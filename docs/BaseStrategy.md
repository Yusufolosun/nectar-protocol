# BaseStrategy Contract

## Overview

`BaseStrategy` is an abstract Solidity contract that serves as the foundation for all yield-generating strategies in the Nectar Protocol. It provides a standardized interface and common functionality that all concrete strategy implementations must follow, ensuring consistency, security, and maintainability across the protocol.

By inheriting from `BaseStrategy`, strategy developers gain access to built-in access control, reentrancy protection, and helper functions while focusing on implementing strategy-specific yield generation logic.

## Purpose

The `BaseStrategy` abstraction exists to:

- **Standardize Strategy Interface**: All strategies implement the same core functions, making them interchangeable and predictable
- **Reduce Code Duplication**: Common functionality like access control and state management is implemented once
- **Enforce Security Best Practices**: Built-in reentrancy guards and access control modifiers protect all strategies
- **Simplify Integration**: Vaults can interact with any strategy through the same interface
- **Enable Composability**: Strategies can be easily swapped, upgraded, or composed together
- **Improve Maintainability**: Bug fixes and improvements to the base contract benefit all strategies

## Architecture

### Inheritance

```solidity
abstract contract BaseStrategy is Ownable, ReentrancyGuard, IBaseStrategy
```

- **Ownable** (OpenZeppelin v5.x): Provides ownership-based access control for administrative functions
- **ReentrancyGuard** (OpenZeppelin): Protects against reentrancy attacks on state-changing functions
- **IBaseStrategy**: Ensures compliance with the protocol's standard strategy interface

### State Variables

| Variable | Type | Visibility | Description |
|----------|------|------------|-------------|
| `VAULT` | `address` | `immutable public` | Address of the vault that owns this strategy |
| `WANT` | `address` | `immutable public` | Address of the underlying asset token (e.g., USDC) |
| `strategist` | `address` | `public` | Address authorized to call harvest and manage strategy |
| `keeper` | `address` | `public` | Address of automated bot that calls harvest |
| `lastHarvest` | `uint256` | `public` | Timestamp of the last harvest execution |

**Note**: `VAULT` and `WANT` are immutable for gas optimization and security - these critical addresses cannot be changed after deployment.

## Access Control

### Modifiers

The contract implements two access control modifiers:

#### 1. `onlyVault`
```solidity
modifier onlyVault() {
    _checkOnlyVault();
    _;
}
```
- Restricts function access to the vault contract only
- Used for deposit and withdraw functions
- Prevents unauthorized capital movements

#### 2. `onlyAuthorized`
```solidity
modifier onlyAuthorized() {
    _checkOnlyAuthorized();
    _;
}
```
- Allows access to vault, strategist, or keeper
- Used for harvest and management functions
- Enables both automated and manual strategy management

### Functions by Access Level

| Access Level | Functions | Purpose |
|--------------|-----------|---------|
| **Owner** | `setStrategist()`, `setKeeper()` | Administrative control |
| **Vault Only** | `deposit()`, `withdraw()` | Capital management |
| **Authorized** | `harvest()` | Yield optimization |
| **Public View** | `name()`, `vault()`, `want()`, `balanceOf()`, `estimateApr()` | Information queries |

## Functions Reference

### Constructor

```solidity
constructor(
    address _vault,
    address _want,
    address _strategist
) Ownable(msg.sender)
```

**Parameters:**
- `_vault`: Address of the vault contract that will own this strategy
- `_want`: Address of the underlying asset token (e.g., USDC, DAI)
- `_strategist`: Address authorized to manage the strategy

**Validation:**
- All addresses must be non-zero
- Sets immutable `VAULT` and `WANT` variables
- Initializes `lastHarvest` to current block timestamp
- Deployer becomes the owner via `Ownable(msg.sender)`

### Implemented Functions

#### `name()`
```solidity
function name() public pure virtual override returns (string memory)
```
- Returns the strategy name (default: "BaseStrategy")
- Can be overridden by child contracts for specific names
- Pure function - no state access

#### `vault()`
```solidity
function vault() external view override returns (address)
```
- Returns the address of the vault that owns this strategy
- Implements `IBaseStrategy` interface requirement
- Returns the immutable `VAULT` address

