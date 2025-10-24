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

**Utilizamos eventos y errores personalizados para mejorar la observabilidad y el debugging del sistema bancario.**

#### **🔍 Custom Events - Trazabilidad Completa**

#### **1. Deposit Event - Línea 280, 349**
```solidity
event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
```

**Dónde se usa:**
- `depositETH()` - Línea 280: `emit Deposit(msg.sender, address(0), msg.value, usdValue, newETHBalance);`
- `depositToken()` - Línea 349: `emit Deposit(msg.sender, token, amount, usdValue, newTokenBalance);`

**Por qué es necesario:**
- **Auditabilidad:** Registro inmutable de cada depósito con valor en USD
- **Frontend Integration:** Permite actualizar interfaces en tiempo real
- **Índices Optimizados:** `indexed user` y `indexed token` permiten filtros eficientes
- **Monitoreo:** Sistemas externos pueden detectar depósitos grandes instantáneamente

#### **2. Withdrawal Event - Línea 395, 464**
```solidity
event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
```

**Dónde se usa:**
- `withdrawETH()` - Línea 395: `emit Withdrawal(msg.sender, address(0), amount, usdValue, newETHBalance);`
- `withdrawToken()` - Línea 464: `emit Withdrawal(msg.sender, token, amount, usdValue, newTokenBalance);`

**Por qué es crítico:**
- **Compliance Financiero:** Registro obligatorio para regulaciones
- **Detección de Fraude:** Patrones anómalos de retiro son detectables
- **Balance Tracking:** El `newBalance` permite verificar consistencia

#### **3. TokenAdded Event - Línea 493**
```solidity
event TokenAdded(address indexed token, string symbol, uint8 decimals);
```

**Dónde se usa:**
- `addToken()` - Línea 493: `emit TokenAdded(token, symbol, decimals);`

**Por qué es esencial:**
- **Configuración Dinámica:** Frontends detectan nuevos tokens automáticamente
- **Seguridad:** Registro público de qué tokens están autorizados
- **Integration:** Servicios externos saben qué tokens soportamos

#### **4. TokenRemoved Event - Línea 502**
```solidity
event TokenRemoved(address indexed token);
```

**Dónde se usa:**
- `removeToken()` - Línea 502: `emit TokenRemoved(token);`

**Por qué es necesario:**
- **Prevención de Errores:** Usuarios saben qué tokens ya no son válidos
- **Cache Invalidation:** Sistemas limpian datos de tokens removidos

#### **5. EmergencyPauseToggled Event - Línea 507, 512**
```solidity
event EmergencyPauseToggled(bool paused);
```

**Dónde se usa:**
- `emergencyPause()` - Línea 507: `emit EmergencyPauseToggled(true);`
- `emergencyUnpause()` - Línea 512: `emit EmergencyPauseToggled(false);`

**Por qué es crítico:**
- **Notificación Inmediata:** Todos los usuarios saben del estado de emergencia
- **Transparencia:** Registro público de cuándo y por qué se pausó el sistema
- **Automatización:** Bots pueden pausar operaciones automáticamente

#### **⚠️ Custom Errors - Debugging Eficiente**

#### **1. ZeroAmount() - Línea 269, 278, 338, etc.**
```solidity
error ZeroAmount();
```

**Dónde se usa:**
- Modifier `validAmount()` - Línea 269: `if (amount == 0) revert ZeroAmount();`
- Aplicado en TODAS las funciones de depósito y retiro

**Por qué es mejor que require:**
- **Gas Eficiente:** Ahorra ~50 gas vs require con string
- **Específico:** Error inequívoco sobre el problema exacto

#### **2. TokenNotSupported() - Línea 336, 426**
```solidity
error TokenNotSupported();
```

**Dónde se usa:**
- `depositToken()` - Línea 336: `if (!supportedTokens[token].isSupported) revert TokenNotSupported();`
- `withdrawToken()` - Línea 426: `if (!supportedTokens[token].isSupported) revert TokenNotSupported();`

**Por qué es esencial:**
- **Prevención de Pérdidas:** Evita depósitos de tokens no listados
- **UX Clarity:** Usuario sabe exactamente por qué falló la transacción

#### **3. CapExceeded() - Línea 282, 353**
```solidity
error CapExceeded();
```

**Dónde se usa:**
- `depositETH()` - Línea 282: `if (totalDepositedUSD + usdValue > BANK_CAP_USD) revert CapExceeded();`
- `depositToken()` - Línea 353: Similar validation

**Por qué es crítico:**
- **Risk Management:** Previene over-exposure del banco
- **Regulatory Compliance:** Mantiene límites dentro de regulaciones

#### **4. LimitExceeded() - Línea 383, 453**
```solidity
error LimitExceeded();
```

**Dónde se usa:**
- `withdrawETH()` - Línea 383: `if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();`
- `withdrawToken()` - Línea 453: Similar validation

**Por qué es necesario:**
- **AML Compliance:** Previene lavado de dinero con retiros grandes
- **Security:** Limita daño en caso de compromiso de cuentas

#### **5. LowBalance() - Línea 387, 457**
```solidity
error LowBalance();
```

**Dónde se usa:**
- `withdrawETH()` - Línea 387: `if (currentETHBalance < amount) revert LowBalance();`
- `withdrawToken()` - Línea 457: Similar validation

**Por qué es fundamental:**
- **Consistency:** Evita balances negativos
- **UX:** Error claro sobre fondos insuficientes

#### **6. TransferFailed() - Línea 392**
```solidity
error TransferFailed();
```

**Dónde se usa:**
- `withdrawETH()` - Línea 392: `if (!success) revert TransferFailed();`

**Por qué es crítico:**
- **Safety:** Detecta fallos en transferencias ETH
- **Atomicity:** Revierte toda la operación si transfer falla

#### **7. Paused() - Línea 264**
```solidity
error Paused();
```

**Dónde se usa:**
- Modifier `whenNotPaused()` - Línea 264: `if (emergencyPaused) revert Paused();`

**Por qué es esencial:**
- **Emergency Response:** Bloquea operaciones durante crisis
- **Clear Messaging:** Usuario sabe que sistema está pausado

#### **8. BadPriceFeed() - Línea 542**
```solidity
error BadPriceFeed();
```

**Dónde se usa:**
- `_getTokenPrice()` - Línea 542: `if (price <= 0) revert BadPriceFeed();`

**Por qué es crítico:**
- **Oracle Security:** Detecta feeds comprometidos o inválidos
- **Financial Safety:** Evita conversiones USD erróneas

#### **9. StalePrice() - Línea 539**
```solidity
error StalePrice();
```

**Dónde se usa:**
- `_getTokenPrice()` - Línea 539: `if (block.timestamp - updatedAt > 3600) revert StalePrice();`

**Por qué es fundamental:**
- **Price Accuracy:** Evita usar precios desactualizados (>1 hora)
- **MEV Protection:** Previene ataques con precios obsoletos

#### **🎯 Ventajas del Sistema de Eventos y Errores:**

1. **Gas Efficiency:** Custom errors ahorran ~50 gas vs require strings
2. **Debugging Precision:** Cada error identifica el problema exacto
3. **Frontend Integration:** Eventos permiten UIs reactivas
4. **Audit Trail:** Registro completo de todas las operaciones
5. **Monitoring:** Sistemas externos pueden reaccionar a eventos específicos
6. **Compliance:** Trazabilidad completa para auditorías regulatorias

**Resultado:** Sistema bancario completamente observable y debuggeable con overhead mínimo de gas.


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

