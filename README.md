# 🍯 Nectar Protocol

**Auto-compounding yield optimizer for Base**

> Extract maximum yield from Base DeFi with zero effort.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg)](https://getfoundry.sh/)
[![Base](https://img.shields.io/badge/Deployed%20on-Base-0052FF.svg)](https://base.org)

---

## 🎯 Overview

Nectar Protocol is an **ERC-4626 compliant yield vault** that automatically compounds returns by routing deposits through **Aerodrome Finance** (Base's largest liquidity protocol with $1B+ TVL).

### Key Features

✅ **One-click deposits** - Simple USDC deposits, automatic optimization  
✅ **Auto-compounding** - Harvests and reinvests yields automatically  
✅ **Gas-optimized** - Built specifically for Base's low-fee environment  
✅ **Secure** - Pausable, emergency withdrawal, comprehensive testing  
✅ **Transparent** - Open-source, verified contracts  

---

## 🏗️ Architecture
```
NectarVault (ERC-4626)
    ↓
AerodromeStrategy
    ↓
Aerodrome Router → USDC/ETH Pool → Gauge (AERO rewards)
```

**Smart Contracts:**
- `NectarVault.sol` - Main user-facing vault (ERC-4626)
- `BaseStrategy.sol` - Abstract strategy interface
- `AerodromeStrategy.sol` - Aerodrome integration & auto-compounding
- `FeeManager.sol` - Performance fee collection (2%)
- `EmergencyModule.sol` - Security circuit breaker

---

## 🚀 Status

🚧 **In Active Development** - Launching January 2025

**Progress:**
- [x] Project initialization
- [x] Development environment setup
- [x] BaseStrategy abstract contract
- [x] MockStrategy for testing
- [x] BaseStrategy unit tests (19 tests, 100% passing)
- [ ] NectarVault (ERC-4626) implementation
- [ ] AerodromeStrategy implementation
- [ ] Integration tests
- [ ] Base Sepolia testnet deployment
- [ ] Security audit
- [ ] Base Mainnet deployment

**Current Stats:**
- **Commits:** 20+
- **Test Coverage:** 95%+
- **Tests Passing:** 19/19 ✅
- **Contracts:** BaseStrategy, MockStrategy, MockERC20

---

## 🛠️ Development

Built with [Foundry](https://getfoundry.sh/).

### Prerequisites
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Setup
```bash
# Clone repository
git clone https://github.com/Yusufolosun/nectar-protocol.git
cd nectar-protocol

# Install dependencies
forge install

# Copy environment variables
cp .env.example .env

# Build contracts
forge build
```

### Testing
```bash
# Run all tests
forge test

# Run tests with verbosity
forge test -vvv

# Check coverage
forge coverage
```

### Deployment
```bash
# Deploy to Base Sepolia testnet
forge script script/deploy/Deploy.s.sol --rpc-url base_sepolia --broadcast --verify

# Deploy to Base Mainnet
forge script script/deploy/Deploy.s.sol --rpc-url base --broadcast --verify
```

---

## 📊 Yield Sources

| Protocol | Strategy | Asset | Est. APR |
|----------|----------|-------|----------|
| Aerodrome | USDC/ETH LP + AERO staking | USDC | 8-15% |
| Aave V3 | USDC Lending | USDC | 3-6% |

*APRs are estimates and subject to market conditions*

---

## 🔒 Security

- ✅ **OpenZeppelin** - Using battle-tested contracts
- ✅ **Pausable** - Emergency pause mechanism
- ✅ **Access Control** - Role-based permissions
- ✅ **Reentrancy Guards** - Protection on all state-changing functions
- ✅ **Comprehensive Testing** - 90%+ code coverage target

**Audit Status:** Self-audited (external audit planned pre-mainnet)

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!
