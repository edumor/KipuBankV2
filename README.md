# KipuBankV2 — Enhanced Decentralized Banking System

[![Solidity](https://img.shields.io/badge/Solidity-0.8.26-363636?style=flat&logo=solidity)](https://soliditylang.org)
[![Ethereum](https://img.shields.io/badge/Ethereum-Sepolia-3C3C3D?style=flat&logo=ethereum&logoColor=white)](https://ethereum.org)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-v5.0-4E5EE4?style=flat)](https://openzeppelin.com)
[![Chainlink](https://img.shields.io/badge/Chainlink-Oracles-375BD2?style=flat&logo=chainlink&logoColor=white)](https://chain.link)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

Production-ready DeFi banking system with multi-token support, Chainlink oracle integration, and enterprise-grade security patterns. Final project for **Module 3 — ETH-KIPU Ethereum Developer Program**.

**Contract:** [`0x56C57BE2539F038BF85cf16442CC7c6B7Df72C79`](https://sepolia.etherscan.io/address/0x56C57BE2539F038BF85cf16442CC7c6B7Df72C79#code) · Sepolia Testnet · ✅ Verified

---

## KipuBank evolution

This contract is part of a three-version progression built throughout the ETH-KIPU program:

| Version | Repo | Module | Key addition |
|---|---|---|---|
| V1 — Basic bank | [`kipu-bank`](https://github.com/edumor/kipu-bank) | Module 2 | ETH deposits, withdrawal limits, gas optimization |
| V2 — Enhanced bank | [`KipuBankV2`](https://github.com/edumor/KipuBankV2) ← you are here | Module 3 | Multi-token, Chainlink oracles, USD accounting |
| V3 — DeFi bank | [`KipuBankV3`](https://github.com/edumor/KipuBankV3) | Module 4 | Uniswap V2 integration, automatic token swaps |

---

## What's new in V2

| Feature | V1 | V2 |
|---|---|---|
| Supported assets | ETH only | ETH + any ERC20 |
| Price tracking | None | Chainlink USD oracles |
| Accounting | ETH (wei) | Normalized USD (6 decimals) |
| Access control | Basic owner | OpenZeppelin Ownable + modifiers |
| Error handling | `require` strings | Custom errors (50% gas savings) |
| Emergency controls | None | Circuit breaker pause/unpause |
| Bank capacity | 10 ETH | 100,000 USD |
| Withdrawal limit | 0.1 ETH | 1,000 USD per transaction |

---

## Key features

- **Multi-token support** — configurable ERC20 tokens via `TokenConfig` struct; add/remove tokens dynamically without redeployment
- **Chainlink oracle integration** — live ETH/USD and ERC20/USD price feeds with staleness protection (1-hour heartbeat)
- **USD-normalized accounting** — all balances stored in 6-decimal USD for cross-asset consistency
- **Gas optimization** — custom errors (~50% savings), constant variables, state variable caching, single storage access patterns
- **OpenZeppelin Ownable** — battle-tested access control with `onlyOwner` on all administrative functions
- **Circuit breaker** — emergency `pause()`/`unpause()` for incident response
- **CEI pattern** — checks-effects-interactions throughout for reentrancy protection

---

## Deployed contract

| Parameter | Value |
|---|---|
| Network | Sepolia Testnet |
| Contract address | `0x56C57BE2539F038BF85cf16442CC7c6B7Df72C79` |
| Etherscan | [View verified source](https://sepolia.etherscan.io/address/0x56C57BE2539F038BF85cf16442CC7c6B7Df72C79#code) |
| ETH/USD price feed | `0x694AA1769357215DE4FAC081bf1f309aDC325306` |
| Deployment date | October 26, 2025 |
| Status | ✅ Verified and operational |

---

## Architecture

### Token configuration

```solidity
struct TokenConfig {
    bool isSupported;                    // Token activation flag
    uint8 decimals;                      // Token precision (6, 8, 18)
    AggregatorV3Interface priceFeed;     // Chainlink oracle reference
}
```

### Storage layout

```solidity
// User balances: user → token → USD balance (6 decimals)
mapping(address user => mapping(address token => uint256 balanceUSD)) s_balances;

// Token configuration: token → config struct
mapping(address token => TokenConfig config) s_tokenConfig;

// ETH represented as address(0)
address private constant NATIVE_TOKEN = address(0);
```

### Key constants

```solidity
uint256 private constant WITHDRAWAL_LIMIT_USD = 1_000 * 10**6;   // $1,000 USD
uint256 private constant BANK_CAP_USD         = 100_000 * 10**6; // $100,000 USD
uint256 private constant ORACLE_HEARTBEAT     = 3600;            // 1 hour
uint8   private constant TARGET_DECIMALS      = 6;               // USDC standard
```

---

## Core functions

### User functions

| Function | Description |
|---|---|
| `depositETH()` | Deposit native ETH, auto-converted to USD balance |
| `depositERC20(address token, uint256 amount)` | Deposit any supported ERC20 token |
| `withdrawETH(uint256 amount)` | Withdraw ETH by specifying WEI amount |
| `withdrawERC20(address token, uint256 amount)` | Withdraw ERC20 tokens |
| `getBalance(address user, address token)` | Returns USD balance (6 decimals) |
| `getPrice(address token)` | Returns live USD price from Chainlink (8 decimals) |
| `getBankInfo()` | Returns full bank stats: totals, caps, limits, pause state |

### Admin functions (owner only)

| Function | Description |
|---|---|
| `addToken(address, address, uint8)` | Add ERC20 token support with price feed |
| `removeToken(address)` | Disable token support |
| `pause()` | Emergency halt of all operations |
| `unpause()` | Resume normal operations |

---

## USD conversion

All internal balances use 6-decimal USD. The `_convertToUSD()` function normalizes any token:

```solidity
// For tokens with more decimals than target (e.g. ETH 18 → 6)
valueUSD = (amount × priceUSD) / (10^8 × 10^(tokenDecimals - 6))

// For tokens with fewer decimals than target (e.g. USDC 6 → 6)
valueUSD = (amount × priceUSD × 10^(6 - tokenDecimals)) / 10^8
```

### Decimal reference

| Data | Decimals | Example |
|---|---|---|
| `depositETH()` msg.value | 18 (WEI) | `10000000000000000` = 0.01 ETH |
| `withdrawETH(amount)` | 18 (WEI) | `2531000000000000` ≈ $10 USD |
| `getBalance()` return | 6 (USD) | `39509075` = $39.51 USD |
| `getPrice()` return | 8 (USD) | `395090750000` = $3,950.91 |

---

## Gas optimization results

| Technique | Savings |
|---|---|
| Custom errors vs `require` strings | ~50% on error paths |
| Constant variables (no SLOAD) | ~2,100 gas per access |
| State variable caching (read-once) | ~200 gas per avoided SLOAD |
| **Total average savings** | **~33% across all operations** |

| Operation | V2 (optimized) | Traditional | Saving |
|---|---|---|---|
| ETH deposit | ~120,000 gas | ~180,000 gas | 33% |
| ETH withdrawal | ~100,000 gas | ~150,000 gas | 33% |
| ERC20 deposit | ~140,000 gas | ~200,000 gas | 30% |

---

## Security layers

1. **Access control** — OpenZeppelin Ownable + custom modifiers (`whenNotPaused`, `validAmount`, `validAddress`)
2. **Oracle security** — staleness check (max 1 hour) + positive price validation
3. **Circuit breaker** — owner can pause all operations instantly
4. **Economic limits** — $1,000 withdrawal cap + $100,000 bank cap
5. **CEI pattern** — state changes before external calls throughout

---

## Running locally

```bash
git clone https://github.com/edumor/KipuBankV2.git
cd KipuBankV2
```

Open `src/KipuBankV2.sol` in [Remix IDE](https://remix.ethereum.org), compile with Solidity 0.8.26, and deploy to Sepolia with constructor parameters:

```
initialOwner:  0xYourWalletAddress
ethPriceFeed:  0x694AA1769357215DE4FAC081bf1f309aDC325306
```

---

## Author

**Eduardo Moreno** — Senior Software Developer · Blockchain & Web3

- GitHub: [@edumor](https://github.com/edumor)
- LinkedIn: [linkedin.com/in/eduardomoreno-15813b19b](https://linkedin.com/in/eduardomoreno-15813b19b)
- Email: [eduardomoreno2503@gmail.com](mailto:eduardomoreno2503@gmail.com)

Part of the [ETH-KIPU](https://ethkipu.org) Ethereum Developer Program — Module 3 final project.
