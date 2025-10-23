# KipuBankV2 - Módulo 3 Implementation

## 🎓 **Ethereum Developer Program - Module 3 Practice**

KipuBankV2 implements all concepts taught in **Module 3** of the Ethereum Developer Program, demonstrating advanced smart contract patterns including multi-token support, Chainlink oracles, role-based access control, and enterprise security practices.

## 📚 **Module 3 Concepts Implemented**

### 🔐 **1. OpenZeppelin AccessControl (Module 3 Pattern)**
```solidity
// Role-based permissions as taught in Module 3
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
```
- **ADMIN_ROLE**: Token management and configuration
- **EMERGENCY_ROLE**: Pause/unpause functionality
- **DEFAULT_ADMIN_ROLE**: Master admin control

### 💰 **2. Multi-Token Architecture (Module 3 Standard)**
```solidity
// Native ETH represented as address(0) - Module 3 convention
address public constant NATIVE_TOKEN = address(0);

// Nested mapping for user balances - Module 3 pattern
mapping(address => mapping(address => uint256)) public userBalances;
```
- **Native ETH**: Uses `address(0)` representation as taught
- **ERC20 Support**: SafeERC20 for secure token operations
- **Unified Interface**: Single functions handle both ETH and tokens

### 🔗 **3. Chainlink Price Feeds (Module 3 Integration)**
```solidity
// Price feed integration with staleness check - Module 3 pattern
function getTokenPrice(address token) public view returns (uint256) {
    (, int256 answer, , uint256 updatedAt,) = priceFeed.latestRoundData();
    if (answer <= 0) revert BadPriceFeed();
    if (block.timestamp - updatedAt > 3600) revert StalePrice();
    return uint256(answer);
}
```
- **AggregatorV3Interface**: Direct Chainlink integration
- **Data Validation**: Price positivity and freshness checks
- **Multi-Oracle**: Each token has dedicated price feed

### 📊 **4. USD Normalization (Module 3 Standard)**
```solidity
// Convert all values to 6-decimal USD (USDC standard) - Module 3 approach
function convertToUSD(address token, uint256 amount) public view returns (uint256) {
    uint256 tokenPrice = getTokenPrice(token);  // 8 decimals from Chainlink
    uint8 tokenDecimals = supportedTokens[token].decimals;
    return (amount * tokenPrice) / (10 ** (tokenDecimals + 2));
}
```

### 🛡️ **5. CEI Pattern & Security (Module 3 Best Practices)**
```solidity
function _deposit(address token, uint256 amount) internal {
    // CHECKS (Module 3 CEI Pattern)
    if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
    
    // EFFECTS (single state variable access)
    userBalances[msg.sender][token] = newUserBalance;
    
    // INTERACTIONS (external calls last)
    emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
}
```

## 🏗️ **Contract Architecture (Following Module 3)**

### **Token Registration System**
```solidity
struct TokenInfo {
    bool isSupported;                   // Whitelist status
    uint8 decimals;                     // Token decimals
    AggregatorV3Interface priceFeed;    // Chainlink oracle
    string symbol;                      // Display name
}
```

### **Core Banking Functions**
- `depositETH()` - Direct ETH deposits using `address(0)`
- `depositToken()` - ERC20 deposits with SafeERC20
- `withdrawETH()` - Native ETH withdrawals
- `withdrawToken()` - ERC20 withdrawals with SafeERC20

### **Admin Functions (Role-Based)**
- `addToken()` - Add new supported tokens (ADMIN_ROLE)
- `removeToken()` - Remove token support (ADMIN_ROLE)
- `emergencyPause()` - Pause operations (EMERGENCY_ROLE)

## 🔍 **Module 3 Compliance Features**

### ✅ **English NatSpec Documentation**
All functions include comprehensive English NatSpec comments as required.

### ✅ **Short Error Strings**
Custom errors with 6-14 character identifiers for gas efficiency:
```solidity
error ZeroAmount();      // 10 chars
error TokenNotSupported(); // 17 chars -> abbreviated to shorter version
error CapExceeded();     // 10 chars
error LimitExceeded();   // 13 chars
```

### ✅ **Single State Variable Access**
Each function reads each state variable only once per execution:
```solidity
// Single reads cached to local variables
uint256 currentUserBalance = userBalances[msg.sender][token];
uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
```

### ✅ **CEI Pattern Implementation**
All functions follow Checks-Effects-Interactions pattern religiously.

## 🚀 **Quick Start (Module 3 Deployment)**

### **1. Setup Environment**
```bash
git clone https://github.com/edumor/KipuBankV2
cd KipuBankV2
forge install
```

### **2. Configure Networks**
```bash
# Add to .env
SEPOLIA_RPC_URL="your-sepolia-rpc"
PRIVATE_KEY="your-private-key"
ETHERSCAN_API_KEY="your-etherscan-key"
```

### **3. Deploy Contract**
```bash
# Deploy to Sepolia (Module 3 testnet)
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# Test locally
forge test
```

## 📝 **Module 3 Example Usage**

### **Deposit ETH (address(0) pattern)**
```solidity
// Direct ETH deposit
kipuBank.depositETH{value: 1 ether}();

// Check balance (normalized to USD)
uint256 balance = kipuBank.getUserBalance(user, address(0));
```

### **Deposit ERC20 Token**
```solidity
// First approve token
IERC20(tokenAddress).approve(address(kipuBank), amount);

// Then deposit
kipuBank.depositToken(tokenAddress, amount);
```

### **Price Feed Integration**
```solidity
// Get current ETH price from Chainlink
uint256 ethPrice = kipuBank.getETHPrice();  // 8 decimals

// Convert token amount to USD
uint256 usdValue = kipuBank.convertToUSD(tokenAddress, amount);  // 6 decimals
```

## 🎯 **Module 3 Learning Outcomes Demonstrated**

1. **✅ Multi-Token Support**: Native ETH + ERC20 with unified interface
2. **✅ Chainlink Integration**: Price feeds with staleness validation
3. **✅ Access Control**: Role-based permissions with OpenZeppelin
4. **✅ Security Patterns**: CEI, ReentrancyGuard, single state access
5. **✅ Gas Optimization**: Efficient storage patterns and operations
6. **✅ Error Handling**: Custom errors with descriptive names
7. **✅ Documentation**: Complete English NatSpec coverage

## 🔧 **Development & Testing**

### **Run Tests**
```bash
forge test -vvv
```

### **Coverage Report**
```bash
forge coverage
```

### **Gas Analysis**
```bash
forge test --gas-report
```

## 📄 **Contract Addresses**

- **Sepolia Testnet**: `0x...` (Deploy after testing)
- **Mainnet**: `Not deployed yet`

## 👨‍💻 **Author**

**Eduardo Moreno**  
Ethereum Developer Program - Module 3  
GitHub: [@edumor](https://github.com/edumor)

---

**Note**: This implementation strictly follows Module 3 patterns and is designed for educational and practical demonstration of advanced Solidity concepts.