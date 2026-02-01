// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title IAerodromeRouter
 * @notice Interface for the Aerodrome Finance Router on Base
 * @dev Handles swapping and liquidity management functions
 */
interface IAerodromeRouter {
    /**
     * @notice Structure representing a swap route
     * @param from Address of the token to swap from
     * @param to Address of the token to swap to
     * @param stable Whether the pool is a stable pool or volatile pool
     * @param factory Address of the factory for this pool
     */
    struct Route {
        address from;
        address to;
        bool stable;
        address factory;
    }

    /**
     * @notice Swap an exact amount of tokens for another token
     * @param amountIn Amount of input tokens to swap
     * @param amountOutMin Minimum amount of output tokens to receive
     * @param routes Array of Route structs defining the swap path
     * @param to Address to receive the output tokens
     * @param deadline Unix timestamp after which the transaction will revert
     * @return amounts Array of input and output amounts for each step in the route
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @notice Add liquidity to a pool
     * @param tokenA Address of token A
     * @param tokenB Address of token B
     * @param stable Whether the pool is stable or volatile
     * @param amountADesired Amount of token A to add
     * @param amountBDesired Amount of token B to add
     * @param amountAMin Minimum amount of token A to add
     * @param amountBMin Minimum amount of token B to add
     * @param to Address to receive the LP tokens
     * @param deadline Unix timestamp after which the transaction will revert
     * @return amountA Actual amount of token A added
     * @return amountB Actual amount of token B added
     * @return liquidity Amount of LP tokens minted
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /**
     * @notice Remove liquidity from a pool
     * @param tokenA Address of token A
     * @param tokenB Address of token B
     * @param stable Whether the pool is stable or volatile
     * @param liquidity Amount of LP tokens to burn
     * @param amountAMin Minimum amount of token A to receive
     * @param amountBMin Minimum amount of token B to receive
     * @param to Address to receive the tokens
     * @param deadline Unix timestamp after which the transaction will revert
     * @return amountA Amount of token A received
     * @return amountB Amount of token B received
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    /**
     * @notice Calculate the output amounts for a given input amount and route
     * @param amountIn Amount of input tokens
     * @param routes Array of Route structs defining the swap path
     * @return amounts Array of expected input and output amounts for each step
     */
    function getAmountsOut(uint256 amountIn, Route[] memory routes) 
        external view returns (uint256[] memory amounts);
}

/**
 * @title IAerodromeGauge
 * @notice Interface for Aerodrome Finance Gauges
 * @dev Used for staking LP tokens to earn AERO rewards
 */
interface IAerodromeGauge {
    /**
     * @notice Stakes LP tokens to earn AERO rewards
     * @param amount Amount of LP tokens to stake
     */
    function deposit(uint256 amount) external;

    /**
     * @notice Unstakes LP tokens
     * @param amount Amount of LP tokens to withdraw
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice Claims AERO rewards
     * @param account Address of the account to claim rewards for
     */
    function getReward(address account) external;

    /**
     * @notice Returns the staked balance of an account
     * @param account Address of the account to check
     * @return The amount of LP tokens staked by the account
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Returns the pending AERO rewards for an account
     * @param account Address of the account to check
     * @return The amount of pending AERO rewards
     */
    function earned(address account) external view returns (uint256);
}

/**
 * @title IAerodromePair
 * @notice Interface for Aerodrome Finance LP tokens (Pools)
 * @dev Inherits standard ERC20 functionality and adds pool-specific views
 */
interface IAerodromePair {
    /**
     * @notice Get the address of the first token in the pair
     * @return The address of token0
     */
    function token0() external view returns (address);

    /**
     * @notice Get the address of the second token in the pair
     * @return The address of token1
     */
    function token1() external view returns (address);

    /**
     * @notice Check if the pool is a stable pool
     * @return True if the pool is stable, false if volatile
     */
    function stable() external view returns (bool);

    /**
     * @notice Returns the LP token balance of an account
     * @param account Address of the account to check
     * @return The LP token balance
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Approve an address to spend LP tokens
     * @param spender Address to authorize
     * @param amount Amount of tokens to approve
     * @return True if the approval was successful
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @notice Transfer LP tokens to another address
     * @param to Address to receive the tokens
     * @param amount Amount of tokens to transfer
     * @return True if the transfer was successful
     */
    function transfer(address to, uint256 amount) external returns (bool);
}
