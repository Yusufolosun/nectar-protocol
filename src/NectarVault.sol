// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {INectarVault} from "./interfaces/INectarVault.sol";
import {IBaseStrategy} from "./interfaces/IBaseStrategy.sol";

/**
 * @title NectarVault
 * @notice ERC-4626 compliant vault with multi-strategy yield optimization
 * @dev Manages multiple yield strategies and automatically allocates capital for optimal returns
 */
contract NectarVault is ERC4626, Ownable, ReentrancyGuard, INectarVault {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /* ========== STATE VARIABLES ========== */

    /**
     * @notice Parameters for each strategy
     * @param debtRatio Percentage of funds allocated (basis points, max 10000)
     * @param totalDebt Current amount deployed to this strategy
     * @param lastReport Timestamp of last harvest
     * @param active Whether strategy is active
     */
    struct StrategyParams {
        uint256 debtRatio;
        uint256 totalDebt;
        uint256 lastReport;
        bool active;
    }

    /// @notice Mapping of strategy addresses to their parameters
    mapping(address => StrategyParams) public strategies;

    /// @notice Array of all strategy addresses
    address[] public strategyList;

    /// @notice Maximum basis points (100%)
    uint256 public constant MAX_BPS = 10000;

    /// @notice Sum of all strategy debt ratios
    uint256 public totalDebtRatio;

    /// @notice Total assets deployed across all strategies
    uint256 public totalStrategyDebt;

    /// @notice Address that receives performance fees
    address public feeRecipient;

    /// @notice Performance fee in basis points (e.g., 200 = 2%)
    uint256 public performanceFee;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the Nectar Vault
     * @param asset Underlying token address (e.g., USDC)
     * @param name Vault token name (e.g., "Nectar USDC Vault")
     * @param symbol Vault token symbol (e.g., "nUSDC")
     * @param _feeRecipient Address to receive performance fees
     */
    constructor(
        IERC20 asset,
        string memory name,
        string memory symbol,
        address _feeRecipient
    ) ERC4626(asset) ERC20(name, symbol) Ownable(msg.sender) {
        require(_feeRecipient != address(0), "NectarVault: zero address");
        feeRecipient = _feeRecipient;
        performanceFee = 200; // Default 2%
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Returns total assets under management (idle + deployed)
     * @dev Overrides ERC4626 to include strategy debt
     * @return Total assets in want token
     */
    function totalAssets() public view virtual override(ERC4626, IERC4626) returns (uint256) {
        return IERC20(asset()).balanceOf(address(this)) + totalStrategyDebt;
    }

    /**
     * @notice Returns idle capital not deployed to strategies
     * @return Idle want tokens in vault
     */
    function availableCapital() public view override returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    /**
     * @notice Returns total assets deployed across all strategies
     * @return Total debt across all strategies
     */
    function totalDebt() public view override returns (uint256) {
        return totalStrategyDebt;
    }

    /* ========== STRATEGY MANAGEMENT FUNCTIONS ========== */

    /**
     * @notice Adds a new yield strategy
     * @dev Only owner can add strategies. Total debt ratio cannot exceed 100%
     * @param strategy Strategy contract address
     * @param debtRatio Percentage of funds to allocate (in basis points, max 10000)
     */
    function addStrategy(address strategy, uint256 debtRatio) 
        external 
        override 
        onlyOwner 
    {
        require(strategy != address(0), "NectarVault: zero address");
        require(debtRatio <= MAX_BPS, "NectarVault: debtRatio too high");
        require(totalDebtRatio + debtRatio <= MAX_BPS, "NectarVault: total debtRatio exceeded");
        require(!strategies[strategy].active, "NectarVault: strategy already active");
        
        // Verify strategy has correct want token
        require(IBaseStrategy(strategy).want() == asset(), "NectarVault: wrong want token");
        
        // Verify this vault owns the strategy
        require(IBaseStrategy(strategy).vault() == address(this), "NectarVault: wrong vault");
        
        strategies[strategy] = StrategyParams({
            debtRatio: debtRatio,
            totalDebt: 0,
            lastReport: block.timestamp,
            active: true
        });
        
        strategyList.push(strategy);
        totalDebtRatio += debtRatio;
        
        emit StrategyAdded(strategy, debtRatio);
    }

    /**
     * @notice Removes a strategy and withdraws all funds
     * @dev Only owner can remove strategies. Withdraws all capital before removal
     * @param strategy Strategy contract address
     */
    function removeStrategy(address strategy) 
        external 
        override 
        onlyOwner 
    {
        require(strategies[strategy].active, "NectarVault: strategy not active");
        
        StrategyParams storage params = strategies[strategy];
        
        // Withdraw all funds from strategy
        if (params.totalDebt > 0) {
            uint256 withdrawn = IBaseStrategy(strategy).withdraw(params.totalDebt);
            totalStrategyDebt -= params.totalDebt;
            params.totalDebt = 0;
        }
        
        // Update total debt ratio
        totalDebtRatio -= params.debtRatio;
        
        // Mark as inactive
        params.active = false;
        params.debtRatio = 0;
        
        // Remove from strategy list
        for (uint256 i = 0; i < strategyList.length; i++) {
            if (strategyList[i] == strategy) {
                strategyList[i] = strategyList[strategyList.length - 1];
                strategyList.pop();
                break;
            }
        }
        
        emit StrategyRemoved(strategy);
    }

    /**
     * @notice Updates allocation percentage for a strategy
     * @dev Only owner can update debt ratios. Rebalances capital accordingly
     * @param strategy Strategy contract address
     * @param debtRatio New debt ratio in basis points
     */
    function updateStrategyDebtRatio(address strategy, uint256 debtRatio) external override onlyOwner {
        require(strategies[strategy].active, "NectarVault: strategy not active");
        require(debtRatio <= MAX_BPS, "NectarVault: debtRatio exceeds max");

        // TODO: Implement in next iteration
        // - Calculate new total debt ratio
        // - Ensure total doesn't exceed MAX_BPS
        // - Update strategy debt ratio
        // - Rebalance capital if necessary
        // - Emit StrategyDebtRatioUpdated event
    }

    /**
     * @notice Triggers harvest on a specific strategy
     * @dev Can be called by anyone to harvest strategy rewards
     * @param strategy Strategy contract address
     */
    function harvest(address strategy) external override {
        require(strategies[strategy].active, "NectarVault: strategy not active");

        // TODO: Implement in next iteration
        // - Call strategy.harvest()
        // - Calculate profit/loss
        // - Deduct performance fee from profit
        // - Update strategy.totalDebt
        // - Update totalStrategyDebt
        // - Update strategy.lastReport
        // - Emit Harvested event
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates performance fee
     * @dev Only owner can update. Maximum fee is 20% (2000 basis points)
     * @param _performanceFee New fee in basis points (max 2000 = 20%)
     */
    function setPerformanceFee(uint256 _performanceFee) external onlyOwner {
        require(_performanceFee <= 2000, "NectarVault: fee exceeds maximum");
        performanceFee = _performanceFee;
    }

    /**
     * @notice Updates fee recipient address
     * @dev Only owner can update
     * @param _feeRecipient New fee recipient address
     */
    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "NectarVault: zero address");
        feeRecipient = _feeRecipient;
    }
}
