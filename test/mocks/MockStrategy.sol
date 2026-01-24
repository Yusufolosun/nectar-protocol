// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {BaseStrategy} from "../../src/strategies/BaseStrategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MockStrategy
 * @notice Simple strategy implementation for testing BaseStrategy functionality
 * @dev This is a mock contract for testing purposes only - does not implement actual yield generation
 */
contract MockStrategy is BaseStrategy {
    using SafeERC20 for IERC20;

    /* ========== CONSTRUCTOR ========== */

    /**
     * @notice Initializes the mock strategy
     * @param _vault Address of the vault that owns this strategy
     * @param _want Address of the underlying asset token
     * @param _strategist Address authorized to manage the strategy
     */
    constructor(
        address _vault,
        address _want,
        address _strategist
    ) BaseStrategy(_vault, _want, _strategist) {}

    /* ========== IMPLEMENTED FUNCTIONS ========== */

    /**
     * @notice Returns the name of this mock strategy
     * @return Strategy name
     */
    function name() public pure override returns (string memory) {
        return "MockStrategy";
    }

    /**
     * @notice Deposits want tokens into this mock strategy
     * @param amount Amount of want tokens to deposit
     * @return Amount deposited (1:1 ratio for simplicity)
     */
    function deposit(uint256 amount) 
        external 
        override 
        onlyVault 
        nonReentrant 
        returns (uint256) 
    {
        IERC20(WANT).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(amount, amount);
        return amount;
    }

    /**
     * @notice Withdraws want tokens from this mock strategy
     * @param amount Amount of want tokens to withdraw
     * @return actualAmount Actual amount withdrawn
     */
    function withdraw(uint256 amount) 
        external 
        override 
        onlyVault 
        nonReentrant 
        returns (uint256) 
    {
        uint256 balance = IERC20(WANT).balanceOf(address(this));
        uint256 actualAmount = amount > balance ? balance : amount;
        IERC20(WANT).safeTransfer(msg.sender, actualAmount);
        emit Withdrawn(actualAmount, actualAmount);
        return actualAmount;
    }

    /**
     * @notice Mock harvest (no actual yield generation)
     * @return Always returns 0 (no profit in mock)
     */
    function harvest() 
        external 
        override 
        onlyAuthorized 
        nonReentrant 
        returns (uint256) 
    {
        lastHarvest = block.timestamp;
        emit Harvested(0, block.timestamp);
        return 0;
    }

    /**
     * @notice Returns a fixed mock APR
     * @return Mock APR of 500 basis points (5%)
     */
    function estimateApr() external pure override returns (uint256) {
        return 500;
    }
}
