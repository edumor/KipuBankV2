// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IKipuBankV2
 * @notice Interface for KipuBankV2 contract
 * @dev Defines the external functions and events for the multi-token bank
 */
interface IKipuBankV2 {
    
    // ============ EVENTS ============
    
    /// @notice Emitted when a user makes a deposit
    /// @param user Address of the user making the deposit
    /// @param token Address of the deposited token (address(0) for ETH)
    /// @param tokenAmount Amount deposited in token units
    /// @param usdValue USD value of the deposit (6 decimals)
    /// @param newBalance New USD balance of the user for this token
    event Deposit(
        address indexed user, 
        address indexed token, 
        uint256 tokenAmount, 
        uint256 usdValue, 
        uint256 newBalance
    );
    
    /// @notice Emitted when a user makes a withdrawal
    /// @param user Address of the user making the withdrawal
    /// @param token Address of the withdrawn token (address(0) for ETH)
    /// @param tokenAmount Amount withdrawn in token units
    /// @param usdValue USD value of the withdrawal (6 decimals)
    /// @param newBalance New USD balance of the user for this token
    event Withdrawal(
        address indexed user, 
        address indexed token, 
        uint256 tokenAmount, 
        uint256 usdValue, 
        uint256 newBalance
    );
    
    /// @notice Emitted when a new token is added to the bank
    /// @param token Address of the new token
    /// @param symbol Symbol of the token
    /// @param decimals Decimals of the token
    event TokenAdded(address indexed token, string symbol, uint8 decimals);
    
    /// @notice Emitted when a token is removed from the bank
    /// @param token Address of the removed token
    event TokenRemoved(address indexed token);
    
    /// @notice Emitted when emergency pause is toggled
    /// @param paused New pause state
    event EmergencyPauseToggled(bool paused);
    
    // ============ DEPOSIT FUNCTIONS ============
    
    /// @notice Deposits native ETH into the bank
    function depositETH() external payable;
    
    /// @notice Deposits ERC20 tokens into the bank
    /// @param token Address of the ERC20 token
    /// @param amount Amount of tokens to deposit
    function depositToken(address token, uint256 amount) external;
    
    // ============ WITHDRAWAL FUNCTIONS ============
    
    /// @notice Withdraws native ETH from the bank
    /// @param amount Amount to withdraw in ETH
    function withdrawETH(uint256 amount) external;
    
    /// @notice Withdraws ERC20 tokens from the bank
    /// @param token Address of the ERC20 token
    /// @param amount Amount of tokens to withdraw
    function withdrawToken(address token, uint256 amount) external;
    
    // ============ VIEW FUNCTIONS ============
    
    /// @notice Gets user balance for a specific token in USD
    /// @param user User address
    /// @param token Token address
    /// @return Balance in USD (6 decimals)
    function getUserBalance(address user, address token) external view returns (uint256);
    
    /// @notice Gets user total balance across all tokens in USD
    /// @param user User address
    /// @return Total balance in USD (6 decimals)
    function getUserTotalBalance(address user) external view returns (uint256);
    
    /// @notice Gets current ETH price in USD
    /// @return price ETH price in USD (8 decimals)
    function getETHPrice() external view returns (uint256 price);
    
    /// @notice Gets token price in USD
    /// @param token Token address
    /// @return price Token price in USD (8 decimals)
    function getTokenPrice(address token) external view returns (uint256 price);
    
    /// @notice Converts token amount to USD value
    /// @param token Token address
    /// @param amount Token amount
    /// @return usdValue Value in USD (6 decimals)
    function convertToUSD(address token, uint256 amount) external view returns (uint256 usdValue);
    
    /// @notice Converts USD amount to token amount
    /// @param token Token address
    /// @param usdAmount USD amount (6 decimals)
    /// @return tokenAmount Token amount
    function convertFromUSD(address token, uint256 usdAmount) external view returns (uint256 tokenAmount);
    
    /// @notice Gets comprehensive bank information
    /// @return totalDepUSD Total deposited in USD
    /// @return totalDeps Total number of deposits
    /// @return totalWiths Total number of withdrawals
    /// @return bankCapUSD Bank capacity in USD
    /// @return withdrawLimitUSD Withdrawal limit in USD
    /// @return paused Emergency pause status
    function getBankInfo() external view returns (
        uint256 totalDepUSD,
        uint256 totalDeps,
        uint256 totalWiths,
        uint256 bankCapUSD,
        uint256 withdrawLimitUSD,
        bool paused
    );
}