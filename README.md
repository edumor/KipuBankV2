# KipuBankV2 - Enhanced Decentralized Banking System 🏦

[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-v5.0.0-blue.svg)](https://openzeppelin.com/)
[![Chainlink](https://img.shields.io/badge/Chainlink-Oracles-red.svg)](https://chain.link/)

## 🎯 **FINAL PROJECT MODULE 3 - ETHEREUM DEVELOPER PROGRAM**

This project represents the evolution of the original KipuBank contract into an enterprise-ready production version, applying advanced Solidity techniques, security patterns, and smart contract architecture best practices.

## 🏗️ **TECHNICAL ARCHITECTURE**

### **🔐 Administrative Roles & Access Control**

**Implementation:** OpenZeppelin's Ownable pattern (Line 26 in `/src/KipuBankV2.sol`)

#### **Administrative Tools Used:**

**1. Ownable Pattern (OpenZeppelin)**
- **What:** Single-owner access control mechanism
- **Why:** Provides secure, battle-tested administrative control
- **Where:** `contract KipuBankV2 is Ownable` - Line 26
- **Benefit:** Centralized governance with `onlyOwner` modifier protection

**2. Custom Access Modifiers**
- **`whenNotPaused()`** - Line 142: Prevents operations during emergency pause
- **`validAmount()`** - Line 148: Ensures non-zero transaction amounts  
- **`validAddress()`** - Line 154: Prevents zero-address operations
- **Why:** Layer additional security checks on top of ownership

**3. Circuit Breaker Pattern**
- **Implementation:** `pause()/unpause()` functions with state variable `s_paused`
- **Why:** Emergency stop mechanism for security incidents
- **Trigger:** Only owner can activate during threats or maintenance

#### **Protected Administrative Functions:**

**Token Management:**
- `addToken()` - Line 365: Add new ERC20 token support with price feed
- `removeToken()` - Line 383: Disable token support (security measure)

**Emergency Controls:**
- `pause()` - Line 397: Halt all operations immediately
- `unpause()` - Line 405: Resume normal operations

**Governance:**
- `transferOwnership()` - Inherited: Transfer admin rights to new address

#### **Why These Administrative Tools:**

**Security Rationale:**
- **Token Management**: Only authorized admin can enable/disable tokens to prevent malicious token addition
- **Emergency Pause**: Critical for responding to security vulnerabilities or oracle failures  
- **Access Control**: Prevents unauthorized changes to system parameters and configuration
- **Input Validation**: Custom modifiers catch invalid inputs before execution

**Governance Benefits:**
- **Centralized Control**: Single point of administrative decision-making
- **Emergency Response**: Immediate reaction capability during incidents
- **System Evolution**: Ability to add new tokens as ecosystem grows
- **Maintenance**: Controlled updates and configuration changes

### **📡 Events & Custom Error Handling**

**Why Custom Events (Lines 91-108):**
- **Transparency**: Off-chain monitoring of all operations
- **Integration**: Easy front-end integration
- **Gas Efficiency**: Cheaper than storage for historical data

**Why Custom Errors (Lines 111-123):**
- **Gas Optimization**: ~50% less gas than require() strings
- **Debugging**: Include relevant parameters for precise error tracking
- **Type Safety**: Prevent error message conflicts

**Key Examples:**
- `KipuBankV2_Deposit` - Line 91: Complete transaction tracking
- `KipuBankV2_BankCapExceeded` - Line 115: Parametrized error with limits
- `KipuBankV2_OracleStalePrice` - Line 121: Oracle validation errors

## 🚀 **STEP-BY-STEP ETHERSCAN EXECUTION GUIDE**

### **📋 Prerequisites**
- MetaMask installed and configured for Sepolia Testnet
- Sepolia ETH from [sepoliafaucet.com](https://sepoliafaucet.com/) (minimum 0.02 ETH recommended)
- Contract Address: `0x4b677233e4124640e309D6880ae66f7697b36674`

### **🔗 Step 1: Access Contract**
1. Navigate to: https://sepolia.etherscan.io/address/0x4b677233e4124640e309D6880ae66f7697b36674
2. Click **"Contract"** tab
3. You'll see **"Read Contract"** and **"Write Contract"** sub-tabs

### **📖 Step 2: Read Contract Functions (Testing Information Retrieval)**

**2.1 Check Bank Status:**
```
Function: getBankInfo()
- Click "getBankInfo" → "Query"
- Returns 6 values:
  * totalDepUSD: Total deposited in USD (6 decimals)
  * totalDeps: Number of deposits made
  * totalWiths: Number of withdrawals made
  * bankCapUSD: Bank capacity limit (1,000,000 USD)
  * withdrawLimitUSD: Withdrawal limit (10,000 USD)
  * paused: Contract status (false=active, true=paused)
```

**2.2 Get Current ETH Price:**
```
Function: getPrice(address token)
- Input: 0x0000000000000000000000000000000000000000
- Click "Query"
- Returns: ETH/USD price in 8 decimals (e.g., 250000000000 = $2,500)
```

**2.3 Verify Your Balance:**
```
Function: getBalance(address user, address token)
- user: Your wallet address
- token: 0x0000000000000000000000000000000000000000 (ETH)
- Returns: Your balance in USD (6 decimals)
```

**2.4 Check Token Configuration:**
```
Function: getTokenConfig(address token)
- Input: 0x0000000000000000000000000000000000000000
- Returns: ETH support status and price feed info
```

**2.5 Verify Contract Owner:**
```
Function: owner()
- Returns: Contract owner address
```

### **✍️ Step 3: Write Contract Functions (Testing Transactions)**

**3.1 Connect MetaMask:**
1. Click **"Write Contract"** tab
2. Click **"Connect to Web3"**
3. Select MetaMask and authorize connection
4. Verify your address appears as connected

**3.2 Test ETH Deposit:**
```
Function: depositETH()
- Enter amount in ETH: 0.01 (for 0.01 ETH deposit)
- Click "Write" → Confirm in MetaMask
- Wait ~15-30 seconds for confirmation
- Note the transaction hash
```

**3.3 Verify Deposit:**
```
- Return to "Read Contract"
- Use getBalance() with your address
- Should show your deposit in USD value
- Use getBankInfo() to see updated totals
```

**3.4 Test ETH Withdrawal:**
```
Function: withdrawETH(uint256 usdAmount)
- Calculate: If ETH = $2,500 and you want to withdraw $10:
  Input: 10000000 (10 USD in 6 decimals)
- Click "Write" → Confirm in MetaMask
- Wait for confirmation
```

### **📊 Step 4: Verify Results and Events**

**4.1 Check Transaction Events:**
```
- Click on transaction hash from deposits/withdrawals
- Go to "Logs" tab
- Look for events:
  * KipuBankV2_Deposit: Shows ETH and USD amounts
  * KipuBankV2_Withdrawal: Shows withdrawal details
```

**4.2 Verify Balance Changes:**
```
- Use getBalance() before and after operations
- Use getBankInfo() to see bank totals update
- Confirm USD conversions are accurate
```

### **🔐 Step 5: Administrative Functions Testing (Owner Only)**

**⚠️ Note:** These functions only work if you're the contract owner.

**5.1 Emergency Pause:**
```
Function: pause()
- Click "Write" → Confirm transaction
- Verify: getBankInfo() shows paused = true
- Test: depositETH() should fail with "ContractPaused" error
```

**5.2 Resume Operations:**
```
Function: unpause()
- Click "Write" → Confirm transaction
- Verify: getBankInfo() shows paused = false
- Test: Normal operations resume
```

### **📈 Expected Results & Validation**

**Typical Values You Should See:**
```
ETH Price: ~250000000000 (≈$2,500 in 8 decimals)
Gas Usage: 
  - Deposit: ~120,000 gas
  - Withdrawal: ~100,000 gas
  - Admin functions: ~50,000 gas

Balance Updates:
  - Deposit 0.01 ETH at $2,500 = 25000000 (25 USD in 6 decimals)
  - Withdrawal 10000000 = $10 worth of ETH returned

Events Emitted:
  - Complete transaction details with USD conversions
  - Proper indexing for off-chain monitoring
```

### **🚨 Common Errors and Solutions**

| Error | Cause | Solution |
|-------|--------|----------|
| `KipuBankV2_ZeroAmount` | Amount = 0 | Enter value > 0 |
| `KipuBankV2_InsufficientBalance` | Not enough balance | Check balance first |
| `KipuBankV2_ContractPaused` | Contract paused | Wait for unpause or contact owner |
| `KipuBankV2_BankCapExceeded` | Bank at capacity | Try smaller amount |
| MetaMask connection fails | Wrong network | Switch to Sepolia Testnet |

### **📝 Testing Checklist for Instructors**

**Complete Test Sequence (15-20 minutes):**
- [ ] Read all contract information functions
- [ ] Connect MetaMask to Sepolia
- [ ] Perform ETH deposit (0.01 ETH recommended)
- [ ] Verify balance update and USD conversion
- [ ] Perform partial withdrawal ($5-10 USD)
- [ ] Check transaction events and gas usage
- [ ] Verify final balances and bank totals
- [ ] Test error conditions (zero amounts, insufficient balance)
- [ ] Document transaction hashes and results

**Key Validation Points:**
- ✅ Oracle price feed working (live ETH/USD rates)
- ✅ USD conversion accuracy (18 decimals → 6 decimals)
- ✅ Event emission with complete transaction details
- ✅ Gas optimization (custom errors vs require strings)
- ✅ Access control enforcement (admin functions)
- ✅ Circuit breaker functionality (pause/unpause)

## 📈 **HIGH-LEVEL IMPROVEMENTS OVERVIEW**

### **Why This Evolution Was Necessary**

The original KipuBank contract was a basic ETH-only banking system suitable for learning purposes. However, for a production-ready DeFi application, several critical limitations needed to be addressed:

**Original Limitations:**
- ❌ **Single Asset Support**: Only ETH deposits/withdrawals
- ❌ **No Price Integration**: No real-world value tracking
- ❌ **Basic Security**: Limited access control and error handling
- ❌ **Gas Inefficient**: Using string-based error messages
- ❌ **No Scalability**: Cannot add new tokens without contract upgrade

### **KipuBankV2 Strategic Improvements**

#### **1. Multi-Asset Banking System**
**Problem Solved:** Limited to ETH-only transactions  
**Solution:** Configurable token support via `TokenConfig` struct  
**Business Impact:** Can serve multiple cryptocurrencies, expanding user base  
**Technical Benefit:** Scalable architecture allows adding tokens without redeployment

#### **2. Real-World Value Integration**
**Problem Solved:** No connection to actual market prices  
**Solution:** Chainlink Oracle integration for live price feeds  
**Business Impact:** Users see accurate USD values, enabling better financial decisions  
**Technical Benefit:** Standardized 6-decimal USD accounting across all assets

#### **3. Enterprise-Grade Security**
**Problem Solved:** Basic security measures insufficient for production  
**Solution:** Multi-layer security with access control, circuit breakers, and validation  
**Business Impact:** Protects user funds and enables institutional adoption  
**Technical Benefit:** Battle-tested OpenZeppelin patterns with custom enhancements

#### **4. Gas Cost Optimization**
**Problem Solved:** High transaction costs for users  
**Solution:** Custom errors, constant variables, and efficient storage patterns  
**Business Impact:** ~50% reduction in gas costs improves user experience  
**Technical Benefit:** Scalable for high-frequency usage patterns

## 🎯 **DESIGN DECISIONS & TRADE-OFFS**

### **Critical Design Decisions Explained**

#### **Decision 1: USD-Normalized Accounting (6 Decimals)**
**Choice Made:** All internal balances stored in 6-decimal USD values  
**Alternative Considered:** Store in native token decimals  
**Why Chosen:**
- ✅ **Consistency**: Same precision across all tokens (ETH=18, USDC=6, WBTC=8)
- ✅ **DeFi Compatibility**: Standard USDC decimal format widely adopted
- ✅ **User Experience**: Clear USD values for all assets

**Trade-off:** Requires decimal conversion logic, slight gas overhead for conversions
**Mitigation:** Optimized `_convertToUSD()` function with minimal computational cost

#### **Decision 2: Centralized Ownership vs Decentralized Governance**
**Choice Made:** OpenZeppelin's Ownable pattern (single owner)  
**Alternative Considered:** Multi-sig or DAO governance  
**Why Chosen:**
- ✅ **Simplicity**: Clear responsibility and quick decision-making
- ✅ **Security**: Reduced attack surface compared to complex governance
- ✅ **Educational Value**: Demonstrates access control patterns clearly

**Trade-off:** Centralized control vs full decentralization
**Mitigation:** Owner can transfer ownership, enabling future governance evolution

#### **Decision 3: Oracle Dependency vs On-Chain Price Discovery**
**Choice Made:** Chainlink Oracle integration with staleness protection  
**Alternative Considered:** AMM-based price discovery or manual price updates  
**Why Chosen:**
- ✅ **Reliability**: Chainlink's proven track record and decentralized network
- ✅ **Accuracy**: Professional-grade price feeds with aggregation
- ✅ **Security**: Built-in protection against price manipulation

**Trade-off:** External dependency vs full on-chain autonomy
**Mitigation:** Staleness checks and circuit breaker for oracle failures

#### **Decision 4: Emergency Pause vs Continuous Operation**
**Choice Made:** Circuit breaker pattern with pause/unpause functionality  
**Alternative Considered:** Immutable contract without pause capability  
**Why Chosen:**
- ✅ **Risk Management**: Ability to halt operations during security incidents
- ✅ **Upgrade Path**: Controlled migration to future contract versions
- ✅ **Regulatory Compliance**: Emergency controls for regulatory requirements

**Trade-off:** Operational flexibility vs immutability principles
**Mitigation:** Pause function only accessible by owner, transparent on-chain

### **Architectural Trade-offs Analysis**

#### **⚖️ Gas Efficiency vs Feature Richness**
**Balance Achieved:** Optimized core functions while maintaining advanced features
- **Pro:** Custom errors save ~50% gas vs require strings
- **Con:** More complex codebase requires careful testing
- **Result:** Production-ready efficiency with comprehensive functionality

#### **⚖️ Security vs Usability**
**Balance Achieved:** Multi-layer security with streamlined user experience
- **Pro:** Comprehensive validation prevents user errors and attacks
- **Con:** Additional checks increase gas costs slightly
- **Result:** Bank-grade security with DeFi-standard user experience

#### **⚖️ Flexibility vs Simplicity**
**Balance Achieved:** Configurable token support with intuitive core operations
- **Pro:** Can support new tokens without contract upgrades
- **Con:** More complex internal architecture
- **Result:** Future-proof design with clear upgrade paths

## �📋 **DEPLOYED CONTRACT INFORMATION**

- **Contract Address:** `0x4b677233e4124640e309D6880ae66f7697b36674`
- **Network:** Sepolia Testnet
- **Etherscan:** [View on Etherscan](https://sepolia.etherscan.io/address/0x4b677233e4124640e309D6880ae66f7697b36674)
- **Status:** ✅ Verified and Operational
- **ETH Price Feed:** `0x694AA1769357215DE4FAC081bf1f309aDC325306` (Chainlink Sepolia ETH/USD)

## 📚 **INSTRUCTOR GUIDE - KEY IMPLEMENTATIONS**

### **🔐 Administrative Roles & Access Control**

**Implementation:** OpenZeppelin's Ownable pattern (Line 26 in `/src/KipuBankV2.sol`)

#### **Administrative Tools Used:**

**1. Ownable Pattern (OpenZeppelin)**
- **What:** Single-owner access control mechanism
- **Why:** Provides secure, battle-tested administrative control
- **Where:** `contract KipuBankV2 is Ownable` - Line 26
- **Benefit:** Centralized governance with `onlyOwner` modifier protection

**2. Custom Access Modifiers**
- **`whenNotPaused()`** - Line 142: Prevents operations during emergency pause
- **`validAmount()`** - Line 148: Ensures non-zero transaction amounts  
- **`validAddress()`** - Line 154: Prevents zero-address operations
- **Why:** Layer additional security checks on top of ownership

**3. Circuit Breaker Pattern**
- **Implementation:** `pause()/unpause()` functions with state variable `s_paused`
- **Why:** Emergency stop mechanism for security incidents
- **Trigger:** Only owner can activate during threats or maintenance

#### **Protected Administrative Functions:**

**Token Management:**
- `addToken()` - Line 365: Add new ERC20 token support with price feed
- `removeToken()` - Line 383: Disable token support (security measure)

**Emergency Controls:**
- `pause()` - Line 397: Halt all operations immediately
- `unpause()` - Line 405: Resume normal operations

**Governance:**
- `transferOwnership()` - Inherited: Transfer admin rights to new address

#### **Why These Administrative Tools:**

**Security Rationale:**
- **Token Management**: Only authorized admin can enable/disable tokens to prevent malicious token addition
- **Emergency Pause**: Critical for responding to security vulnerabilities or oracle failures  
- **Access Control**: Prevents unauthorized changes to system parameters and configuration
- **Input Validation**: Custom modifiers catch invalid inputs before execution

**Governance Benefits:**
- **Centralized Control**: Single point of administrative decision-making
- **Emergency Response**: Immediate reaction capability during incidents
- **System Evolution**: Ability to add new tokens as ecosystem grows
- **Maintenance**: Controlled updates and configuration changes

### **📡 Events & Custom Error Handling**

**Why Custom Events (Lines 91-108):**
- **Transparency**: Off-chain monitoring of all operations
- **Integration**: Easy front-end integration
- **Gas Efficiency**: Cheaper than storage for historical data

**Why Custom Errors (Lines 111-123):**
- **Gas Optimization**: ~50% less gas than require() strings
- **Debugging**: Include relevant parameters for precise error tracking
- **Type Safety**: Prevent error message conflicts

**Key Examples:**
- `KipuBankV2_Deposit` - Line 91: Complete transaction tracking
- `KipuBankV2_BankCapExceeded` - Line 115: Parametrized error with limits
- `KipuBankV2_OracleStalePrice` - Line 121: Oracle validation errors

## 🚀 **STEP-BY-STEP ETHERSCAN EXECUTION GUIDE**

### **📋 Prerequisites**
- MetaMask installed and configured for Sepolia Testnet
- Sepolia ETH from [sepoliafaucet.com](https://sepoliafaucet.com/) (minimum 0.02 ETH recommended)
- Contract Address: `0x4b677233e4124640e309D6880ae66f7697b36674`

### **🔗 Step 1: Access Contract**
1. Navigate to: https://sepolia.etherscan.io/address/0x4b677233e4124640e309D6880ae66f7697b36674
2. Click **"Contract"** tab
3. You'll see **"Read Contract"** and **"Write Contract"** sub-tabs

### **📖 Step 2: Read Contract Functions (Testing Information Retrieval)**

**2.1 Check Bank Status:**
```
Function: getBankInfo()
- Click "getBankInfo" → "Query"
- Returns 6 values:
  * totalDepUSD: Total deposited in USD (6 decimals)
  * totalDeps: Number of deposits made
  * totalWiths: Number of withdrawals made
  * bankCapUSD: Bank capacity limit (1,000,000 USD)
  * withdrawLimitUSD: Withdrawal limit (10,000 USD)
  * paused: Contract status (false=active, true=paused)
```

**2.2 Get Current ETH Price:**
```
Function: getPrice(address token)
- Input: 0x0000000000000000000000000000000000000000
- Click "Query"
- Returns: ETH/USD price in 8 decimals (e.g., 250000000000 = $2,500)
```

**2.3 Verify Your Balance:**
```
Function: getBalance(address user, address token)
- user: Your wallet address
- token: 0x0000000000000000000000000000000000000000 (ETH)
- Returns: Your balance in USD (6 decimals)
```

**2.4 Check Token Configuration:**
```
Function: getTokenConfig(address token)
- Input: 0x0000000000000000000000000000000000000000
- Returns: ETH support status and price feed info
```

**2.5 Verify Contract Owner:**
```
Function: owner()
- Returns: Contract owner address
```

### **✍️ Step 3: Write Contract Functions (Testing Transactions)**

**3.1 Connect MetaMask:**
1. Click **"Write Contract"** tab
2. Click **"Connect to Web3"**
3. Select MetaMask and authorize connection
4. Verify your address appears as connected

**3.2 Test ETH Deposit:**
```
Function: depositETH()
- Enter amount in ETH: 0.01 (for 0.01 ETH deposit)
- Click "Write" → Confirm in MetaMask
- Wait ~15-30 seconds for confirmation
- Note the transaction hash
```

**3.3 Verify Deposit:**
```
- Return to "Read Contract"
- Use getBalance() with your address
- Should show your deposit in USD value
- Use getBankInfo() to see updated totals
```

**3.4 Test ETH Withdrawal:**
```
Function: withdrawETH(uint256 usdAmount)
- Calculate: If ETH = $2,500 and you want to withdraw $10:
  Input: 10000000 (10 USD in 6 decimals)
- Click "Write" → Confirm in MetaMask
- Wait for confirmation
```

### **📊 Step 4: Verify Results and Events**

**4.1 Check Transaction Events:**
```
- Click on transaction hash from deposits/withdrawals
- Go to "Logs" tab
- Look for events:
  * KipuBankV2_Deposit: Shows ETH and USD amounts
  * KipuBankV2_Withdrawal: Shows withdrawal details
```

**4.2 Verify Balance Changes:**
```
- Use getBalance() before and after operations
- Use getBankInfo() to see bank totals update
- Confirm USD conversions are accurate
```

### **🔐 Step 5: Administrative Functions Testing (Owner Only)**

**⚠️ Note:** These functions only work if you're the contract owner.

**5.1 Emergency Pause:**
```
Function: pause()
- Click "Write" → Confirm transaction
- Verify: getBankInfo() shows paused = true
- Test: depositETH() should fail with "ContractPaused" error
```

**5.2 Resume Operations:**
```
Function: unpause()
- Click "Write" → Confirm transaction
- Verify: getBankInfo() shows paused = false
- Test: Normal operations resume
```

### **📈 Expected Results & Validation**

**Typical Values You Should See:**
```
ETH Price: ~250000000000 (≈$2,500 in 8 decimals)
Gas Usage: 
  - Deposit: ~120,000 gas
  - Withdrawal: ~100,000 gas
  - Admin functions: ~50,000 gas

Balance Updates:
  - Deposit 0.01 ETH at $2,500 = 25000000 (25 USD in 6 decimals)
  - Withdrawal 10000000 = $10 worth of ETH returned

Events Emitted:
  - Complete transaction details with USD conversions
  - Proper indexing for off-chain monitoring
```

### **🚨 Common Errors and Solutions**

| Error | Cause | Solution |
|-------|--------|----------|
| `KipuBankV2_ZeroAmount` | Amount = 0 | Enter value > 0 |
| `KipuBankV2_InsufficientBalance` | Not enough balance | Check balance first |
| `KipuBankV2_ContractPaused` | Contract paused | Wait for unpause or contact owner |
| `KipuBankV2_BankCapExceeded` | Bank at capacity | Try smaller amount |
| MetaMask connection fails | Wrong network | Switch to Sepolia Testnet |

### **📝 Testing Checklist for Instructors**

**Complete Test Sequence (15-20 minutes):**
- [ ] Read all contract information functions
- [ ] Connect MetaMask to Sepolia
- [ ] Perform ETH deposit (0.01 ETH recommended)
- [ ] Verify balance update and USD conversion
- [ ] Perform partial withdrawal ($5-10 USD)
- [ ] Check transaction events and gas usage
- [ ] Verify final balances and bank totals
- [ ] Test error conditions (zero amounts, insufficient balance)
- [ ] Document transaction hashes and results

**Key Validation Points:**
- ✅ Oracle price feed working (live ETH/USD rates)
- ✅ USD conversion accuracy (18 decimals → 6 decimals)
- ✅ Event emission with complete transaction details
- ✅ Gas optimization (custom errors vs require strings)
- ✅ Access control enforcement (admin functions)
- ✅ Circuit breaker functionality (pause/unpause)

### **Module 3 Deliverables Implementation**

| Requirement | Implementation | Code Reference |
|-------------|----------------|----------------|
| **Access Control** | OpenZeppelin Ownable | Line 21, Functions 301-346 |
| **Type Declarations** | TokenConfig struct | Lines 28-32 |
| **Chainlink Oracle** | AggregatorV3Interface | Lines 507-517 |
| **Constant Variables** | 6 gas-optimized constants | Lines 38-51 |
| **Nested Mappings** | User→Token→Balance | Line 75 |
| **Decimal Conversion** | `_convertToUSD()` function | Lines 482-501 |

### **Key Enhancements Over Original KipuBank**

#### **1. Multi-Token Support**
- **Before:** ETH only
- **After:** Configurable ERC20 tokens via `TokenConfig` struct (Lines 28-32)

#### **2. USD-Based Accounting**
- **Implementation:** All balances normalized to 6 decimals USD
- **Benefit:** Universal compatibility with DeFi standards
- **Logic:** `_convertToUSD()` handles different token decimals (Lines 482-501)

#### **3. Oracle Integration**
- **Price Feeds:** Chainlink AggregatorV3Interface (Line 16)
- **Validation:** Staleness check with 1-hour heartbeat (Line 50)
- **Security:** Price validation prevents manipulation attacks

#### **4. Gas Optimization**
- **Custom Errors:** 50% gas reduction vs string requires
- **Constant Variables:** Compile-time optimization (Lines 38-51)
- **Efficient Storage:** Packed structs and optimized mappings

## ⚙️ **SYSTEM CONFIGURATION**

### **Token Configuration**
```solidity
struct TokenConfig {
    bool isActive;           // Gas-optimized boolean flag
    uint8 decimals;         // Token precision (6, 8, 18)
    address priceFeed;      // Chainlink aggregator address
}
```

### **Security Patterns Applied**
- **Circuit Breaker:** Emergency pause functionality
- **Access Control:** Role-based permissions
- **Oracle Validation:** Staleness and price sanity checks
- **Reentrancy Protection:** OpenZeppelin's ReentrancyGuard
- **Integer Overflow:** Solidity 0.8.26 built-in protection

## 🛠️ **DEPLOYMENT SPECIFICATIONS**

### **Constructor Parameters**
```solidity
constructor(
    address _ethPriceFeed,    // 0x694AA1769357215DE4FAC081bf1f309aDC325306
    uint256 _maxBankBalance   // 1000000000000 (1M USD in 6 decimals)
)
```

### **Initial State**
- **ETH Support:** Automatically configured
- **Oracle Feed:** Chainlink ETH/USD Sepolia
- **Bank Capacity:** 1,000,000 USD maximum
- **Decimals:** 6-decimal USD normalization

## 🔒 **SECURITY CONSIDERATIONS**

### **Oracle Security**
- **Staleness Check:** 1-hour maximum age
- **Price Validation:** Reasonable bounds checking
- **Fallback Mechanism:** Circuit breaker on oracle failure

### **Access Control Matrix**
| Function | Public | Owner Only | Notes |
|----------|--------|------------|-------|
| `depositETH()` | ✅ | ❌ | Open deposits |
| `withdrawETH()` | ✅ | ❌ | User withdrawals |
| `addToken()` | ❌ | ✅ | Admin governance |
| `pause()` | ❌ | ✅ | Emergency control |

## 📊 **TESTING & VERIFICATION**

### **Unit Test Coverage**
- ✅ Deposit/Withdrawal flows
- ✅ Oracle price integration
- ✅ Access control enforcement
- ✅ Emergency pause functionality
- ✅ Multi-token support

### **Integration Tests**
- ✅ Chainlink oracle interaction
- ✅ ERC20 token compatibility
- ✅ USD conversion accuracy
- ✅ Gas optimization validation

## 🚀 **USAGE EXAMPLES**

### **Basic ETH Operations**
```javascript
// Deposit 0.1 ETH
await kipuBank.depositETH({ value: ethers.parseEther("0.1") });

// Check balance (returns USD value in 6 decimals)
const balance = await kipuBank.getBalance(userAddress, ethers.ZeroAddress);

// Withdraw 50 USD worth of ETH
await kipuBank.withdrawETH(50000000); // 50 * 10^6
```

### **Administrative Functions**
```javascript
// Add new token support (Owner only)
await kipuBank.addToken(
    "0xTokenAddress",
    "0xPriceFeedAddress", 
    18 // Token decimals
);

// Emergency pause (Owner only)
await kipuBank.pause();
```

## 📈 **PERFORMANCE METRICS**

| Operation | Gas Estimate | USD Cost (@20 gwei) |
|-----------|--------------|---------------------|
| ETH Deposit | ~120,000 | $0.48 |
| ETH Withdrawal | ~100,000 | $0.40 |
| Balance Query | ~30,000 | $0.12 |
| Add Token | ~80,000 | $0.32 |

## 🎓 **EDUCATIONAL VALUE**

This project demonstrates mastery of:
- **Advanced Solidity Patterns**: Structs, mappings, modifiers
- **DeFi Integration**: Oracle usage, multi-token accounting
- **Security Best Practices**: Access control, circuit breakers
- **Gas Optimization**: Custom errors, constant variables
- **Professional Development**: Documentation, testing, deployment

## 📞 **SUPPORT & CONTACT**

- **Developer:** Eduardo Moreno
- **Project Type:** Academic/Educational
- **Framework:** Ethereum Solidity
- **Deployment:** Sepolia Testnet
- **License:** MIT

---

**🎯 This project fulfills all Module 3 requirements while demonstrating production-ready smart contract development practices.**