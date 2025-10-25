// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KipuBankV2 - Test Version for Remix Deployment
 * @author Eduardo Moreno
 */

// Simple test contract to verify deployment works
contract KipuBankV2Test {
    
    uint256 public immutable WITHDRAWAL_LIMIT_USD;
    uint256 public immutable BANK_CAP_USD;
    address public immutable ethUsdPriceFeed;
    
    constructor(
        uint256 _withdrawalLimitUSD,
        uint256 _bankCapUSD,
        address _ethUsdPriceFeed
    ) {
        WITHDRAWAL_LIMIT_USD = _withdrawalLimitUSD;
        BANK_CAP_USD = _bankCapUSD;
        ethUsdPriceFeed = _ethUsdPriceFeed;
    }
    
    function getInfo() external view returns (uint256, uint256, address) {
        return (WITHDRAWAL_LIMIT_USD, BANK_CAP_USD, ethUsdPriceFeed);
    }
}