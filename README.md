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
- **Status:** ✅ Verified and Deployed (Optimized Version)

## 🎯 Project Description

KipuBankV2 is a decentralized banking system developed following **Module 3** concepts of the Solidity course. The contract enables ETH and ERC20 token deposits and withdrawals with automatic USD conversion using Chainlink oracles, role-based access control, and advanced security features.

> **⚡ OPTIMIZATION NOTE:** This contract has been fully optimized to eliminate multiple storage access patterns. Each function performs only **one read per storage variable**, following Module 3 gas optimization best practices.

---

## 📝 For Instructor - Module 3 Technical Analysis

### 🔐 **Access Control Implementation**

The contract implements **OpenZeppelin's AccessControl** with three specific roles:

#### **Defined Roles:**
```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
// DEFAULT_ADMIN_ROLE inherited from AccessControl
```

#### **Administrative Functions:**

1. **`addToken()`** - Line 490
   - **Required Role:** `ADMIN_ROLE`
   - **Purpose:** Add new supported ERC20 tokens
   - **Why:** Only administrators can expand accepted tokens
   ```solidity
   function addToken(address token, string memory symbol, uint8 decimals, address priceFeed) 
       external onlyRole(ADMIN_ROLE)
   ```

2. **`removeToken()`** - Line 499
   - **Required Role:** `ADMIN_ROLE`
   - **Purpose:** Remove tokens from the system
   - **Why:** Administrative control for obsolete or problematic tokens

3. **`emergencyPause()`** - Line 505
   - **Required Role:** `EMERGENCY_ROLE`
   - **Purpose:** Pause contract during emergencies
   - **Why:** Critical security requires specialized role

4. **`emergencyUnpause()`** - Line 510
   - **Required Role:** `EMERGENCY_ROLE`
   - **Purpose:** Resume operations after emergency

#### **Initial Role Configuration:**
```solidity
constructor(uint256 _withdrawalLimitUSD, uint256 _bankCapUSD, address _ethUsdPriceFeed) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(ADMIN_ROLE, msg.sender);
    _grantRole(EMERGENCY_ROLE, msg.sender);
}
```

### 🚨 **Events and Error Handling**

#### **Custom Events:**
```solidity
event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
event TokenAdded(address indexed token, string symbol, uint8 decimals);
event TokenRemoved(address indexed token);
event EmergencyPauseToggled(bool paused);
```

**Purpose:** Complete operation traceability, auditing, and observability.

#### **Custom Errors:**
```solidity
error ZeroAmount();           // Prevents operations with invalid amounts
error TokenNotSupported();    // Unauthorized token
error CapExceeded();         // Deposit limit exceeded
error LimitExceeded();       // Withdrawal limit exceeded
error LowBalance();          // Insufficient balance
error TransferFailed();      // ETH transfer failure
error Paused();              // Contract paused
error BadPriceFeed();        // Invalid oracle price
error StalePrice();          // Outdated price
```

**Advantages:**
- **Gas Efficient:** Custom errors vs strings
- **Clarity:** Specific for each failure case
- **Debugging:** Precise problem identification

---

## 🏗️ Module 3 Architecture and Functionalities

### 📊 **1. Data Structures**
```solidity
struct TokenInfo {
    bool isSupported;
    uint8 decimals;
    AggregatorV3Interface priceFeed;
    string symbol;
}
```

### 🔒 **2. Security Modifiers**
- **`whenNotPaused()`:** Prevents operations during emergencies
- **`validAmount(uint256 amount)`:** Validates amounts greater than zero
- **`nonReentrant()`:** Protection against reentrancy attacks
- **`onlyRole(bytes32 role)`:** Role-based access control

### 💰 **3. Main Functions**

#### **Deposits:**
- `depositETH()` - Native Ether deposit
- `depositToken(address token, uint256 amount)` - ERC20 token deposit

#### **Withdrawals:**
- `withdrawETH(uint256 amount)` - Ether withdrawal
- `withdrawToken(address token, uint256 amount)` - ERC20 token withdrawal

#### **Queries:**
- `getUserBalance(address user, address token)` - Individual balance per token
- `getUserTotalBalance(address user)` - Total balance in USD
- `getETHPrice()` - Current ETH price in USD
- `getTokenPrice(address token)` - Specific token price
- `convertToUSD(address token, uint256 amount)` - USD conversion
- `getBankInfo()` - General bank statistics

### 🔗 **4. Oracle Integration**
- **Chainlink Price Feeds** for real-time USD conversion
- **Staleness validation** (maximum 1 hour old)
- **Price verification** (greater than zero)

