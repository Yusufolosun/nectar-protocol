// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

/**
 * @title INectarVault
 * @notice Extended interface for NectarVault with strategy management functions
 * @dev Extends ERC-4626 standard with multi-strategy yield optimization capabilities
 */
interface INectarVault is IERC4626 {
    /* ========== EVENTS ========== */

    /**
     * @notice Emitted when a new strategy is added to the vault
     * @param strategy Address of the strategy contract
     * @param debtRatio Allocation percentage in basis points
     */
    event StrategyAdded(address indexed strategy, uint256 debtRatio);

    /**
     * @notice Emitted when a strategy is removed from the vault
     * @param strategy Address of the strategy contract
     */
    event StrategyRemoved(address indexed strategy);

    /**
     * @notice Emitted when a strategy's debt ratio is updated
     * @param strategy Address of the strategy contract
     * @param newDebtRatio New allocation percentage in basis points
     */
    event StrategyDebtRatioUpdated(address indexed strategy, uint256 newDebtRatio);

    /**
     * @notice Emitted when a strategy is harvested
     * @param strategy Address of the strategy contract
     * @param profit Amount of profit generated
     * @param loss Amount of loss incurred
     */
    event Harvested(address indexed strategy, uint256 profit, uint256 loss);

    /* ========== STRATEGY MANAGEMENT FUNCTIONS ========== */

    /**
     * @notice Adds a new yield strategy
     * @param strategy Strategy contract address
     * @param debtRatio Percentage of funds to allocate (in basis points, max 10000)
     */
    function addStrategy(address strategy, uint256 debtRatio) external;

    /**
     * @notice Removes a strategy and withdraws all funds
     * @param strategy Strategy contract address
     */
    function removeStrategy(address strategy) external;

    /**
     * @notice Updates allocation percentage for a strategy
     * @param strategy Strategy contract address
     * @param debtRatio New debt ratio in basis points
     */
    function updateStrategyDebtRatio(address strategy, uint256 debtRatio) external;

    /**
     * @notice Triggers harvest on a specific strategy
     * @param strategy Strategy contract address
     */
    function harvest(address strategy) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Returns total assets deployed to strategies
     * @return Total debt across all strategies
     */
    function totalDebt() external view returns (uint256);

    /**
     * @notice Returns idle capital available for deployment
     * @return Undeployed want tokens in vault
     */
    function availableCapital() external view returns (uint256);
}