#### `want()`
```solidity
function want() external view override returns (address)
```
- Returns the address of the underlying asset token
- Implements `IBaseStrategy` interface requirement
- Returns the immutable `WANT` address

#### `balanceOf()`
```solidity
function balanceOf() public view virtual override returns (uint256)
```
- Returns the total want tokens held by this strategy
- Default implementation: idle balance in contract
- Can be overridden to include staked/deployed balances
- Virtual function for strategy-specific logic

#### `setStrategist()`
```solidity
function setStrategist(address _strategist) external onlyOwner
```
- Updates the strategist address
- Only callable by contract owner
- Validates non-zero address
- Emits `StrategistUpdated` event

#### `setKeeper()`
```solidity
function setKeeper(address _keeper) external onlyOwner
```
- Updates the keeper (automation bot) address
- Only callable by contract owner
- Validates non-zero address
- Emits `KeeperUpdated` event

### Abstract Functions (Child Contracts Must Implement)

#### `deposit(uint256 amount)`
```solidity
function deposit(uint256 amount) external virtual override returns (uint256);
```
- **Purpose**: Deposits want tokens into the strategy
- **Access**: Must apply `onlyVault` and `nonReentrant` modifiers
- **Returns**: Amount of shares/tokens received
- **Implementation**: Transfer tokens from vault, deploy capital, emit `Deposited` event

#### `withdraw(uint256 amount)`
```solidity
function withdraw(uint256 amount) external virtual override returns (uint256);
```
- **Purpose**: Withdraws want tokens from the strategy
- **Access**: Must apply `onlyVault` and `nonReentrant` modifiers
- **Returns**: Actual amount withdrawn (may differ due to slippage)
- **Implementation**: Withdraw from deployed positions, transfer to vault, emit `Withdrawn` event

#### `harvest()`
```solidity
function harvest() external virtual override returns (uint256);
```
- **Purpose**: Claims rewards and compounds them back into the strategy
- **Access**: Must apply `onlyAuthorized` and `nonReentrant` modifiers
- **Returns**: Amount of profit harvested
- **Implementation**: Claim rewards, swap to want token, reinvest, update `lastHarvest`, emit `Harvested` event

#### `estimateApr()`
```solidity
function estimateApr() external view virtual override returns (uint256);
```
- **Purpose**: Estimates the current annual percentage rate
- **Returns**: APR in basis points (e.g., 500 = 5%)
- **Implementation**: Calculate based on strategy-specific yield sources

## Creating a New Strategy

### Step-by-Step Guide

1. **Create a new contract that inherits from BaseStrategy**
```solidity
import {BaseStrategy} from "../strategies/BaseStrategy.sol";

contract MyYieldStrategy is BaseStrategy {
    // Your code here
}
```

2. **Implement the constructor**
```solidity
constructor(
    address _vault,
    address _want,
    address _strategist
) BaseStrategy(_vault, _want, _strategist) {
    // Strategy-specific initialization
}
```

3. **Add strategy-specific state variables**
```solidity
address public yieldProtocol;
uint256 public performanceFee;
```

4. **Implement all abstract functions with proper modifiers**
```solidity
function deposit(uint256 amount) 
    external 
    override 
    onlyVault 
    nonReentrant 
    returns (uint256) 
{
    // Implementation
}
```

5. **Emit appropriate events**
```solidity
emit Deposited(amount, shares);
emit Withdrawn(amount, shares);
emit Harvested(profit, block.timestamp);
```

### Example Code

