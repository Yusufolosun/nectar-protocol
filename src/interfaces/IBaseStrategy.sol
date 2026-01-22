// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IBaseStrategy
 * @notice Standard interface that all yield strategies must implement
 * @dev Defines the core functionality required for strategies that interact with the NectarVault
 */
interface IBaseStrategy {
    // ============ Events ============

    /**
     * @notice Emitted when assets are deposited into the strategy
     * @param amount The amount of want tokens deposited
     * @param shares The amount of strategy shares received
     */
    event Deposited(uint256 amount, uint256 shares);

    /**
     * @notice Emitted when assets are withdrawn from the strategy
     * @param amount The amount of want tokens withdrawn
     * @param shares The amount of strategy shares burned
     */
    event Withdrawn(uint256 amount, uint256 shares);

    /**
     * @notice Emitted when rewards are harvested and compounded
     * @param profit The amount of profit harvested in want tokens
     * @param timestamp The timestamp when harvest occurred
     */
    event Harvested(uint256 profit, uint256 timestamp);

    // ============ View Functions ============

    /**
     * @notice Returns the name of the strategy
     * @dev Used for identification and display purposes
     * @return Strategy name as a string
     */
    function name() external pure returns (string memory);

    /**
     * @notice Returns the vault address that owns this strategy
     * @dev The vault has privileged access to deposit/withdraw functions
     * @return Address of the vault contract
     */
    function vault() external view returns (address);

    /**
     * @notice Returns the underlying asset token address (e.g., USDC)
     * @dev This is the token that users deposit and withdraw
     * @return Address of the want token
     */
    function want() external view returns (address);

    /**
     * @notice Returns total assets controlled by this strategy
     * @dev Includes both idle assets and assets deployed in yield sources
     * @return Total balance in want tokens
     */
    function balanceOf() external view returns (uint256);

    /**
     * @notice Estimates the current annual percentage rate
     * @dev Returns the estimated APR based on current market conditions
     * @return apr Estimated APR in basis points (e.g., 500 = 5%)
     */
    function estimateAPR() external view returns (uint256);

    // ============ State-Changing Functions ============

    /**
     * @notice Deposits assets into the strategy
     * @dev Only callable by the vault contract
     * @param amount Amount of want tokens to deposit
     * @return shares Strategy shares received for the deposit
     */
    function deposit(uint256 amount) external returns (uint256 shares);

    /**
     * @notice Withdraws assets from the strategy
     * @dev Only callable by the vault contract
     * @param amount Amount of want tokens to withdraw
     * @return withdrawn Actual amount withdrawn (may differ due to slippage)
     */
    function withdraw(uint256 amount) external returns (uint256 withdrawn);

    /**
     * @notice Harvests rewards and compounds them back into the strategy
     * @dev Should claim rewards, swap to want token, and reinvest
     * @return harvested Amount of profit harvested in want tokens
     */
    function harvest() external returns (uint256 harvested);
}
