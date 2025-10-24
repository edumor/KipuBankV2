// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {KipuBankV2} from "../contracts/KipuBankV2.sol";

/**
 * @title Deploy Script para KipuBankV2
 * @author Eduardo Moreno
 * @notice Script de despliegue para el contrato KipuBankV2 en Sepolia
 */
contract DeployKipuBankV2 is Script {
    
    // Configuración para Sepolia
    uint256 public constant WITHDRAWAL_LIMIT_USD = 10_000 * 1e6; // $10,000 USD
    uint256 public constant BANK_CAP_USD = 1_000_000 * 1e6; // $1,000,000 USD
    address public constant SEPOLIA_ETH_USD_FEED = 0x694AA1769357215DE4fac081bf1f309aDC325306;
    
    function run() external returns (KipuBankV2) {
        vm.startBroadcast();
        
        KipuBankV2 kipuBank = new KipuBankV2(
            WITHDRAWAL_LIMIT_USD,
            BANK_CAP_USD,
            SEPOLIA_ETH_USD_FEED
        );
        
        vm.stopBroadcast();
        
        return kipuBank;
    }
}