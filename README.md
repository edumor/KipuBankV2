# KipuBankV2 - Sistema Bancario Avanzado

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue.svg)](https://soliditylang.org/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-v5.0.0-blue.svg)](https://openzeppelin.com/) [![Chainlink](https://img.shields.io/badge/Chainlink-Oracles-red.svg)](https://chain.link/)

## 📋 Descripción del Proyecto

**KipuBankV2** es un sistema bancario descentralizado que evoluciona el KipuBank original implementando funcionalidades avanzadas del Módulo 3. El contrato permite depósitos y retiros multi-token con conversión automática a USD usando oráculos Chainlink, control de acceso basado en roles, y patrones de seguridad empresarial.

### 🎯 **Funcionalidades Principales**
- **Depósitos Multi-token**: ETH nativo y tokens ERC-20 
- **Conversión USD Automática**: Precios en tiempo real via Chainlink
- **Control de Acceso**: Sistema de roles granular con OpenZeppelin
- **Límites Dinámicos**: Capacidad del banco y límites de retiro en USD
- **Seguridad Empresarial**: Pausas de emergencia y protección contra reentrancy
- **Observabilidad Completa**: Eventos detallados y errores descriptivos

## 🏦 **¿QUÉ HACE EL CONTRATO KIPUBANKV2?**

### 📖 **Descripción Funcional Completa**

**KipuBankV2** es un banco descentralizado completo que gestiona depósitos y retiros de múltiples criptomonedas con las siguientes capacidades:

#### **💰 Sistema Bancario Multi-Token**
El contrato actúa como un banco que acepta tanto **ETH nativo** como **tokens ERC-20**. Cada usuario tiene balances individuales para cada tipo de token que deposita:

- **ETH Nativo**: Representado internamente como `address(0)` siguiendo estándares DeFi
- **Tokens ERC-20**: Cualquier token que el administrador haya agregado al sistema
- **Balances Separados**: Cada usuario mantiene balances independientes por token
- **Conversión USD**: Todos los valores se normalizan a USD para límites y contabilidad

#### **🔗 Integración con Oráculos Chainlink**
El contrato utiliza **Chainlink Data Feeds** para obtener precios en tiempo real:

- **Precios Actualizados**: Cada transacción usa el precio más reciente del mercado
- **Validación de Datos**: Verifica que los precios sean positivos y actualizados (máximo 1 hora)
- **Multi-Oracle**: Cada token puede tener su propio feed de precios dedicado
- **Normalización**: Convierte todos los valores a USD con 6 decimales (estándar USDC)

#### **🛡️ Sistema de Control de Acceso**
Implementa roles granulares usando **OpenZeppelin AccessControl**:

- **ADMIN_ROLE**: Puede agregar/remover tokens soportados
- **EMERGENCY_ROLE**: Puede pausar/despausar el sistema completo
- **DEFAULT_ADMIN_ROLE**: Control maestro sobre todos los roles

#### **⚖️ Límites y Capacidades**
El banco opera con límites configurables para seguridad:

- **Capacidad Total**: Límite máximo de USD que puede almacenar el banco
- **Límite de Retiro**: Cantidad máxima que un usuario puede retirar por transacción
- **Depósito Mínimo**: Cantidad mínima requerida para depositar (1 USD)

## 🔧 **FUNCIONES PRINCIPALES Y QUÉ REALIZAN**

### 💳 **Funciones de Depósito**

#### **`depositETH()` - Depositar Ethereum**
```solidity
function depositETH() external payable whenNotPaused validAmount(msg.value) nonReentrant
```
**¿Qué hace?**
1. Recibe ETH nativo enviado con la transacción (`msg.value`)
2. Convierte el ETH a valor USD usando el precio de Chainlink
3. Verifica que el depósito no exceda la capacidad del banco
4. Actualiza el balance del usuario y las estadísticas globales
5. Emite evento `Deposit` con todos los detalles

**¿Por qué es importante?**
- Permite a usuarios depositar la criptomoneda nativa de Ethereum
- Gestiona automáticamente la conversión de ETH a USD para límites
- Mantiene contabilidad precisa de todos los depósitos

#### **`depositToken(address token, uint256 amount)` - Depositar Tokens ERC-20**
```solidity
function depositToken(address token, uint256 amount) external whenNotPaused validAmount(amount) onlySupportedToken(token) nonReentrant
```
**¿Qué hace?**
1. Verifica que el token esté en la lista de tokens soportados
2. Transfiere tokens desde la wallet del usuario al contrato usando `SafeERC20`
3. Convierte el valor del token a USD usando su precio feed específico
4. Actualiza balances y estadísticas igual que con ETH
5. Emite evento `Deposit` correspondiente

**¿Por qué es importante?**
- Diversifica los tipos de activos que el banco puede manejar
- Usa `SafeERC20` para compatibilidad con tokens problemáticos
- Mantiene consistencia en el tratamiento de diferentes tokens

### 🏧 **Funciones de Retiro**

#### **`withdrawETH(uint256 amount)` - Retirar Ethereum**
```solidity
function withdrawETH(uint256 amount) external whenNotPaused validAmount(amount) nonReentrant
```
**¿Qué hace?**
1. Convierte la cantidad solicitada a valor USD
2. Verifica que no exceda el límite de retiro por transacción
3. Verifica que el usuario tenga suficiente balance
4. Actualiza balances y estadísticas del banco
5. Transfiere ETH al usuario usando transferencia segura
6. Emite evento `Withdrawal` con detalles

**¿Por qué es importante?**
- Permite a usuarios recuperar su ETH depositado
- Aplica límites de seguridad para prevenir retiros masivos
- Usa transferencias seguras para evitar fallos

#### **`withdrawToken(address token, uint256 amount)` - Retirar Tokens ERC-20**
```solidity
function withdrawToken(address token, uint256 amount) external whenNotPaused validAmount(amount) onlySupportedToken(token) nonReentrant
```
**¿Qué hace?**
1. Verifica que el token esté soportado y el usuario tenga balance
2. Convierte cantidad a USD y verifica límites
3. Actualiza balances del usuario y del banco
4. Transfiere tokens usando `SafeERC20.safeTransfer`
5. Emite evento `Withdrawal` correspondiente

**¿Por qué es importante?**
- Completa la funcionalidad bancaria permitiendo retiros de cualquier token
- Mantiene la misma lógica de seguridad para todos los tipos de activos

### 📊 **Funciones de Consulta**

#### **`getUserBalance(address user, address token)` - Consultar Balance Individual**
```solidity
function getUserBalance(address user, address token) external view returns (uint256)
```
**¿Qué hace?**
- Retorna el balance de un usuario específico para un token específico
- El balance está expresado en USD con 6 decimales
- No requiere gas (función de solo lectura)

**¿Por qué es importante?**
- Permite a usuarios y aplicaciones consultar balances sin costo
- Proporciona información normalizada en USD

#### **`getUserTotalBalance(address user)` - Balance Total del Usuario**
```solidity
function getUserTotalBalance(address user) external view returns (uint256)
```
**¿Qué hace?**
- Retorna la suma total de todos los balances del usuario en USD
- Incluye ETH y todos los tokens ERC-20 depositados
- No requiere gas (función de solo lectura)

**¿Por qué es importante?**
- Da una vista completa de la riqueza del usuario en el banco
- Útil para aplicaciones que necesitan el valor total

#### **`getBankInfo()` - Estadísticas Completas del Banco**
```solidity
function getBankInfo() external view returns (uint256 totalDepUSD, uint256 totalDeps, uint256 totalWiths, uint256 bankCapUSD, uint256 withdrawLimitUSD, bool paused)
```
**¿Qué hace?**
- Retorna un resumen completo del estado del banco
- Incluye total depositado, número de operaciones, límites y estado
- Optimizada para obtener toda la información en una sola llamada

**¿Por qué es importante?**
- Proporciona transparencia sobre el estado del banco
- Útil para dashboards y monitoreo

### 🔗 **Funciones de Precios Chainlink**

#### **`getETHPrice()` - Precio Actual de Ethereum**
```solidity
function getETHPrice() public view returns (uint256 price)
```
**¿Qué hace?**
1. Consulta el precio feed de Chainlink para ETH/USD
2. Valida que el precio sea positivo y actualizado (máximo 1 hora)
3. Retorna el precio en formato de 8 decimales (estándar Chainlink)
4. Revierte con error si los datos están obsoletos o son inválidos

**¿Por qué es importante?**
- Proporciona precios precisos y actualizados para conversiones
- Incluye validaciones de seguridad para datos de oráculos

#### **`getTokenPrice(address token)` - Precio de Cualquier Token**
```solidity
function getTokenPrice(address token) public view returns (uint256 price)
```
**¿Qué hace?**
- Si es ETH (address(0)), llama a `getETHPrice()`
- Para tokens ERC-20, usa su price feed específico
- Aplica las mismas validaciones de datos que ETH
- Retorna precio en formato estándar de Chainlink

**¿Por qué es importante?**
- Unifica el acceso a precios para todos los tokens
- Mantiene consistencia en validaciones

#### **`convertToUSD(address token, uint256 amount)` - Conversión a USD**
```solidity
function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue)
```
**¿Qué hace?**
1. Obtiene el precio del token usando `getTokenPrice()`
2. Obtiene los decimales del token de su configuración
3. Aplica fórmula de conversión: `(amount * price) / (10^(tokenDecimals + 2))`
4. Retorna valor en USD con 6 decimales (estándar USDC)

**¿Por qué es importante?**
- Núcleo del sistema de normalización a USD
- Maneja correctamente diferentes decimales de tokens
- Usado internamente por todas las funciones de depósito/retiro

### 🔐 **Funciones Administrativas**

#### **`addToken(address, string, uint8, address)` - Agregar Soporte de Token**
```solidity
function addToken(address token, string memory symbol, uint8 decimals, address priceFeed) external onlyRole(ADMIN_ROLE)
```
**¿Qué hace?**
1. Verifica que el llamador tenga `ADMIN_ROLE`
2. Previene agregar ETH nativo (ya está incluido)
3. Registra el token con su información y price feed
4. Emite evento `TokenAdded` para tracking

**¿Por qué es importante?**
- Permite expansión del banco con nuevos tokens
- Mantiene control administrativo sobre qué tokens acepta el banco

#### **`removeToken(address token)` - Remover Soporte de Token**
```solidity
function removeToken(address token) external onlyRole(ADMIN_ROLE)
```
**¿Qué hace?**
- Verifica permisos de administrador
- Elimina token de la lista de soportados
- Previene remover ETH nativo
- Emite evento `TokenRemoved`

**¿Por qué es importante?**
- Permite remover tokens problemáticos o descontinuados
- Mantiene flexibilidad en la gestión de tokens

### 🚨 **Funciones de Emergencia**

#### **`emergencyPause()` - Pausar Sistema**
```solidity
function emergencyPause() external onlyRole(EMERGENCY_ROLE)
```
**¿Qué hace?**
- Verifica que el llamador tenga `EMERGENCY_ROLE`
- Activa la pausa global del sistema
- Previene nuevos depósitos y retiros
- Emite evento `EmergencyPauseToggled`

**¿Por qué es importante?**
- Proporciona circuit breaker en caso de exploits o problemas
- Permite respuesta rápida a emergencias

#### **`emergencyUnpause()` - Reanudar Sistema**
```solidity
function emergencyUnpause() external onlyRole(EMERGENCY_ROLE)
```
**¿Qué hace?**
- Desactiva la pausa del sistema
- Permite resumir operaciones normales
- Solo ejecutable por usuarios con `EMERGENCY_ROLE`

**¿Por qué es importante?**
- Permite reanudar operaciones después de resolver problemas
- Mantiene control granular sobre el estado del sistema

## 👨‍🏫 **SECCIÓN PARA EL INSTRUCTOR**

### 📚 **Implementaciones del Módulo 3 Requeridas**

#### 🔐 **1. Control de Acceso: OpenZeppelin AccessControl**

**📍 UBICACIÓN EN EL CÓDIGO:**
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