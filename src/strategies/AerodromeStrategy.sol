// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {BaseStrategy} from "./BaseStrategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IAerodromeRouter, IAerodromeGauge, IAerodromePair} from "../interfaces/IAerodrome.sol";

/**
 * @title AerodromeStrategy
 * @notice Strategy for yield farming on Aerodrome Finance
 * @dev Deposits want tokens into Aerodrome LP pools and stakes in Gauges
 */
contract AerodromeStrategy is BaseStrategy {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    // Aerodrome contracts
    /// @notice Aerodrome Router contract
    IAerodromeRouter public immutable ROUTER;
    /// @notice Aerodrome Gauge contract for LP staking
    IAerodromeGauge public immutable GAUGE;
    /// @notice Aerodrome LP Token (Pool) contract
    IAerodromePair public immutable LP_TOKEN;

    // Tokens
    /// @notice AERO token address
    address public immutable AERO;
    /// @notice The other token in the LP pair (e.g., WETH)
    address public immutable PAIR_TOKEN;

    /// @notice Slippage protection in basis points (e.g., 100 = 1%)
    uint256 public slippageTolerance;
    /// @notice Maximum allowed slippage tolerance (5%)
    uint256 public constant MAX_SLIPPAGE = 500;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the Aerodrome Strategy
     * @param _vault Address of the vault that owns this strategy
     * @param _want Address of the underlying asset token (e.g., USDC)
     * @param _strategist Address authorized to manage the strategy
     * @param _router Aerodrome router address
     * @param _gauge Aerodrome gauge for LP staking
     * @param _lpToken USDC/WETH pair token
     * @param _aero AERO token address
     * @param _pairToken WETH address
     */
    constructor(
        address _vault,
        address _want,
        address _strategist,
        address _router,
        address _gauge,
        address _lpToken,
        address _aero,
        address _pairToken
    ) BaseStrategy(_vault, _want, _strategist) {
        require(_router != address(0), "AerodromeStrategy: zero router");
        require(_gauge != address(0), "AerodromeStrategy: zero gauge");
        require(_lpToken != address(0), "AerodromeStrategy: zero lpToken");
        require(_aero != address(0), "AerodromeStrategy: zero aero");
        require(_pairToken != address(0), "AerodromeStrategy: zero pairToken");

        ROUTER = IAerodromeRouter(_router);
        GAUGE = IAerodromeGauge(_gauge);
        LP_TOKEN = IAerodromePair(_lpToken);
        AERO = _aero;
        PAIR_TOKEN = _pairToken;
        slippageTolerance = 100; // Default 1%
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Returns the name of the strategy
     * @return Strategy name string
     */
    function name() public pure override returns (string memory) {
        return "AerodromeStrategy";
    }

    /**
     * @notice Returns total want tokens controlled by strategy
     * @dev Includes LP value converted back to want
     * @return Total balance in want tokens
     */
    function balanceOf() public view override returns (uint256) {
        // TODO: Implement balance calculation including staked LP value
        return 0;
    }

    /**
     * @notice Estimates current APR based on AERO emissions
     * @return Estimated APR in basis points (e.g., 500 = 5%)
     */
    function estimateApr() external view override returns (uint256) {
        // TODO: Implement APR estimation
        return 0;
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    /**
     * @notice Deposits want tokens and deploys to Aerodrome
     * @param amount Amount of want tokens to deposit
     * @return shares Strategy shares received (always matches amount for now)
     */
    function deposit(uint256 amount) external override onlyVault nonReentrant returns (uint256) {
        // TODO: Implement deposit logic
        return amount;
    }

    /**
     * @notice Withdraws want tokens from Aerodrome positions
     * @param amount Amount of want tokens to withdraw
     * @return withdrawn Actual amount withdrawn
     */
    function withdraw(uint256 amount) external override onlyVault nonReentrant returns (uint256) {
        // TODO: Implement withdraw logic
        return 0;
    }

    /**
     * @notice Harvests AERO rewards and compounds into position
     * @return harvested Amount of profit (want tokens) harvested
     */
    function harvest() external override onlyAuthorized nonReentrant returns (uint256) {
        // TODO: Implement harvest and compound logic
        return 0;
    }

    /**
     * @notice Updates slippage tolerance
     * @param _slippage New slippage in basis points (max 500)
     */
    function setSlippageTolerance(uint256 _slippage) external onlyOwner {
        require(_slippage <= MAX_SLIPPAGE, "AerodromeStrategy: slippage too high");
        slippageTolerance = _slippage;
    }

    /* ========== INTERNAL HELPER FUNCTIONS ========== */

    /**
     * @notice Swaps half want to pair token and adds liquidity
     * @dev Internal helper for deployment
     * @param wantAmount Amount of want tokens to use
     * @return liquidity Amount of LP tokens received
     */
    function _addLiquidity(uint256 wantAmount) internal returns (uint256 liquidity) {
        // TODO: Implement liquidity addition logic
        return 0;
    }

    /**
     * @notice Removes liquidity and swaps pair token back to want
     * @dev Internal helper for withdrawals
     * @param liquidity Amount of LP tokens to remove
     * @return wantAmount Total amount of want tokens received
     */
    function _removeLiquidity(uint256 liquidity) internal returns (uint256 wantAmount) {
        // TODO: Implement liquidity removal logic
        return 0;
    }

    /**
     * @notice Swaps any token to want via Aerodrome router
     * @dev Internal helper for harvesting
     * @param tokenIn Address of token to swap from
     * @param amountIn Amount of tokens to swap
     * @return amountOut Amount of want tokens received
     */
    function _swapToWant(address tokenIn, uint256 amountIn) internal returns (uint256 amountOut) {
        // TODO: Implement swap logic
        return 0;
    }

    /**
     * @notice Calculates total LP position value in want tokens
     * @dev Internal helper for balance calculation
     * @return Total value in want tokens
     */
    function _getLPValue() internal view returns (uint256) {
        // TODO: Implement LP valuation logic
        return 0;
    }
}
