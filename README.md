# KipuBankV2 - Decentralized Banking System 🏦

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://soliditylang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-v5.0.0-blue.svg)](https://openzeppelin.com/)
[![Chainlink](https://img.shields.io/badge/Chainlink-Oracles-red.svg)](https://chain.link/)

## 📋 Contract Information

- **Contract Address:** `0x4759C99DeeDe743aC81105e4bfcCb809BFa002E3`
- **Network:** Sepolia Testnet
- **Etherscan:** [View on Etherscan](https://sepolia.etherscan.io/address/0x4759C99DeeDe743aC81105e4bfcCb809BFa002E3)
- **Solidity Version:** 0.8.20
- **Status:** ✅ Verified and Deployed

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
1. Go to: https://sepolia.etherscan.io/address/0x4759C99DeeDe743aC81105e4bfcCb809BFa002E3
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

- **Gas Optimized:** Single storage read per function
- **Complete Events:** Full operation traceability
- **Custom Errors:** Higher gas efficiency
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

## 🚀 **MEJORAS IMPLEMENTADAS**

- ✅ **Retiros de ETH** con validación de fondos- **Seguridad Empresarial**: Pausas de emergencia y protección contra reentrancy

### **🔄 Evolución desde KipuBank Original:**

- ✅ **Consulta de balances** personales y del banco- **Observabilidad Completa**: Eventos detallados y errores descriptivos

| Característica | KipuBank V1 | KipuBankV2 | Mejora |

|---|---|---|---|- ✅ **Control de acceso** con funciones de administrador

| **Tokens Soportados** | Solo ETH | ETH + ERC-20 | ✅ Multi-token |

| **Control de Acceso** | Simple `onlyOwner` | AccessControl con roles | ✅ Granular |- ✅ **Funciones de emergencia** para el propietario## 🏦 **¿QUÉ HACE EL CONTRATO KIPUBANKV2?**

| **Precio de Activos** | N/A | Chainlink Oracles | ✅ Datos reales |

| **Contabilidad** | Simple mapping | Mappings anidados USD | ✅ Normalizada |

| **Seguridad** | Básica | ReentrancyGuard + CEI | ✅ Avanzada |

| **Manejo de Errores** | `require` strings | Custom errors | ✅ Gas eficiente |## 🚀 **DEPLOYMENT EN REMIX**### 📖 **Descripción Funcional Completa**

| **Eventos** | Básicos | Detallados con índices | ✅ Mejor observabilidad |

| **Configuración** | Hardcoded | Variables inmutables | ✅ Configurable |



### **🏗️ Arquitectura Avanzada:**### **1. Copiar el Contrato****KipuBankV2** es un banco descentralizado completo que gestiona depósitos y retiros de múltiples criptomonedas con las siguientes capacidades:



#### **1. Control de Acceso Granular**- Ve a [remix.ethereum.org](https://remix.ethereum.org)

```solidity

bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");- Crea un nuevo archivo: `KipuBank.sol`#### **💰 Sistema Bancario Multi-Token**

bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");

```- Copia todo el contenido del archivoEl contrato actúa como un banco que acepta tanto **ETH nativo** como **tokens ERC-20**. Cada usuario tiene balances individuales para cada tipo de token que deposita:

- **ADMIN_ROLE:** Gestión de tokens soportados

- **EMERGENCY_ROLE:** Pausa/reanudación de emergencia

- **DEFAULT_ADMIN_ROLE:** Administración de roles

### **2. Compilar**- **ETH Nativo**: Representado internamente como `address(0)` siguiendo estándares DeFi

#### **2. Integración con Chainlink Oracles**

```solidity- Compiler Version: **0.8.20**- **Tokens ERC-20**: Cualquier token que el administrador haya agregado al sistema

AggregatorV3Interface public immutable ethUsdPriceFeed;

```- Optimization: **Enabled (200 runs)**- **Balances Separados**: Cada usuario mantiene balances independientes por token

- **Precio ETH/USD:** Datos en tiempo real

- **Validación de Staleness:** Máximo 1 hora de antigüedad- **Conversión USD**: Todos los valores se normalizan a USD para límites y contabilidad

- **Sanity Checks:** Validación de precios positivos

### **3. Deploy**

#### **3. Soporte Multi-Token**

```solidity- Network: **Sepolia Testnet**#### **🔗 Integración con Oráculos Chainlink**

struct TokenInfo {

    bool isSupported;- **SIN PARÁMETROS DE CONSTRUCTOR** ✅El contrato utiliza **Chainlink Data Feeds** para obtener precios en tiempo real:

    uint8 decimals;

    AggregatorV3Interface priceFeed;- Gas Limit: 3,000,000

    string symbol;

}- **Precios Actualizados**: Cada transacción usa el precio más reciente del mercado

```

- **Configuración Flexible:** Añadir/remover tokens## 📊 **FUNCIONES PRINCIPALES**- **Validación de Datos**: Verifica que los precios sean positivos y actualizados (máximo 1 hora)

- **Oracle por Token:** Precios precisos para cada activo

- **Metadatos:** Decimales y símbolos- **Multi-Oracle**: Cada token puede tener su propio feed de precios dedicado



#### **4. Contabilidad Unificada en USD**### **💰 Depósitos**- **Normalización**: Convierte todos los valores a USD con 6 decimales (estándar USDC)

```solidity

mapping(address => mapping(address => uint256)) public userBalances;```solidity

```

- **Normalización:** Todos los valores en USD (6 decimales)function depositETH() external payable#### **🛡️ Sistema de Control de Acceso**

- **Conversión Automática:** ETH y tokens a USD

- **Balance Total:** Suma de todos los tokens del usuario```Implementa roles granulares usando **OpenZeppelin AccessControl**:



#### **5. Seguridad de Grado Producción**- Deposita ETH enviando valor con la transacción

- **ReentrancyGuard:** Protección contra ataques de reentrada

- **CEI Pattern:** Checks-Effects-Interactions en todas las funciones- Actualiza el balance del usuario- **ADMIN_ROLE**: Puede agregar/remover tokens soportados

- **SafeERC20:** Manejo seguro de tokens con comportamientos diversos

- **Custom Errors:** Eficiencia de gas y mejor debugging- Emite evento `Deposit`- **EMERGENCY_ROLE**: Puede pausar/despausar el sistema completo



---- **DEFAULT_ADMIN_ROLE**: Control maestro sobre todos los roles



## 🛠️ **INSTALACIÓN Y CONFIGURACIÓN**### **💸 Retiros**



### **Prerrequisitos:**```solidity#### **⚖️ Límites y Capacidades**

```bash

# Instalar Foundryfunction withdrawETH(uint256 amount) externalEl banco opera con límites configurables para seguridad:

curl -L https://foundry.paradigm.xyz | bash

foundryup```



# Verificar instalación- Retira la cantidad especificada en wei- **Capacidad Total**: Límite máximo de USD que puede almacenar el banco

forge --version

cast --version- Valida que el usuario tenga fondos suficientes- **Límite de Retiro**: Cantidad máxima que un usuario puede retirar por transacción

```

- Emite evento `Withdrawal`- **Depósito Mínimo**: Cantidad mínima requerida para depositar (1 USD)

### **Clonar y Configurar:**

```bash

# Clonar el repositorio

git clone https://github.com/edumor/KipuBankV2.git### **📈 Consultas**## 🔧 **FUNCIONES PRINCIPALES Y QUÉ REALIZAN**

cd KipuBankV2

```solidity

# Instalar dependencias

forge install OpenZeppelin/openzeppelin-contractsfunction getBalance() external view returns (uint256)### 💳 **Funciones de Depósito**

forge install smartcontractkit/chainlink

function getBankInfo() external view returns (uint256, uint256, uint256)

# Compilar contratos

forge build```#### **`depositETH()` - Depositar Ethereum**

```

```solidity

---

## 🔐 **SEGURIDAD**function depositETH() external payable whenNotPaused validAmount(msg.value) nonReentrant

## 🚀 **DEPLOYMENT**

```

### **1. Configurar Variables de Entorno:**

```bash- **Validación de fondos** antes de retiros**¿Qué hace?**

# Crear archivo .env

echo "PRIVATE_KEY=tu_private_key_aqui" > .env- **Control de acceso** con modificador `onlyOwner`1. Recibe ETH nativo enviado con la transacción (`msg.value`)

echo "SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/tu_api_key" >> .env

```- **Función de emergencia** para recuperar fondos2. Convierte el ETH a valor USD usando el precio de Chainlink



### **2. Deploy en Sepolia:**- **Transferencias seguras** con `call` y validación de éxito3. Verifica que el depósito no exceda la capacidad del banco

```bash

# Deploy con verificación4. Actualiza el balance del usuario y las estadísticas globales

forge script script/Deploy.s.sol:DeployKipuBankV2 \

    --rpc-url $SEPOLIA_RPC_URL \## 📝 **EVENTOS**5. Emite evento `Deposit` con todos los detalles

    --private-key $PRIVATE_KEY \

    --broadcast \

    --verify \

    --etherscan-api-key $ETHERSCAN_API_KEY```solidity**¿Por qué es importante?**

```

event Deposit(address indexed user, uint256 amount, uint256 newBalance);- Permite a usuarios depositar la criptomoneda nativa de Ethereum

### **3. Parámetros de Configuración:**

- **Límite de Retiro:** $10,000 USD por transacciónevent Withdrawal(address indexed user, uint256 amount, uint256 newBalance);- Gestiona automáticamente la conversión de ETH a USD para límites

- **Capacidad del Banco:** $1,000,000 USD total

- **Oracle ETH/USD:** `0x694AA1769357215DE4fac081bf1f309aDC325306` (Sepolia)```- Mantiene contabilidad precisa de todos los depósitos



---



## 📖 **GUÍA DE INTERACCIÓN**## 🧪 **TESTING EN REMIX**#### **`depositToken(address token, uint256 amount)` - Depositar Tokens ERC-20**



### **💰 Depósitos:**```solidity



#### **ETH:**### **Después del Deploy:**function depositToken(address token, uint256 amount) external whenNotPaused validAmount(amount) onlySupportedToken(token) nonReentrant

```solidity

// Depositar 1 ETH```

kipuBank.depositETH{value: 1 ether}();

```1. **Depositar ETH:****¿Qué hace?**



#### **Tokens ERC-20:**   - Ve a `depositETH`1. Verifica que el token esté en la lista de tokens soportados

```solidity

// 1. Aprobar tokens (ejemplo con USDC)   - En "Value": pon `1` ETH2. Transfiere tokens desde la wallet del usuario al contrato usando `SafeERC20`

IERC20(usdcAddress).approve(kipuBankAddress, amount);

   - Click "transact"3. Convierte el valor del token a USD usando su precio feed específico

// 2. Depositar tokens

kipuBank.depositToken(usdcAddress, amount);4. Actualiza balances y estadísticas igual que con ETH

```

2. **Ver Balance:**5. Emite evento `Deposit` correspondiente

### **💸 Retiros:**

   - Click en `getBalance`

#### **ETH:**

```solidity   - Verifica que muestre 1 ETH (en wei)**¿Por qué es importante?**

// Retirar 0.5 ETH

kipuBank.withdrawETH(0.5 ether);- Diversifica los tipos de activos que el banco puede manejar

```

3. **Retirar ETH:**- Usa `SafeERC20` para compatibilidad con tokens problemáticos

#### **Tokens ERC-20:**

```solidity   - En `withdrawETH`- Mantiene consistencia en el tratamiento de diferentes tokens

// Retirar tokens

kipuBank.withdrawToken(tokenAddress, amount);   - Amount: `500000000000000000` (0.5 ETH en wei)

```

   - Click "transact"### 🏧 **Funciones de Retiro**

### **📊 Consultas:**



```solidity

// Balance de usuario para un token específico4. **Información del Banco:**#### **`withdrawETH(uint256 amount)` - Retirar Ethereum**

uint256 balance = kipuBank.getUserBalance(userAddress, tokenAddress);

   - Click en `getBankInfo````solidity

// Balance total del usuario en USD

uint256 totalBalance = kipuBank.getUserTotalBalance(userAddress);   - Verifica estadísticasfunction withdrawETH(uint256 amount) external whenNotPaused validAmount(amount) nonReentrant



// Información general del banco```

(uint256 totalUSD, uint256 deposits, uint256 withdrawals, 

 uint256 cap, uint256 limit, bool paused) = kipuBank.getBankInfo();## 📋 **VERIFICACIÓN EN ETHERSCAN****¿Qué hace?**

```

1. Convierte la cantidad solicitada a valor USD

---

### **Pasos para Verificar:**2. Verifica que no exceda el límite de retiro por transacción

## 🔧 **FUNCIONES ADMINISTRATIVAS**

3. Verifica que el usuario tenga suficiente balance

### **Gestión de Tokens:**

```solidity1. **Etherscan → Verify and Publish**4. Actualiza balances y estadísticas del banco

// Añadir nuevo token (solo ADMIN_ROLE)

kipuBank.addToken(2. **Contract Address:** [tu-dirección-deployada]5. Transfiere ETH al usuario usando transferencia segura

    tokenAddress,

    "USDC",3. **Compiler Type:** `Solidity (Single file)`6. Emite evento `Withdrawal` con detalles

    6,

    usdcPriceFeedAddress4. **Compiler Version:** `v0.8.20+commit.a1b79de6`

);

5. **License:** `MIT License (MIT)`**¿Por qué es importante?**

// Remover token

kipuBank.removeToken(tokenAddress);6. **Optimization:** `Yes` (200 runs)- Permite a usuarios recuperar su ETH depositado

```

7. **Constructor Arguments:** `(vacío - sin parámetros)`- Aplica límites de seguridad para prevenir retiros masivos

### **Emergencias:**

```solidity8. **Pegar todo el código** de `KipuBank.sol`- Usa transferencias seguras para evitar fallos

// Pausar banco (solo EMERGENCY_ROLE)

kipuBank.emergencyPause();



// Reanudar operaciones## 🎓 **PARA EL INSTRUCTOR**#### **`withdrawToken(address token, uint256 amount)` - Retirar Tokens ERC-20**

kipuBank.emergencyUnpause();

``````solidity



---### **Funcionalidades Implementadas:**function withdrawToken(address token, uint256 amount) external whenNotPaused validAmount(amount) onlySupportedToken(token) nonReentrant



## 🧪 **TESTING CON REMIX**- ✅ Patrón de depósito/retiro seguro```



### **1. Deploy en Remix:**- ✅ Manejo de eventos para tracking**¿Qué hace?**

- Compilador: `0.8.20`

- Optimización: Habilitada (200 runs)- ✅ Control de acceso con `onlyOwner`1. Verifica que el token esté soportado y el usuario tenga balance

- Parámetros del constructor:

  - `_withdrawalLimitUSD`: `10000000000` (10K USD)- ✅ Validaciones de seguridad2. Convierte cantidad a USD y verifica límites

  - `_bankCapUSD`: `1000000000000` (1M USD)  

  - `_ethUsdPriceFeed`: `0x694AA1769357215DE4fac081bf1f309aDC325306`- ✅ Función `receive()` para ETH directo3. Actualiza balances del usuario y del banco



### **2. Interacciones de Prueba:**- ✅ Gestión de balances individuales4. Transfiere tokens usando `SafeERC20.safeTransfer`



```javascript5. Emite evento `Withdrawal` correspondiente

// 1. Depositar ETH

await kipuBank.depositETH({value: web3.utils.toWei("1", "ether")});### **Contrato Verificado:**



// 2. Verificar balanceUna vez deployado y verificado, el contrato estará disponible en:**¿Por qué es importante?**

const balance = await kipuBank.getUserBalance(accounts[0], "0x0000000000000000000000000000000000000000");

- **Etherscan:** [Dirección del contrato]- Completa la funcionalidad bancaria permitiendo retiros de cualquier token

// 3. Verificar conversión USD

const ethPrice = await kipuBank.getETHPrice();- **Funciones públicas:** Todas las funciones view son accesibles- Mantiene la misma lógica de seguridad para todos los tipos de activos

const usdValue = await kipuBank.convertToUSD("0x0000000000000000000000000000000000000000", web3.utils.toWei("1", "ether"));

```- **Eventos:** Historial completo de depósitos y retiros



---### 📊 **Funciones de Consulta**



## 📋 **DECISIONES DE DISEÑO**### **Casos de Uso Demostrados:**



### **1. ¿Por qué USD como denominación común?**1. Usuario deposita ETH → Balance actualizado#### **`getUserBalance(address user, address token)` - Consultar Balance Individual**

- **Consistencia:** Facilita comparaciones entre diferentes activos

- **Límites Claros:** Los límites de retiro y capacidad son intuitivos2. Usuario retira parcialmente → Fondos transferidos```solidity

- **Compatibilidad:** Estándar en DeFi para normalización de valores

3. Consulta de estadísticas del bancofunction getUserBalance(address user, address token) external view returns (uint256)

### **2. ¿Por qué 6 decimales para USD?**

- **Compatibilidad:** Coincide con USDC (el stablecoin más usado)4. Función de emergencia para administrador```

- **Precisión:** Suficiente para centavos de dólar

- **Eficiencia:** Menor uso de gas que 18 decimales**¿Qué hace?**



### **3. ¿Por qué AccessControl en lugar de Ownable?**---- Retorna el balance de un usuario específico para un token específico

- **Granularidad:** Diferentes roles para diferentes responsabilidades

- **Escalabilidad:** Múltiples administradores posibles- El balance está expresado en USD con 6 decimales

- **Seguridad:** Separación de poderes

**📧 Contacto:** Eduardo Moreno  - No requiere gas (función de solo lectura)

### **4. ¿Por qué variables inmutables para configuración?**

- **Seguridad:** No pueden ser modificadas después del deploy**🔗 Proyecto:** KipuBank - Ethereum Developer Program Módulo 3

- **Gas:** Más eficiente que variables de estado**¿Por qué es importante?**

- **Confianza:** Los usuarios conocen los límites desde el inicio- Permite a usuarios y aplicaciones consultar balances sin costo

- Proporciona información normalizada en USD

### **5. ¿Por qué Custom Errors?**

- **Gas:** Significativamente más eficiente que strings#### **`getUserTotalBalance(address user)` - Balance Total del Usuario**

- **Debugging:** Mejor información para desarrolladores```solidity

- **ABI:** Más limpio y fácil de parsearfunction getUserTotalBalance(address user) external view returns (uint256)

```

---**¿Qué hace?**

- Retorna la suma total de todos los balances del usuario en USD

## 🔐 **CONSIDERACIONES DE SEGURIDAD**- Incluye ETH y todos los tokens ERC-20 depositados

- No requiere gas (función de solo lectura)

### **✅ Medidas Implementadas:**

**¿Por qué es importante?**

1. **Reentrancy Protection:**- Da una vista completa de la riqueza del usuario en el banco

   - `nonReentrant` en todas las funciones que transfieren valor- Útil para aplicaciones que necesitan el valor total

   - Patrón CEI (Checks-Effects-Interactions) estricto

#### **`getBankInfo()` - Estadísticas Completas del Banco**

2. **Oracle Security:**```solidity

   - Validación de staleness (máximo 1 hora)function getBankInfo() external view returns (uint256 totalDepUSD, uint256 totalDeps, uint256 totalWiths, uint256 bankCapUSD, uint256 withdrawLimitUSD, bool paused)

   - Sanity checks para precios positivos```

   - Uso de feeds oficiales de Chainlink**¿Qué hace?**

- Retorna un resumen completo del estado del banco

3. **Access Control:**- Incluye total depositado, número de operaciones, límites y estado

   - Roles granulares con OpenZeppelin- Optimizada para obtener toda la información en una sola llamada

   - Funciones críticas protegidas

   - Capacidad de pausa de emergencia**¿Por qué es importante?**

- Proporciona transparencia sobre el estado del banco

4. **Safe Token Handling:**- Útil para dashboards y monitoreo

   - SafeERC20 para todos los tokens

   - Validación de tokens soportados### 🔗 **Funciones de Precios Chainlink**

   - Manejo de tokens con comportamientos diversos

#### **`getETHPrice()` - Precio Actual de Ethereum**

5. **Input Validation:**```solidity

   - Validación de montos positivosfunction getETHPrice() public view returns (uint256 price)

   - Verificación de límites y capacidades```

   - Custom errors para eficiencia**¿Qué hace?**

1. Consulta el precio feed de Chainlink para ETH/USD

### **⚠️ Limitaciones y Consideraciones:**2. Valida que el precio sea positivo y actualizado (máximo 1 hora)

3. Retorna el precio en formato de 8 decimales (estándar Chainlink)

1. **Oracle Dependency:**4. Revierte con error si los datos están obsoletos o son inválidos

   - Dependencia de Chainlink para precios

   - Riesgo de parada temporal si oracle falla**¿Por qué es importante?**

- Proporciona precios precisos y actualizados para conversiones

2. **Token Support:**- Incluye validaciones de seguridad para datos de oráculos

   - Solo tokens con oracles de Chainlink

   - Administrador debe configurar nuevos tokens#### **`getTokenPrice(address token)` - Precio de Cualquier Token**

```solidity

3. **Upgrade Path:**function getTokenPrice(address token) public view returns (uint256 price)

   - Contrato no es upgradeable```

   - Cambios requieren nuevo deployment**¿Qué hace?**

- Si es ETH (address(0)), llama a `getETHPrice()`

---- Para tokens ERC-20, usa su price feed específico

- Aplica las mismas validaciones de datos que ETH

## 📊 **MÉTRICAS Y MONITOREO**- Retorna precio en formato estándar de Chainlink



### **Eventos Clave:****¿Por qué es importante?**

```solidity- Unifica el acceso a precios para todos los tokens

event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);- Mantiene consistencia en validaciones

event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);

event TokenAdded(address indexed token, string symbol, uint8 decimals);#### **`convertToUSD(address token, uint256 amount)` - Conversión a USD**

event EmergencyPauseToggled(bool paused);```solidity

```function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue)

```

### **Métricas Importantes:****¿Qué hace?**

- **Total Depositado (USD):** `totalDepositedUSD`1. Obtiene el precio del token usando `getTokenPrice()`

- **Número de Operaciones:** `totalDeposits` + `totalWithdrawals`2. Obtiene los decimales del token de su configuración

- **Utilización:** `totalDepositedUSD / BANK_CAP_USD * 100%`3. Aplica fórmula de conversión: `(amount * price) / (10^(tokenDecimals + 2))`

- **Balance por Usuario:** Via `getUserTotalBalance()`4. Retorna valor en USD con 6 decimales (estándar USDC)



---**¿Por qué es importante?**

- Núcleo del sistema de normalización a USD

## 🔗 **ENLACES IMPORTANTES**- Maneja correctamente diferentes decimales de tokens

- Usado internamente por todas las funciones de depósito/retiro

### **Contrato Desplegado:**

- **Red:** Sepolia Testnet### 🔐 **Funciones Administrativas**

- **Dirección:** `[Será actualizada después del deploy]`

- **Etherscan:** `[Link será añadido]`#### **`addToken(address, string, uint8, address)` - Agregar Soporte de Token**

```solidity

### **Recursos:**function addToken(address token, string memory symbol, uint8 decimals, address priceFeed) external onlyRole(ADMIN_ROLE)

- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds)```

- [OpenZeppelin AccessControl](https://docs.openzeppelin.com/contracts/4.x/access-control)**¿Qué hace?**

- [Foundry Documentation](https://book.getfoundry.sh/)1. Verifica que el llamador tenga `ADMIN_ROLE`

2. Previene agregar ETH nativo (ya está incluido)

---3. Registra el token con su información y price feed

4. Emite evento `TokenAdded` para tracking

## 👨‍💻 **PARA EL INSTRUCTOR**

**¿Por qué es importante?**

### **Conceptos del Módulo 3 Implementados:**- Permite expansión del banco con nuevos tokens

- Mantiene control administrativo sobre qué tokens acepta el banco

1. **✅ EIP/ERC Standards:**

   - ERC-20 para tokens#### **`removeToken(address token)` - Remover Soporte de Token**

   - Uso de interfaces estándar```solidity

function removeToken(address token) external onlyRole(ADMIN_ROLE)

2. **✅ OpenZeppelin Integration:**```

   - AccessControl para roles**¿Qué hace?**

   - ReentrancyGuard para seguridad  - Verifica permisos de administrador

   - SafeERC20 para tokens seguros- Elimina token de la lista de soportados

- Previene remover ETH nativo

3. **✅ Chainlink Oracle Integration:**- Emite evento `TokenRemoved`

   - ETH/USD price feed

   - Validación de staleness**¿Por qué es importante?**

   - Conversión de precios- Permite remover tokens problemáticos o descontinuados

- Mantiene flexibilidad en la gestión de tokens

4. **✅ Advanced Solidity Patterns:**

   - Checks-Effects-Interactions### 🚨 **Funciones de Emergencia**

   - Custom errors

   - Immutable variables#### **`emergencyPause()` - Pausar Sistema**

   - Mappings anidados```solidity

function emergencyPause() external onlyRole(EMERGENCY_ROLE)

5. **✅ Multi-Token Architecture:**```

   - Soporte ETH nativo**¿Qué hace?**

   - Tokens ERC-20 configurables- Verifica que el llamador tenga `EMERGENCY_ROLE`

   - Normalización a USD- Activa la pausa global del sistema

- Previene nuevos depósitos y retiros

6. **✅ Security Best Practices:**- Emite evento `EmergencyPauseToggled`

   - Control de acceso granular

   - Protección contra reentrancy**¿Por qué es importante?**

   - Manejo seguro de tokens- Proporciona circuit breaker en caso de exploits o problemas

   - Validación exhaustiva- Permite respuesta rápida a emergencias



### **Casos de Uso Demostrados:**#### **`emergencyUnpause()` - Reanudar Sistema**

```solidity

1. **Usuario deposita ETH** → Conversión automática a USD via Oraclefunction emergencyUnpause() external onlyRole(EMERGENCY_ROLE)

2. **Usuario deposita USDC** → Tracking directo en USD  ```

3. **Administrador añade nuevo token** → Configuración de oracle y metadatos**¿Qué hace?**

4. **Emergencia detectada** → Pausa inmediata del sistema- Desactiva la pausa del sistema

5. **Usuario retira fondos** → Validación de límites y conversión inversa- Permite resumir operaciones normales

- Solo ejecutable por usuarios con `EMERGENCY_ROLE`

### **Innovaciones Técnicas:**

**¿Por qué es importante?**

- **Contabilidad Unificada:** Todos los balances en USD facilita gestión- Permite reanudar operaciones después de resolver problemas

- **Oracle Integration:** Precios en tiempo real para decisiones informadas- Mantiene control granular sobre el estado del sistema

- **Role-Based Admin:** Separación de responsabilidades administrativas

- **Multi-Token Native:** Diseñado desde cero para múltiples activos## 👨‍🏫 **SECCIÓN PARA EL INSTRUCTOR**



---### 📚 **Implementaciones del Módulo 3 Requeridas**



**📧 Contacto:** Eduardo Moreno  #### 🔐 **1. Control de Acceso: OpenZeppelin AccessControl**

**🔗 Repositorio:** [github.com/edumor/KipuBankV2](https://github.com/edumor/KipuBankV2)  

**🏆 Programa:** Ethereum Developer Program - Módulo 3**📍 UBICACIÓN EN EL CÓDIGO:**
```solidity
// contracts/KipuBankV2.sol - Líneas 17-35
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract KipuBankV2 is AccessControl, ReentrancyGuard {
    // Definición de roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
}
```

**🛠️ QUÉ SE AGREGÓ Y POR QUÉ:**

| Componente | Ubicación | Propósito |
|------------|-----------|-----------|
| **ADMIN_ROLE** | Línea 25 | Gestión de tokens soportados (`addToken`, `removeToken`) |
| **EMERGENCY_ROLE** | Línea 26 | Control de pausas (`emergencyPause`, `emergencyUnpause`) |
| **DEFAULT_ADMIN_ROLE** | Constructor | Rol maestro heredado de OpenZeppelin |

**🔧 FUNCIONES CON RESTRICCIONES DE ACCESO:**
```solidity
// Solo ADMIN_ROLE puede ejecutar
function addToken(address token, string memory symbol, uint8 decimals, address priceFeed) 
    external onlyRole(ADMIN_ROLE) { ... }

// Solo EMERGENCY_ROLE puede ejecutar  
function emergencyPause() external onlyRole(EMERGENCY_ROLE) { ... }
```

**💡 BENEFICIO:** Separación de responsabilidades - no todos los admins pueden pausar el sistema, creando capas de seguridad granular.

#### 📊 **2. Eventos y Manejo de Errores: Observabilidad Completa**

**📍 UBICACIÓN EN EL CÓDIGO:**
```solidity
// contracts/KipuBankV2.sol - Líneas 81-95 (Eventos)
event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
event TokenAdded(address indexed token, string symbol, uint8 decimals);
event EmergencyPauseToggled(bool paused);

// Líneas 97-115 (Errores Personalizados)
error ZeroAmount();
error TokenNotSupported(); 
error CapExceeded();
error LimitExceeded();
error LowBalance();
error TransferFailed();
error Paused();
error BadPriceFeed();
error StalePrice();
```

**🛠️ QUÉ SE AGREGÓ Y POR QUÉ:**

| Elemento | Ubicación | Propósito |
|----------|-----------|-----------|
| **Eventos Indexados** | Líneas 81-87 | Filtrado eficiente en frontend/analytics |
| **Valores USD en Eventos** | `usdValue` parameter | Tracking de valor real independiente de volatilidad |
| **Errores Cortos** | Líneas 97-115 | Ahorro de gas vs strings largos |
| **Estados Específicos** | `newBalance` en eventos | Auditabilidad completa sin queries adicionales |

**🔧 IMPLEMENTACIÓN EN FUNCIONES:**
```solidity
// Ejemplo en _deposit() - Línea 385
function _deposit(address token, uint256 amount) internal {
    // ... lógica ...
    
    // ✅ EVENTO CON INFORMACIÓN COMPLETA
    emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
}

// Ejemplo en _withdraw() con error personalizado
if (usdValue > currentUserBalance) revert LowBalance();
```

**💡 BENEFICIO:** Debugging eficiente y monitoreo en tiempo real. Los eventos permiten crear dashboards y alertas, mientras los errores personalizados ahorran gas.

### 🎯 **Funciones Implementadas y Sus Propósitos**

#### 💰 **Funciones de Usuario (Sin Restricciones)**
| Función | Propósito | Parámetros | Retorno |
|---------|-----------|------------|---------|
| `depositETH()` | Depositar ETH nativo | `payable` (ETH amount) | - |
| `depositToken()` | Depositar ERC-20 | `token`, `amount` | - |
| `withdrawETH()` | Retirar ETH | `amount` | - |
| `withdrawToken()` | Retirar ERC-20 | `token`, `amount` | - |
| `getUserBalance()` | Consultar balance | `user`, `token` | `uint256` (USD) |
| `getETHPrice()` | Precio ETH actual | - | `uint256` (USD, 8 decimals) |

#### 🔐 **Funciones Administrativas (Con Restricciones)**
| Función | Rol Requerido | Propósito | Parámetros |
|---------|---------------|-----------|------------|
| `addToken()` | `ADMIN_ROLE` | Agregar soporte para nuevo token | `token`, `symbol`, `decimals`, `priceFeed` |
| `removeToken()` | `ADMIN_ROLE` | Remover soporte de token | `token` |
| `emergencyPause()` | `EMERGENCY_ROLE` | Pausar todas las operaciones | - |
| `emergencyUnpause()` | `EMERGENCY_ROLE` | Reanudar operaciones | - |

#### 👁️ **Funciones de Vista (Consulta Gratuita)**
| Función | Información Retornada | Casos de Uso |
|---------|----------------------|--------------|
| `getBankInfo()` | Estadísticas completas del banco | Dashboards, analytics |
| `convertToUSD()` | Conversión token → USD | Cálculos frontend |
| `getTokenPrice()` | Precio de cualquier token soportado | Validaciones precio |

## 🌐 **GUÍA DE INTERACCIÓN EN ETHERSCAN PARA EL INSTRUCTOR**

### 📋 **Información del Contrato Desplegado**
Una vez desplegado en Etherscan, encontrará:
```
📍 Contract Address: 0x[address-del-contrato]
✅ Status: Verified ✓  
📄 Contract Name: KipuBankV2
🔗 Network: Sepolia Testnet
💰 ETH Balance: [ETH depositado en el contrato]
```

### 🔍 **Pestaña "Read Contract" - Verificación Sin Costos**

#### **Para Verificar Configuración Inicial:**
1. **`ADMIN_ROLE()`** → Devuelve: `0x241ecf16d79d0f8dbfb92cbc07fe17840425976cf0667f022fe9877caa831b08`
2. **`EMERGENCY_ROLE()`** → Devuelve: `0x5d8e12c39142ff96d79d04d15d1a04f3145b9947e4b2e55e53b7c8ee8ec7b2bc`  
3. **`WITHDRAWAL_LIMIT_USD()`** → Devuelve: `10000000000` (= $10,000 USD con 6 decimals)
4. **`BANK_CAP_USD()`** → Devuelve: `1000000000000` (= $1,000,000 USD con 6 decimals)

#### **Para Verificar Roles del Deployer:**
1. **`hasRole(bytes32,address)`**
   - Role: `0x241ecf16d79d0f8dbfb92cbc07fe17840425976cf0667f022fe9877caa831b08` (ADMIN_ROLE)
   - Account: `[su-address-de-deployer]`
   - Resultado: `true` ✅

#### **Para Verificar Precios Chainlink:**
1. **`getETHPrice()`** → Devuelve precio actual (ej: `250000000000` = $2,500.00 USD)
2. **`getTokenPrice(address)`** → Con `0x0000000000000000000000000000000000000000` para ETH

### ✍️ **Pestaña "Write Contract" - Interacción Con Costos de Gas**

#### **🔧 Funciones de Configuración (Solo para ADMIN_ROLE):**

**1. Agregar Nuevo Token ERC-20:**
```
Función: addToken(address,string,uint8,address)
Inputs:
  - token: 0x... (dirección del contrato ERC-20)
  - symbol: "USDC" 
  - decimals: 6
  - priceFeed: 0x... (dirección Chainlink price feed)
```

**2. Control de Emergencia (Solo EMERGENCY_ROLE):**
```
Función: emergencyPause()
Sin parámetros → Pausa todas las operaciones
```

#### **💰 Funciones de Usuario (Cualquiera puede ejecutar):**

**1. Depositar ETH:**
```
Función: depositETH()
Value: 1000000000000000000 (1 ETH en wei)
Sin parámetros adicionales
```

**2. Depositar Token ERC-20:**
```
⚠️ PRIMERO: Aprobar en el contrato del token
Función del Token: approve(address,uint256)
- spender: [dirección-del-KipuBankV2]  
- amount: 1000000 (1 USDC si son 6 decimales)

DESPUÉS: Depositar en KipuBank
Función: depositToken(address,uint256)
- token: [dirección-del-token]
- amount: 1000000
```

**3. Retirar ETH:**
```
Función: withdrawETH(uint256)
- amount: 500000000000000000 (0.5 ETH en wei)
```

### 📊 **Monitoreo de Eventos en Etherscan**

#### **Eventos Principales a Observar:**

**1. Evento `Deposit`:**
```
Topics[0]: 0x... (hash del evento Deposit)
Topics[1]: 0x... (dirección del usuario - indexed)
Topics[2]: 0x... (dirección del token - indexed)
Data: [amount, usdValue, newBalance] (sin indexar)
```

**Interpretación:**
- `user`: Quien hizo el depósito
- `token`: `0x000...000` = ETH, otra dirección = ERC-20
- `amount`: Cantidad en decimales nativos del token
- `usdValue`: Valor en USD (6 decimales) al momento del depósito
- `newBalance`: Nuevo balance del usuario en USD

**2. Evento `TokenAdded`:**
```
Indica cuando el admin agregó soporte para un nuevo token
Useful para trackear expansión de tokens soportados
```

#### **Logs de Transacciones Exitosas vs Fallidas:**
- ✅ **Success**: Estado `Success`, eventos emitidos
- ❌ **Reverted**: Razón del fallo (ej: "LowBalance", "CapExceeded")

### 🧪 **Escenarios de Prueba Recomendados para el Instructor**

#### **Prueba 1: Depósito ETH Básico**
```
1. Ir a Write Contract → depositETH()
2. Value: 0.1 ETH (100000000000000000 wei)
3. Ejecutar transacción
4. Verificar en Events: evento Deposit emitido
5. Verificar en Read Contract: getUserBalance(tu-address, 0x000...000)
```

#### **Prueba 2: Verificar Límites**
```
1. Intentar depositar > $1M USD equivalent en ETH
2. Debería fallar con error "CapExceeded"
3. Verificar en transaction details el revert reason
```

#### **Prueba 3: Control de Acceso**
```
1. Con cuenta SIN ADMIN_ROLE intentar addToken()
2. Debería fallar con "AccessControl: account ... is missing role"
3. Confirma que solo el deployer puede agregar tokens
```

## 🏗️ **Arquitectura Técnica del Sistema**

### 📁 **Estructura del Proyecto**
```
KipuBankV2/
├── contracts/
│   └── KipuBankV2.sol           # Contrato principal (460 líneas)
├── script/
│   └── Deploy.s.sol             # Script Foundry para deployment
├── foundry.toml                 # Configuración del proyecto
├── README.md                    # Documentación completa
└── README_MODULE3.md            # Documentación específica Módulo 3
```

### 🔗 **Dependencias y Imports**
```solidity
// OpenZeppelin (Seguridad y Estándares)
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";  
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Chainlink (Oráculos)
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
```

### 🎯 **Patrón de Herencia**
```solidity
contract KipuBankV2 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;  // Extensión para transferencias seguras
}
```

## 🚀 **Deployment y Configuración**

### 📋 **Parámetros de Constructor**
```solidity
constructor(
    uint256 _withdrawalLimitUSD,    // Ej: 10_000e6 ($10K con 6 decimales)
    uint256 _bankCapUSD,            // Ej: 1_000_000e6 ($1M con 6 decimales)  
    address _ethUsdPriceFeed        // Ej: 0x694AA1769357215DE4FAC081bf1f309aDC325306 (Sepolia)
)
```

### 🌐 **Direcciones de Price Feeds por Red**
| Red | ETH/USD Price Feed | Chain ID |
|-----|-------------------|----------|
| **Sepolia** | `0x694AA1769357215DE4FAC081bf1f309aDC325306` | 11155111 |
| **Mainnet** | `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419` | 1 |

### 🛠️ **Comandos de Deployment**
```bash
# 1. Configurar variables de entorno
export PRIVATE_KEY="your-private-key"
export SEPOLIA_RPC_URL="your-sepolia-rpc-url"
export ETHERSCAN_API_KEY="your-etherscan-api-key"

# 2. Deploy con verificación automática
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# 3. Verificar manualmente si falla auto-verificación
forge verify-contract --chain-id 11155111 [CONTRACT_ADDRESS] contracts/KipuBankV2.sol:KipuBankV2
```

## 🔧 **Instalación y Setup del Proyecto**

### 📦 **Requisitos Previos**
```bash
# 1. Node.js v18+
node --version

# 2. Foundry (Framework de desarrollo)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 3. Git para clonar el repositorio
git --version
```

### 📁 **Instalación del Proyecto**
```bash
# 1. Clonar repositorio
git clone https://github.com/edumor/kipu-bank.git
cd KipuBankV2

# 2. Instalar dependencias de Foundry
forge install

# 3. Compilar contratos
forge build

# 4. Ejecutar tests (opcional)
forge test
```

### ⚙️ **Configuración de Variables de Entorno**
```bash
# Crear archivo .env en la raíz del proyecto
SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR_INFURA_KEY"
PRIVATE_KEY="your-wallet-private-key-here"
ETHERSCAN_API_KEY="your-etherscan-api-key"
```

## 📊 **Estadísticas del Contrato**

### 📈 **Métricas de Código**
- **Líneas de código**: 460 líneas
- **Funciones públicas**: 12 funciones
- **Funciones administrativas**: 4 funciones
- **Eventos definidos**: 5 eventos  
- **Errores personalizados**: 9 errores
- **Roles de acceso**: 3 roles

### ⛽ **Estimaciones de Gas**
| Operación | Gas Estimado | Costo USD (50 gwei) |
|-----------|--------------|---------------------|
| `depositETH()` | ~85,000 gas | ~$2.50 |
| `depositToken()` | ~95,000 gas | ~$2.80 |
| `withdrawETH()` | ~75,000 gas | ~$2.20 |
| `addToken()` | ~65,000 gas | ~$1.90 |

---

## 👨‍💻 **Información del Desarrollador**

**Autor**: Eduardo Moreno  
**Proyecto**: Trabajo Práctico Módulo 3 - Ethereum Developer Program  
**Contrato**: KipuBankV2.sol  
**Framework**: Foundry + OpenZeppelin + Chainlink  
**Licencia**: MIT  

---

## 📞 **Soporte y Contacto**

Para consultas técnicas sobre la implementación o dudas sobre el funcionamiento del contrato, revisar:

1. **📖 Documentación técnica**: README_MODULE3.md  
2. **🔍 Código fuente**: contracts/KipuBankV2.sol  
3. **📊 Tests**: Ejecutar `forge test -vvv`