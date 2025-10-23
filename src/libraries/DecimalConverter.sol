// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DecimalConverter
 * @notice Library for converting between different decimal representations
 * @dev Handles decimal conversions for multi-token accounting with price feeds
 */
library DecimalConverter {
    
    /// @notice Converts amount from source decimals to target decimals with price
    /// @param amount Amount in source decimals
    /// @param sourceDecimals Decimals of the source token
    /// @param targetDecimals Decimals of the target representation
    /// @param price Price from oracle (price decimals)
    /// @param priceDecimals Decimals of the price feed
    /// @return convertedAmount Amount in target decimals
    function convertToTargetDecimals(
        uint256 amount,
        uint8 sourceDecimals,
        uint8 targetDecimals,
        uint256 price,
        uint8 priceDecimals
    ) internal pure returns (uint256 convertedAmount) {
        // Convert amount to 18 decimals for intermediate calculations
        uint256 normalizedAmount = _normalizeToDecimals(amount, sourceDecimals, 18);
        
        // Apply price (price is in priceDecimals, normalize to 18 decimals)
        uint256 normalizedPrice = _normalizeToDecimals(price, priceDecimals, 18);
        uint256 valueIn18Decimals = (normalizedAmount * normalizedPrice) / 1e18;
        
        // Convert to target decimals
        return _normalizeToDecimals(valueIn18Decimals, 18, targetDecimals);
    }
    
    /// @notice Converts amount from target decimals back to source decimals with price
    /// @param amount Amount in target decimals
    /// @param targetDecimals Decimals of the target representation
    /// @param sourceDecimals Decimals of the source token
    /// @param price Price from oracle (price decimals)
    /// @param priceDecimals Decimals of the price feed
    /// @return convertedAmount Amount in source decimals
    function convertFromTargetDecimals(
        uint256 amount,
        uint8 targetDecimals,
        uint8 sourceDecimals,
        uint256 price,
        uint8 priceDecimals
    ) internal pure returns (uint256 convertedAmount) {
        // Convert amount to 18 decimals for intermediate calculations
        uint256 normalizedAmount = _normalizeToDecimals(amount, targetDecimals, 18);
        
        // Apply inverse price (divide by price)
        uint256 normalizedPrice = _normalizeToDecimals(price, priceDecimals, 18);
        uint256 valueIn18Decimals = (normalizedAmount * 1e18) / normalizedPrice;
        
        // Convert to source decimals
        return _normalizeToDecimals(valueIn18Decimals, 18, sourceDecimals);
    }
    
    /// @notice Normalizes amount from source decimals to target decimals
    /// @param amount Amount in source decimals
    /// @param sourceDecimals Source decimal places
    /// @param targetDecimals Target decimal places
    /// @return normalizedAmount Amount in target decimals
    function _normalizeToDecimals(
        uint256 amount,
        uint8 sourceDecimals,
        uint8 targetDecimals
    ) private pure returns (uint256 normalizedAmount) {
        if (sourceDecimals == targetDecimals) {
            return amount;
        }
        
        if (sourceDecimals < targetDecimals) {
            // Scale up
            uint8 decimalDiff = targetDecimals - sourceDecimals;
            return amount * (10 ** decimalDiff);
        } else {
            // Scale down
            uint8 decimalDiff = sourceDecimals - targetDecimals;
            return amount / (10 ** decimalDiff);
        }
    }
    
    /// @notice Calculates percentage of an amount
    /// @param amount Base amount
    /// @param percentage Percentage in basis points (10000 = 100%)
    /// @return result Calculated percentage amount
    function calculatePercentage(
        uint256 amount,
        uint256 percentage
    ) internal pure returns (uint256 result) {
        return (amount * percentage) / 10000;
    }
    
    /// @notice Safely adds two amounts checking for overflow
    /// @param a First amount
    /// @param b Second amount
    /// @return sum Sum of both amounts
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 sum) {
        sum = a + b;
        require(sum >= a, "DecimalConverter: Addition overflow");
        return sum;
    }
    
    /// @notice Safely subtracts two amounts checking for underflow
    /// @param a Minuend
    /// @param b Subtrahend
    /// @return difference Difference of both amounts
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256 difference) {
        require(a >= b, "DecimalConverter: Subtraction underflow");
        return a - b;
    }
}