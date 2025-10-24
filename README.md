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

#### **How Access Control is Used Throughout the Contract:**

#### **1. ADMIN_ROLE - Token Management Authority**

**Functions Protected:**
- **`addToken(address token, string memory symbol, uint8 decimals, address priceFeed)`** - Line 490
- **`removeToken(address token)`** - Line 499

**Where Used:** Token configuration management
**Why Needed:** 
- **Financial Security:** Only trusted administrators can add new tokens to prevent malicious tokens
- **Oracle Security:** Each token requires a validated Chainlink price feed - wrong feeds could manipulate prices
- **System Integrity:** Prevents unauthorized expansion of supported assets

**Implementation:**
```solidity
function addToken(address token, string memory symbol, uint8 decimals, address priceFeed) 
    external onlyRole(ADMIN_ROLE) 
{
    supportedTokens[token] = TokenInfo({
        isSupported: true,
        decimals: decimals,
        priceFeed: AggregatorV3Interface(priceFeed),
        symbol: symbol
    });
}
```

**Critical Impact:** Without this control, anyone could add fake tokens or manipulate price feeds

#### **2. EMERGENCY_ROLE - Crisis Management Authority**

**Functions Protected:**
- **`emergencyPause()`** - Line 505  
- **`emergencyUnpause()`** - Line 510

**Where Used:** System-wide operation control
**Why Needed:**
- **Immediate Response:** Quick reaction to security threats or oracle failures
- **User Protection:** Prevent deposits/withdrawals during critical issues
- **Damage Limitation:** Stop operations before major losses occur
- **Regulatory Compliance:** Meet emergency stop requirements

**Implementation:**
```solidity
function emergencyPause() external onlyRole(EMERGENCY_ROLE) {
    emergencyPaused = true;
    emit EmergencyPauseToggled(true);
}
```

**Critical Impact:** The `whenNotPaused` modifier on `depositETH`, `depositToken`, `withdrawETH`, `withdrawToken` means this role can instantly freeze all banking operations

#### **3. DEFAULT_ADMIN_ROLE - Master Control Authority**

**Where Used:** Role management and contract administration
**Why Needed:**
- **Role Assignment:** Can grant/revoke ADMIN_ROLE and EMERGENCY_ROLE  
- **Access Hierarchy:** Supreme authority over all contract permissions
- **Recovery Mechanism:** Can restore access if other roles are compromised

**Functions Affected:** All `grantRole()`, `revokeRole()` operations

#### **Access Control Integration with Core Functions:**

**Protected User Functions:**
```solidity
// All main banking functions are protected by emergency pause
function depositETH() external payable whenNotPaused validAmount(msg.value) nonReentrant
function depositToken(address token, uint256 amount) external whenNotPaused validAmount(amount) nonReentrant  
function withdrawETH(uint256 amount) external whenNotPaused validAmount(amount) nonReentrant
function withdrawToken(address token, uint256 amount) external whenNotPaused validAmount(amount) nonReentrant
```

**Why This Design:**
- **EMERGENCY_ROLE** can instantly freeze all user operations via `emergencyPause()`
- **Normal users** have NO special roles - they use public functions with safety checks
- **Token validity** is enforced through ADMIN_ROLE-managed `supportedTokens` mapping

#### **Security Architecture Benefits:**
1. **Separation of Concerns:** Different roles for different responsibilities
2. **Principle of Least Privilege:** Each role has minimal required permissions  
3. **Emergency Response:** Instant system freeze capability
4. **Upgradeable Security:** Role assignment can be modified by DEFAULT_ADMIN_ROLE

#### **Initial Role Configuration:**
```solidity
constructor(uint256 _withdrawalLimitUSD, uint256 _bankCapUSD, address _ethUsdPriceFeed) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);  // Master control
    _grantRole(ADMIN_ROLE, msg.sender);          // Token management  
    _grantRole(EMERGENCY_ROLE, msg.sender);      // Crisis response
}
```

**Deployment Security:** All roles initially assigned to deployer, can be redistributed to specialized addresses later

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

### ⚡ **Critical Gas Optimizations Applied**

#### **Storage Access Optimization:**
The contract has been **critically optimized** to eliminate multiple storage access patterns:

**❌ BEFORE (Problematic):**
```solidity
// Multiple storage access - INEFFICIENT
userTotalBalanceUSD[msg.sender] += usdValue;  // READ + WRITE = 2 accesses
totalDeposits++;                              // READ + WRITE = 2 accesses
```

**✅ AFTER (Optimized):**
```solidity
// Single storage access - EFFICIENT
uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];    // 1 READ
uint256 currentTotalDeposits = totalDeposits;                 // 1 read
userTotalBalanceUSD[msg.sender] = currentUserTotal + usdValue; // 1 write
totalDeposits = currentTotalDeposits + 1;                     // 1 write
```

#### **Optimization Results:**
- ✅ **Zero `+=` operations** - All converted to explicit read/write
- ✅ **Zero `-=` operations** - All converted to explicit read/write  
- ✅ **Zero `++` operations** - All converted to explicit read/write
- ✅ **Zero `--` operations** - All converted to explicit read/write
- ✅ **Single storage read** per variable per function
- ✅ **Memory-first pattern** applied consistently

#### **Functions Optimized:**
1. **`depositToken()`** - Eliminated 4 multiple access patterns
2. **`withdrawToken()`** - Eliminated 6 multiple access patterns
3. **All functions** now follow "one read per storage variable" rule

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

✅ **Access Control:** ADMIN_ROLE and EMERGENCY_ROLE roles with granular permissions  
✅ **Custom Events:** 5 specific events with indexed parameters for observability  
✅ **Custom Errors:** 9 specific errors for debugging and gas efficiency  
✅ **Security Modifiers:** 4 modifiers (whenNotPaused, validAmount, nonReentrant, onlyRole)  
✅ **Oracle Integration:** Chainlink price feeds with staleness validation  
✅ **CRITICAL Gas Optimization:** Single storage read per variable per function ⚡  
✅ **Storage Access Patterns:** Zero `+=`, `-=`, `++`, `--` operations  
✅ **Advanced Security:** ReentrancyGuard, SafeERC20, CEI pattern, emergency pauses  
✅ **Scalable Architecture:** Configurable multi-token support with metadata  

### 🎯 **Critical Requirements Met:**
- ❌ **No Long Strings:** Only custom errors used (gas efficient)
- ❌ **No Multiple Storage Access:** Each variable read only once per function
- ✅ **Production Ready:** Passes all Module 3 optimization criteria  

---

**Developed by:** Eduardo Moreno  
**Date:** October 2025  
**Module:** 3 - Advanced Solidity Development  
**Status:** ✅ Completed and Verified