### 🛡️ **5. Security Measures**
- **ReentrancyGuard:** Prevents reentrancy attacks
- **SafeERC20:** Safe token transfers
- **Emergency pause:** Stops critical operations
- **Configurable limits:** Risk control

---

## 🧪 For Instructor - How to Test on Etherscan

### **Step 1: Access the Contract**
1. Go to: https://sepolia.etherscan.io/address/0x5118780bEfEC5eBB67eaBbD0660441632577C2DA
2. Click on **"Contract"** tab
3. Select **"Write Contract"** to execute functions

### **Step 2: Connect Wallet**
1. Click **"Connect to Web3"**
2. Select MetaMask or other wallet
3. Ensure you're on **Sepolia Testnet**
4. Have **SepoliaETH** for gas fees

### **Step 3: Basic Tests**

#### **A) Test ETH Deposit:**
```
Function: depositETH
Value (ETH): 0.01
Gas Limit: 150000
```

#### **B) Query Balance:**
```
Function: getUserBalance (Read Contract)
user: [your_address]
token: 0x0000000000000000000000000000000000000000
```

#### **C) Test Withdrawal:**
```
Function: withdrawETH
amount: 5000000000000000 (0.005 ETH in Wei)
```

#### **D) View Bank Information:**
```
Function: getBankInfo (Read Contract)
- Returns: totalDepositedUSD, totalDeposits, totalWithdrawals, BANK_CAP_USD, WITHDRAWAL_LIMIT_USD, emergencyPaused
```

### **Step 4: Advanced Tests**

#### **A) Access Control (Admin Only):**
```
Function: addToken
token: [ERC20_token_address]
symbol: "USDC"
decimals: 6
priceFeed: [chainlink_usdc_usd_address]
```

#### **B) Emergency Functions:**
```
Function: emergencyPause
(Only EMERGENCY_ROLE)
```

#### **C) Verify Events:**
1. Go to **"Logs"** in the transaction
2. Verify `Deposit`, `Withdrawal`, etc. events

### **Step 5: Monitoring and Debugging**

#### **View Contract State:**
- **Read Contract** → `getBankInfo()`
- **Read Contract** → `getETHPrice()`
- **Read Contract** → `emergencyPaused()`

#### **Verify Roles:**
- **Read Contract** → `hasRole(ADMIN_ROLE, [address])`
- **Read Contract** → `hasRole(EMERGENCY_ROLE, [address])`

---

## 📊 Configuration Parameters

- **Withdrawal Limit:** 100,000 USD (100000000000 wei)
- **Bank Capacity:** 1,000,000 USD (1000000000000 wei)
- **Minimum Deposit:** 1 USD
- **Oracle Heartbeat:** 3600 seconds (1 hour)
- **ETH/USD Price Feed:** `0x694AA1769357215DE4FAC081bf1f309aDC325306`

## 🔧 Technologies Used

- **Solidity** 0.8.20
- **OpenZeppelin Contracts:**
  - AccessControl (Role management)
  - ReentrancyGuard (Anti-reentrancy security)  
  - SafeERC20 (Safe transfers)
- **Chainlink Oracles** (Real-time pricing)
- **Remix IDE** (Development and deployment)

## 📈 Contract Statistics

- **Gas Optimized:** Single storage read per variable per function ⚡
- **Zero Multiple Access:** Eliminated all `+=`, `-=`, `++`, `--` operations
- **Complete Events:** Full operation traceability with indexed parameters
- **Custom Errors:** Higher gas efficiency vs require strings
- **Production Ready:** Passed all Module 3 critical requirements
- **Modular Architecture:** Easy maintenance and updates

## 🎓 Module 3 Concepts Applied

✅ **Access Control:** ADMIN_ROLE and EMERGENCY_ROLE roles  
✅ **Custom Events:** 5 specific events for observability  
✅ **Custom Errors:** 9 specific errors for debugging  
✅ **Modifiers:** 4 security and validation modifiers  
✅ **Oracle Integration:** Chainlink for real-time pricing  
✅ **Gas Optimization:** Single storage reads, custom errors  
✅ **Advanced Security:** ReentrancyGuard, SafeERC20, emergency pauses  
✅ **Scalable Architecture:** Configurable multi-token support  

---

**Developed by:** Eduardo Moreno  
**Date:** October 2025  
**Module:** 3 - Advanced Solidity Development  
**Status:** ✅ Completed and Verified