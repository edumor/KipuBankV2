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