Here's a minimal concrete implementation:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {BaseStrategy} from "../strategies/BaseStrategy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SimpleYieldStrategy is BaseStrategy {
    using SafeERC20 for IERC20;

    address public immutable YIELD_VAULT;

    constructor(
        address _vault,
        address _want,
        address _strategist,
        address _yieldVault
    ) BaseStrategy(_vault, _want, _strategist) {
        YIELD_VAULT = _yieldVault;
    }

    function name() public pure override returns (string memory) {
        return "Simple Yield Strategy";
    }

    function deposit(uint256 amount) 
        external 
        override 
        onlyVault 
        nonReentrant 
        returns (uint256) 
    {
        IERC20(WANT).safeTransferFrom(msg.sender, address(this), amount);
        _checkAllowance(WANT, YIELD_VAULT, amount);
        
        // Deposit to yield protocol
        IYieldVault(YIELD_VAULT).deposit(amount);
        
        emit Deposited(amount, amount);
        return amount;
    }

    function withdraw(uint256 amount) 
        external 
        override 
        onlyVault 
        nonReentrant 
        returns (uint256) 
    {
        // Withdraw from yield protocol
        IYieldVault(YIELD_VAULT).withdraw(amount);
        
        IERC20(WANT).safeTransfer(msg.sender, amount);
        emit Withdrawn(amount, amount);
        return amount;
    }

    function harvest() 
        external 
        override 
        onlyAuthorized 
        nonReentrant 
        returns (uint256) 
    {
        // Claim rewards
        uint256 profit = IYieldVault(YIELD_VAULT).claimRewards();
        
        lastHarvest = block.timestamp;
        emit Harvested(profit, block.timestamp);
        return profit;
    }

    function estimateApr() external view override returns (uint256) {
        return IYieldVault(YIELD_VAULT).getCurrentApr();
    }

    function balanceOf() public view override returns (uint256) {
        return IYieldVault(YIELD_VAULT).balanceOf(address(this));
    }
}
```

## Security Considerations

### Reentrancy Protection
- All state-changing functions (`deposit`, `withdraw`, `harvest`) must use the `nonReentrant` modifier
- Protects against reentrancy attacks during external calls to DeFi protocols

### Access Control Enforcement
- `onlyVault` ensures only the trusted vault can move capital
- `onlyAuthorized` limits harvest access to trusted addresses
- `onlyOwner` restricts administrative functions

### Input Validation
- Constructor validates all addresses are non-zero
- `setStrategist` and `setKeeper` enforce non-zero addresses
- Child contracts should validate amounts and parameters

### Safe Token Operations
- Always use `SafeERC20` library for token transfers
- Use `forceApprove` instead of deprecated `safeApprove` (OpenZeppelin v5.x)
- Check balances before and after transfers when necessary

### Immutable Critical Addresses
- `VAULT` and `WANT` are immutable, preventing address manipulation
- Reduces attack surface and gas costs
- Uses SCREAMING_SNAKE_CASE convention for clarity

### Best Practices
- Follow checks-effects-interactions pattern
- Emit events for all state changes
- Consider slippage in withdrawal calculations
- Implement emergency withdrawal mechanisms in child contracts

## Testing

The `BaseStrategy` contract is thoroughly tested through the `MockStrategy` implementation.

**Test File**: [`test/unit/BaseStrategy.t.sol`](../test/unit/BaseStrategy.t.sol)

**Test Coverage**: 19 comprehensive unit tests covering:
- Initial state validation
- Getter functions
- Access control (authorized and unauthorized)
- Deposit/withdraw functionality
- Harvest from multiple authorized addresses
- Zero address validation
- Event emissions
- Balance tracking

**Run Tests**:
```bash
forge test --match-contract BaseStrategyTest -vv
```

## Gas Optimizations

### Wrapped Modifiers
```solidity
modifier onlyVault() {
    _checkOnlyVault();
    _;
}

function _checkOnlyVault() private view {
    require(msg.sender == VAULT, "BaseStrategy: only vault");
}
```
- Reduces bytecode size by extracting modifier logic to private functions
- Each modifier usage adds a function call instead of inlining code
- Significant savings when modifiers are used multiple times

### Immutable Variables
- `VAULT` and `WANT` are immutable, stored in bytecode not storage
- Saves ~2,100 gas per read compared to storage variables
- Cannot be changed, providing security and efficiency

### SafeERC20 Library
- Uses `forceApprove` for efficient allowance management
- Handles non-standard ERC20 implementations safely
- Reduces gas costs compared to manual approval patterns

### State Variable Packing
- Consider packing smaller types when extending BaseStrategy
- `strategist` and `keeper` could be optimized in future versions
- `lastHarvest` (uint256) already optimized for timestamp storage

---

**Version**: 1.0.0  
**License**: MIT  
**Solidity**: ^0.8.28
