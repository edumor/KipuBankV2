# KipuBankV2 - Decentralized Banking System 🏦

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-v5.0.0-blue.svg)](https://openzeppelin.com/)
[![Chainlink](https://img.shields.io/badge/Chainlink-Oracles-red.svg)](https://chain.link/)

## 📋 Contract Information

- **Contract Address:** `0x5118780bEfEC5eBB67eaBbD0660441632577C2DA`
- **Network:** Sepolia Testnet
- **Etherscan:** [View on Etherscan](https://sepolia.etherscan.io/address/0x5118780bEfEC5eBB67eaBbD0660441632577C2DA)
- **Solidity Version:** 0.8.20
- **Status:** ✅ Verified and Deployed

## 🎯 Overview

KipuBankV2 is a gas-optimized decentralized banking system that enables ETH and ERC20 token deposits and withdrawals with real-time USD conversion using Chainlink oracles. The contract implements advanced security features including role-based access control, emergency pause mechanisms, and comprehensive event logging.

## ✨ Key Features

- **Multi-Asset Support**: Native ETH and configurable ERC20 tokens
- **Real-Time Pricing**: Chainlink oracle integration with staleness protection
- **Role-Based Security**: Granular access control with emergency response capabilities
- **Gas Optimized**: Single storage read per variable per function
- **Complete Observability**: Comprehensive event logging and custom error handling
- **Risk Management**: Configurable withdrawal limits and bank capacity controls

## 🏗 Architecture

### Core Components

- **Access Control**: Three-tier role system (DEFAULT_ADMIN, ADMIN, EMERGENCY)
- **Oracle Integration**: Chainlink price feeds for USD conversion
- **Security Layer**: ReentrancyGuard, emergency pause, and input validation
- **Storage Optimization**: Memory-first patterns with explicit state management

### Data Structures

```solidity
struct TokenInfo {
    bool isSupported;
    uint8 decimals;
    AggregatorV3Interface priceFeed;
    string symbol;
}
```

## 🔒 Security Features

### Access Control Roles

- **DEFAULT_ADMIN_ROLE**: Master control for role management
- **ADMIN_ROLE**: Token configuration and management
- **EMERGENCY_ROLE**: Crisis response and system pause capabilities

### Security Modifiers

- `whenNotPaused()`: Emergency operation control
- `validAmount()`: Zero amount validation
- `nonReentrant()`: Reentrancy attack protection
- `onlyRole()`: Role-based function restriction

### Risk Controls

- **Withdrawal Limits**: Maximum USD withdrawal per transaction
- **Bank Capacity**: Total deposit ceiling in USD
- **Oracle Validation**: Price staleness and validity checks
- **Emergency Pause**: Instant system-wide operation freeze
## 🔧 Core Functions

### Banking Operations

```solidity
// All main banking functions are protected by emergency pause
function depositETH() external payable whenNotPaused validAmount(msg.value) nonReentrant
function depositToken(address token, uint256 amount) external whenNotPaused validAmount(amount) nonReentrant  
function withdrawETH(uint256 amount) external whenNotPaused validAmount(amount) nonReentrant
function withdrawToken(address token, uint256 amount) external whenNotPaused validAmount(amount) nonReentrant
```

### Administrative Functions

- `addToken()`: Configure new supported ERC20 tokens (ADMIN_ROLE)
- `removeToken()`: Remove token support (ADMIN_ROLE)
- `emergencyPause()`: Freeze all operations (EMERGENCY_ROLE)
- `emergencyUnpause()`: Resume operations (EMERGENCY_ROLE)

### Query Functions

- `getUserBalance()`: Get user balance for specific token
- `getUserTotalBalance()`: Get total user balance in USD
- `getETHPrice()`: Current ETH price from oracle
- `getTokenPrice()`: Specific token price from oracle
- `getBankInfo()`: General bank statistics and configuration

## 📊 Events and Error Handling

### Events

The contract emits comprehensive events for complete operation traceability:

```solidity
event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
event TokenAdded(address indexed token, string symbol, uint8 decimals);
event TokenRemoved(address indexed token);
event EmergencyPauseToggled(bool paused);
```

### Custom Errors

Gas-efficient custom errors for precise debugging:

- `ZeroAmount()`: Invalid zero amount transactions
- `TokenNotSupported()`: Unsupported token operations
- `CapExceeded()`: Bank capacity limit reached
- `LimitExceeded()`: Withdrawal limit exceeded
- `LowBalance()`: Insufficient user balance
- `TransferFailed()`: ETH transfer failure
- `Paused()`: Operations paused during emergency
- `BadPriceFeed()`: Invalid oracle price data
- `StalePrice()`: Outdated oracle price (>1 hour)

## ⚡ Gas Optimization

The contract implements advanced gas optimization techniques:

- **Single Storage Read**: Each variable accessed only once per function
- **Memory-First Pattern**: Load storage to memory, modify, then write back
- **Eliminated Compound Assignments**: No `+=`, `-=`, `++`, `--` operations
- **Custom Errors**: ~50 gas savings vs require strings
- **Optimized Event Logging**: Indexed parameters for efficient filtering

### Optimization Results

- ✅ Zero compound assignment operations
- ✅ Single storage read per variable per function
- ✅ Memory-first pattern applied consistently
- ✅ Gas-efficient error handling
- ✅ Optimized event emission

## 🧪 Testing Guide

### Etherscan Interaction

1. **Access Contract**: Visit [Etherscan](https://sepolia.etherscan.io/address/0x5118780bEfEC5eBB67eaBbD0660441632577C2DA)
2. **Connect Wallet**: Ensure Sepolia testnet connection with SepoliaETH for gas
3. **Basic Operations**:
   - Deposit ETH: Use `depositETH()` with value (e.g., 0.01 ETH)
   - Check Balance: Query `getUserBalance()` with your address and token
   - Withdraw: Use `withdrawETH()` with amount in wei
   - View Stats: Call `getBankInfo()` for contract statistics

### Advanced Testing

- **Admin Functions**: Test `addToken()` and `removeToken()` (requires ADMIN_ROLE)
- **Emergency Controls**: Test `emergencyPause()` (requires EMERGENCY_ROLE)
- **Event Monitoring**: Check transaction logs for emitted events
- **Role Verification**: Use `hasRole()` to verify role assignments

## ⚙️ Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| Withdrawal Limit | 100,000 USD | Maximum withdrawal per transaction |
| Bank Capacity | 1,000,000 USD | Total deposit ceiling |
| Oracle Heartbeat | 3600 seconds | Maximum price age |
| ETH Price Feed | `0x694AA1769357215DE4FAC081bf1f309aDC325306` | Chainlink ETH/USD oracle |

## � Technology Stack

- **Solidity** 0.8.20
- **OpenZeppelin Contracts**:
  - AccessControl for role management
  - ReentrancyGuard for security
  - SafeERC20 for safe transfers
- **Chainlink Oracles** for real-time pricing
- **Remix IDE** for development and deployment

## � Module 3 Requirements Checklist

✅ **Access Control**: Multi-role system with granular permissions  
✅ **Custom Events**: Complete operation traceability with indexed parameters  
✅ **Custom Errors**: Gas-efficient error handling  
✅ **Security Modifiers**: Comprehensive protection mechanisms  
✅ **Oracle Integration**: Real-time price feeds with validation  
✅ **Gas Optimization**: Single storage read per variable per function  
✅ **Advanced Security**: ReentrancyGuard, SafeERC20, emergency controls  

---

**Developer**: Eduardo Moreno  
**Date**: October 2025  
**Status**: ✅ Production Ready

