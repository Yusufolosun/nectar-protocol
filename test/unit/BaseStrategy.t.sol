// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {MockStrategy} from "../mocks/MockStrategy.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {IBaseStrategy} from "../../src/interfaces/IBaseStrategy.sol";
import {BaseStrategy} from "../../src/strategies/BaseStrategy.sol";

/**
 * @title BaseStrategyTest
 * @notice Unit tests for BaseStrategy abstract contract functionality
 * @dev Tests the base strategy implementation using MockStrategy
 */
contract BaseStrategyTest is Test {
    MockStrategy public strategy;
    MockERC20 public wantToken;
    address public vault = makeAddr("vault");
    address public strategist = makeAddr("strategist");
    address public keeper = makeAddr("keeper");
    address public user = makeAddr("user");

    function setUp() public {
        wantToken = new MockERC20("Mock USDC", "mUSDC");
        strategy = new MockStrategy(vault, address(wantToken), strategist);
        strategy.setKeeper(keeper);
        wantToken.mint(vault, 1000e6);
    }

    function test_InitialState() public view {
        assertEq(strategy.VAULT(), vault, "Vault address mismatch");
        assertEq(strategy.WANT(), address(wantToken), "Want token address mismatch");
        assertEq(strategy.strategist(), strategist, "Strategist address mismatch");
        assertEq(strategy.keeper(), keeper, "Keeper address mismatch");
        assertEq(strategy.name(), "MockStrategy", "Strategy name mismatch");
        assertGt(strategy.lastHarvest(), 0, "Last harvest should be initialized");
    }

    function test_VaultGetter() public view {
        assertEq(strategy.vault(), vault, "Vault getter returns incorrect address");
    }

    function test_WantGetter() public view {
        assertEq(strategy.want(), address(wantToken), "Want getter returns incorrect address");
    }

    function test_SetStrategist() public {
        address newStrategist = makeAddr("newStrategist");
        
        vm.expectEmit(true, false, false, false);
        emit BaseStrategy.StrategistUpdated(newStrategist);
        
        strategy.setStrategist(newStrategist);
        
        assertEq(strategy.strategist(), newStrategist, "Strategist not updated");
    }

    function test_SetStrategist_RevertUnauthorized() public {
        address newStrategist = makeAddr("newStrategist");
        
        vm.prank(user);
        vm.expectRevert();
        strategy.setStrategist(newStrategist);
    }

    function test_SetStrategist_RevertZeroAddress() public {
        vm.expectRevert("BaseStrategy: strategist cannot be zero");
        strategy.setStrategist(address(0));
    }

    function test_SetKeeper() public {
        address newKeeper = makeAddr("newKeeper");
        
        vm.expectEmit(true, false, false, false);
        emit BaseStrategy.KeeperUpdated(newKeeper);
        
        strategy.setKeeper(newKeeper);
        
        assertEq(strategy.keeper(), newKeeper, "Keeper not updated");
    }

    function test_SetKeeper_RevertUnauthorized() public {
        address newKeeper = makeAddr("newKeeper");
        
        vm.prank(user);
        vm.expectRevert();
        strategy.setKeeper(newKeeper);
    }

    function test_SetKeeper_RevertZeroAddress() public {
        vm.expectRevert("BaseStrategy: keeper cannot be zero");
        strategy.setKeeper(address(0));
    }

    function test_Deposit_Success() public {
        uint256 depositAmount = 100e6;
        
        vm.startPrank(vault);
        wantToken.approve(address(strategy), depositAmount);
        
        vm.expectEmit(true, true, false, false);
        emit IBaseStrategy.Deposited(depositAmount, depositAmount);
        
        uint256 shares = strategy.deposit(depositAmount);
        vm.stopPrank();
        
        assertEq(shares, depositAmount, "Shares mismatch");
        assertEq(strategy.balanceOf(), depositAmount, "Strategy balance mismatch");
        assertEq(wantToken.balanceOf(address(strategy)), depositAmount, "Token balance mismatch");
    }

    function test_Deposit_RevertUnauthorized() public {
        uint256 depositAmount = 100e6;
        
        vm.prank(user);
        vm.expectRevert("BaseStrategy: only vault");
        strategy.deposit(depositAmount);
    }

    function test_Withdraw_Success() public {
        uint256 depositAmount = 100e6;
        uint256 withdrawAmount = 50e6;
        
        // First deposit
        vm.startPrank(vault);
        wantToken.approve(address(strategy), depositAmount);
        strategy.deposit(depositAmount);
        
        // Then withdraw
        uint256 balanceBefore = wantToken.balanceOf(vault);
        
        vm.expectEmit(true, true, false, false);
        emit IBaseStrategy.Withdrawn(withdrawAmount, withdrawAmount);
        
        uint256 withdrawn = strategy.withdraw(withdrawAmount);
        vm.stopPrank();
        
        assertEq(withdrawn, withdrawAmount, "Withdrawn amount mismatch");
        assertEq(strategy.balanceOf(), depositAmount - withdrawAmount, "Strategy balance mismatch");
        assertEq(wantToken.balanceOf(vault), balanceBefore + withdrawAmount, "Vault balance mismatch");
    }

    function test_Withdraw_RevertUnauthorized() public {
        uint256 withdrawAmount = 50e6;
        
        vm.prank(user);
        vm.expectRevert("BaseStrategy: only vault");
        strategy.withdraw(withdrawAmount);
    }

    function test_Harvest_AsVault() public {
        vm.prank(vault);
        
        vm.expectEmit(true, true, false, false);
        emit IBaseStrategy.Harvested(0, block.timestamp);
        
        uint256 profit = strategy.harvest();
        
        assertEq(profit, 0, "Mock harvest should return 0 profit");
    }

    function test_Harvest_AsStrategist() public {
        vm.prank(strategist);
        
        vm.expectEmit(true, true, false, false);
        emit IBaseStrategy.Harvested(0, block.timestamp);
        
        uint256 profit = strategy.harvest();
        
        assertEq(profit, 0, "Mock harvest should return 0 profit");
    }

    function test_Harvest_AsKeeper() public {
        vm.prank(keeper);
        
        vm.expectEmit(true, true, false, false);
        emit IBaseStrategy.Harvested(0, block.timestamp);
        
        uint256 profit = strategy.harvest();
        
        assertEq(profit, 0, "Mock harvest should return 0 profit");
    }

    function test_Harvest_RevertUnauthorized() public {
        vm.prank(user);
        vm.expectRevert("BaseStrategy: not authorized");
        strategy.harvest();
    }

    function test_EstimateApr() public view {
        uint256 apr = strategy.estimateApr();
        assertEq(apr, 500, "Mock APR should be 500 basis points (5%)");
    }

    function test_BalanceOf() public {
        uint256 depositAmount = 250e6;
        
        assertEq(strategy.balanceOf(), 0, "Initial balance should be 0");
        
        vm.startPrank(vault);
        wantToken.approve(address(strategy), depositAmount);
        strategy.deposit(depositAmount);
        vm.stopPrank();
        
        assertEq(strategy.balanceOf(), depositAmount, "Balance should match deposited amount");
    }
}
