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

## 🎓 For Instructor - Complete Testing Guide

This comprehensive testing guide allows instructors to systematically validate all contract functionalities, security measures, and Module 3 requirements.

### 📋 Prerequisites

**1. Setup Requirements:**
- MetaMask or compatible wallet connected to **Sepolia Testnet**
- Minimum **0.1 SepoliaETH** for gas fees (get from [Sepolia Faucet](https://sepoliafaucet.com/))
- Contract URL: https://sepolia.etherscan.io/address/0x5118780bEfEC5eBB67eaBbD0660441632577C2DA

**2. Access Steps:**
- Navigate to contract on Etherscan
- Click **"Contract"** tab
- Use **"Read Contract"** for queries
- Use **"Write Contract"** for transactions (requires wallet connection)

### 🔍 Phase 1: Contract State Validation (Read Functions)

**Test 1.1 - Bank Information Verification**
```
Function: getBankInfo
Expected Results:
- BANK_CAP_USD: 1000000000000 (1M USD with 6 decimals)
- WITHDRAWAL_LIMIT_USD: 100000000000 (100K USD with 6 decimals)
- emergencyPaused: false
- totalDepositedUSD: Current total deposits
- totalDeposits/totalWithdrawals: Transaction counters
```

**Test 1.2 - Oracle Price Validation**
```
Function: getETHPrice
Expected: Current ETH price in USD (6 decimals)
Validation: Price should be > 0 and reasonable (e.g., 1500-4000 USD)

Function: getTokenPrice
Parameters: token = 0x0000000000000000000000000000000000000000 (ETH)
Expected: Same as getETHPrice()
```

**Test 1.3 - Role Verification**
```
Function: hasRole
Test DEFAULT_ADMIN_ROLE:
- role: 0x0000000000000000000000000000000000000000000000000000000000000000
- account: [contract_deployer_address]
Expected: true

Test ADMIN_ROLE:
- role: 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775
- account: [contract_deployer_address]
Expected: true

Test EMERGENCY_ROLE:
- role: 0x5d8e12c39142ff96d79d04d15d1a04f37fa897a2281a8b32e60d024948bac3ee
- account: [contract_deployer_address]
Expected: true
```

### 💰 Phase 2: Core Banking Operations

**Test 2.1 - ETH Deposit (Basic Flow)**
```
Function: depositETH
Value: 0.01 ETH (0.01 in Value field)
Gas Limit: 150,000

Success Criteria:
✅ Transaction succeeds
✅ Event 'Deposit' emitted with correct parameters
✅ getUserBalance shows new ETH balance
✅ getUserTotalBalance reflects USD value
✅ getBankInfo shows incremented totalDeposits and totalDepositedUSD
```

**Test 2.2 - Balance Verification**
```
Function: getUserBalance
Parameters:
- user: [your_wallet_address]
- token: 0x0000000000000000000000000000000000000000
Expected: Shows deposited ETH amount in wei
```

**Test 2.3 - USD Conversion Verification**
```
Function: convertToUSD
Parameters:
- token: 0x0000000000000000000000000000000000000000
- amount: [deposited_amount_in_wei]
Expected: USD value matching the deposit event
```

**Test 2.4 - ETH Withdrawal**
```
Function: withdrawETH
Parameters:
- amount: [50% of deposited amount in wei]
Gas Limit: 120,000

Success Criteria:
✅ Transaction succeeds
✅ Event 'Withdrawal' emitted
✅ getUserBalance reflects reduced balance
✅ ETH received in wallet
✅ getBankInfo shows incremented totalWithdrawals
```

### 🛡️ Phase 3: Security and Error Handling

**Test 3.1 - Zero Amount Validation**
```
Function: depositETH
Value: 0 ETH
Expected: Transaction FAILS with 'ZeroAmount' error
```

**Test 3.2 - Insufficient Balance Test**
```
Function: withdrawETH
Parameters:
- amount: [more than user balance]
Expected: Transaction FAILS with 'LowBalance' error
```

**Test 3.3 - Withdrawal Limit Test**
```
Function: withdrawETH
Parameters:
- amount: [equivalent to >$100,000 USD in wei]
Expected: Transaction FAILS with 'LimitExceeded' error
```

**Test 3.4 - Minimum Deposit Test**
```
Function: depositETH
Value: 0.0001 ETH (very small amount)
Expected: May fail if USD value < $1.00 minimum
```

### 🔧 Phase 4: Administrative Functions (Role-Based)

**Test 4.1 - Emergency Pause (EMERGENCY_ROLE required)**
```
Function: emergencyPause
Prerequisites: Must have EMERGENCY_ROLE
Expected Results:
✅ emergencyPaused becomes true
✅ Event 'EmergencyPauseToggled(true)' emitted
```

**Test 4.2 - Operations During Pause**
```
Function: depositETH
Value: 0.01 ETH
Expected: Transaction FAILS with 'Paused' error
```

**Test 4.3 - Emergency Unpause**
```
Function: emergencyUnpause
Expected Results:
✅ emergencyPaused becomes false
✅ Event 'EmergencyPauseToggled(false)' emitted
✅ Normal operations resume
```

**Test 4.4 - Unauthorized Access Test**
```
Function: emergencyPause (from non-EMERGENCY_ROLE account)
Expected: Transaction FAILS with AccessControl error
```

### 📊 Phase 5: Event and Log Verification

**For each transaction, verify in the "Logs" tab:**

**Deposit Event Structure:**
```
Event: Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance)
Validation:
- user: correct wallet address
- token: 0x0000000000000000000000000000000000000000 (for ETH)
- amount: deposited amount in wei
- usdValue: USD equivalent (6 decimals)
- newBalance: updated user balance
```

**Withdrawal Event Structure:**
```
Event: Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance)
Validation: Similar to Deposit with withdrawal data
```

### 🧪 Phase 6: Advanced Testing Scenarios

**Test 6.1 - Price Feed Staleness (Advanced)**
```
Note: This test requires waiting >1 hour or using a stale price feed
Expected: Functions should fail with 'StalePrice' error if oracle data is old
```

**Test 6.2 - Gas Optimization Verification**
```
Compare gas usage:
- depositETH: Should use ~120,000-150,000 gas
- withdrawETH: Should use ~100,000-120,000 gas
- Read functions: Should use minimal gas (<50,000)
```

**Test 6.3 - Reentrancy Protection**
```
Note: Advanced test requiring custom contract
Verify: nonReentrant modifier prevents reentrancy attacks
```

### 📋 Phase 7: Module 3 Requirements Validation

**Checklist for Instructor:**

✅ **Access Control Implementation:**
- [ ] Three distinct roles defined and functional
- [ ] Role-based function restrictions working
- [ ] Unauthorized access properly blocked

✅ **Custom Events:**
- [ ] All operations emit appropriate events
- [ ] Events contain indexed parameters for filtering
- [ ] Event data matches transaction results

✅ **Custom Errors:**
- [ ] Gas-efficient error handling (no require strings)
- [ ] Specific errors for different failure modes
- [ ] Proper error messages in failed transactions

✅ **Security Modifiers:**
- [ ] whenNotPaused prevents operations during emergency
- [ ] validAmount blocks zero amounts
- [ ] nonReentrant protects against reentrancy
- [ ] onlyRole restricts administrative functions

✅ **Oracle Integration:**
- [ ] Real-time price feeds functional
- [ ] Staleness validation working
- [ ] USD conversion accuracy

✅ **Gas Optimization:**
- [ ] Single storage read per variable per function
- [ ] No compound assignment operations
- [ ] Memory-first patterns implemented

### 🎯 Expected Test Results Summary

**Successful Operations Should Show:**
- ✅ Clean transaction execution
- ✅ Appropriate events emitted
- ✅ Accurate balance updates
- ✅ Proper USD conversions
- ✅ Gas usage within expected ranges

**Security Tests Should Demonstrate:**
- ✅ Error handling for invalid inputs
- ✅ Access control enforcement
- ✅ Emergency pause functionality
- ✅ Limit enforcement

**This comprehensive testing validates all Module 3 requirements and demonstrates production-ready smart contract security and efficiency.**

## 🧪 Basic Testing Guide

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

