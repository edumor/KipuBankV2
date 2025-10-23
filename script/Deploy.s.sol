// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {KipuBankV2} from "../src/KipuBankV2.sol";

/**
 * @title Deploy KipuBankV2
 * @notice Script para desplegar KipuBankV2 en diferentes redes
 * @dev Uso: forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
 */
contract Deploy is Script {
    // Chainlink Price Feeds
    address constant ETH_USD_SEPOLIA = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address constant ETH_USD_MAINNET = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    
    // Deployment parameters
    uint256 constant TOTAL_CAP_USD = 1_000_000e6;        // $1M cap
    uint256 constant WITHDRAWAL_LIMIT_USD = 10_000e6;    // $10K limit

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("Deploying KipuBankV2 with deployer:", deployer);
        console2.log("Chain ID:", block.chainid);
        
        // Get appropriate price feed based on chain
        address ethPriceFeed = getEthPriceFeed();
        console2.log("Using ETH/USD Price Feed:", ethPriceFeed);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy KipuBankV2
        KipuBankV2 kipuBank = new KipuBankV2{salt: "KipuBankV2"}(
            TOTAL_CAP_USD,
            WITHDRAWAL_LIMIT_USD,
            deployer, // Admin address
            ethPriceFeed
        );
        
        vm.stopBroadcast();
        
        console2.log("");
        console2.log("=== DEPLOYMENT SUCCESSFUL ===");
        console2.log("KipuBankV2 Address:", address(kipuBank));
        console2.log("Total Cap USD:", TOTAL_CAP_USD / 1e6, "USD");
        console2.log("Withdrawal Limit USD:", WITHDRAWAL_LIMIT_USD / 1e6, "USD");
        console2.log("Admin Address:", deployer);
        console2.log("ETH Price Feed:", ethPriceFeed);
        console2.log("");
        console2.log("Next steps:");
        console2.log("1. Verify contract on Etherscan");
        console2.log("2. Add additional supported tokens if needed");
        console2.log("3. Test deposit/withdrawal functionality");
        
        // Verify deployment by reading some values
        console2.log("");
        console2.log("=== DEPLOYMENT VERIFICATION ===");
        console2.log("TOTAL_CAP_USD:", kipuBank.TOTAL_CAP_USD());
        console2.log("WITHDRAWAL_LIMIT_USD:", kipuBank.WITHDRAWAL_LIMIT_USD());
        console2.log("ETH_TOKEN supported:", kipuBank.isTokenSupported(address(0)));
        
        (, uint256 totalCapUSD, uint256 withdrawalLimitUSD) = kipuBank.getBankInfo();
        console2.log("Bank Info - Cap:", totalCapUSD, "Limit:", withdrawalLimitUSD);
    }
    
    function getEthPriceFeed() internal view returns (address) {
        if (block.chainid == 1) {
            // Ethereum Mainnet
            return ETH_USD_MAINNET;
        } else if (block.chainid == 11155111) {
            // Sepolia Testnet
            return ETH_USD_SEPOLIA;
        } else {
            revert("Unsupported chain - add price feed address for this network");
        }
    }
}