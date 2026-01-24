// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IBaseStrategy} from "../interfaces/IBaseStrategy.sol";

/**
 * @title BaseStrategy
 * @notice Abstract base contract that provides common functionality for all yield strategies
 * @dev Child contracts must implement deposit, withdraw, harvest, and estimateAPR functions
 */
abstract contract BaseStrategy is Ownable, ReentrancyGuard, IBaseStrategy {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    /// @notice Address of the vault that owns this strategy
    address public immutable VAULT;

    /// @notice Address of the underlying asset token (e.g., USDC)
    address public immutable WANT;

    /// @notice Address authorized to call harvest and manage strategy
    address public strategist;

    /// @notice Address of automated bot that calls harvest
    address public keeper;

    /// @notice Timestamp of the last harvest
    uint256 public lastHarvest;

    /* ========== EVENTS ========== */

    /// @notice Emitted when strategist address is updated
    event StrategistUpdated(address indexed newStrategist);

    /// @notice Emitted when keeper address is updated
    event KeeperUpdated(address indexed newKeeper);

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the base strategy with vault and want token addresses
     * @param _vault Address of the vault that owns this strategy
     * @param _want Address of the underlying asset token
     * @param _strategist Address authorized to manage the strategy
     */
    constructor(
        address _vault,
        address _want,
        address _strategist
    ) Ownable(msg.sender) {
        require(_vault != address(0), "Vault address cannot be zero");
        require(_want != address(0), "Want address cannot be zero");
        require(_strategist != address(0), "Strategist address cannot be zero");

        VAULT = _vault;
        WANT = _want;
        strategist = _strategist;
        lastHarvest = block.timestamp;
    }

    /* ========== MODIFIERS ========== */

    /**
     * @notice Ensures only the vault can call the function
     * @dev Used to restrict deposit and withdraw functions
     */
    modifier onlyVault() {
        _checkOnlyVault();
        _;
    }

    /**
     * @notice Ensures only authorized addresses can call the function
     * @dev Authorized addresses include: vault, strategist, and keeper
     */
    modifier onlyAuthorized() {
        _checkOnlyAuthorized();
        _;
    }

    /* ========== IMPLEMENTED FUNCTIONS ========== */

    /**
     * @notice Returns the name of this strategy
     * @dev Can be overridden by child contracts to provide specific strategy names
     * @return Strategy name
     */
    function name() public pure virtual override returns (string memory) {
        return "BaseStrategy";
    }

    /**
     * @notice Returns total want tokens held by this strategy
     * @dev Can be overridden to include staked/deployed balances in addition to idle balance
     * @return Total balance in want tokens
     */
    function balanceOf() public view virtual override returns (uint256) {
        return IERC20(WANT).balanceOf(address(this));
    }

    /**
     * @notice Updates the strategist address
     * @dev Only owner can update the strategist
     * @param _strategist New strategist address
     */
    function setStrategist(address _strategist) external onlyOwner {
        require(_strategist != address(0), "BaseStrategy: strategist cannot be zero");
        strategist = _strategist;
        emit StrategistUpdated(_strategist);
    }

    /**
     * @notice Updates the keeper address
     * @dev Only owner can update the keeper
     * @param _keeper New keeper address
     */
    function setKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0), "BaseStrategy: keeper cannot be zero");
        keeper = _keeper;
        emit KeeperUpdated(_keeper);
    }

    /* ========== ABSTRACT FUNCTIONS ========== */

    /// @dev Child contracts MUST apply appropriate access control modifiers (onlyVault, onlyAuthorized, nonReentrant)

    /**
     * @notice Deposits want tokens into the strategy
     * @dev Must be implemented by child contracts to deploy capital
     * @param amount Amount of want tokens to deposit
     * @return shares Strategy shares received
     */
    function deposit(uint256 amount)
        external
        virtual
        override
        returns (uint256);

    /**
     * @notice Withdraws want tokens from the strategy
     * @dev Must be implemented by child contracts to withdraw from deployed positions
     * @param amount Amount of want tokens to withdraw
     * @return withdrawn Actual amount withdrawn
     */
    function withdraw(uint256 amount)
        external
        virtual
        override
        returns (uint256);

    /**
     * @notice Harvests rewards and compounds them
     * @dev Must be implemented by child contracts to claim and reinvest rewards
     * @return harvested Amount of profit harvested
     */
    function harvest()
        external
        virtual
        override
        returns (uint256);

    /**
     * @notice Estimates the current annual percentage rate
     * @dev Must be implemented by child contracts based on their specific yield source
     * @return apr Estimated APR in basis points (e.g., 500 = 5%)
     */
    function estimateApr() external view virtual override returns (uint256);

    /* ========== INTERNAL HELPER FUNCTIONS ========== */

    /**
     * @notice Ensures sufficient token allowance for spender
     * @dev Approves max uint256 if current allowance is insufficient
     * @param token Token address to check
     * @param spender Spender address
     * @param amount Required allowance amount
     */
    function _checkAllowance(
        address token,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = IERC20(token).allowance(address(this), spender);
        if (currentAllowance < amount) {
            IERC20(token).forceApprove(spender, type(uint256).max);
        }
    }

    /**
     * @notice Internal function to validate vault-only access
     * @dev Called by onlyVault modifier
     */
    function _checkOnlyVault() private view {
        require(msg.sender == VAULT, "BaseStrategy: only vault");
    }

    /**
     * @notice Internal function to validate authorized access
     * @dev Called by onlyAuthorized modifier
     */
    function _checkOnlyAuthorized() private view {
        require(
            msg.sender == VAULT || msg.sender == strategist || msg.sender == keeper,
            "BaseStrategy: not authorized"
        );
    }
}
