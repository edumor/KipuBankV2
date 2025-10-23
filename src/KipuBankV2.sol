// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IKipuBankV2.sol";
import "./libraries/DecimalConverter.sol";

/**
 * @title KipuBankV2
 * @author Eduardo Moreno
 * @notice Advanced bank contract supporting multi-token deposits/withdrawals with Chainlink price feeds
 * @dev Implements role-based access control, multi-token support, and USD-based global limits
 * @custom:version 2.0.0
 */
contract KipuBankV2 is IKipuBankV2, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using DecimalConverter for uint256;

    // ============ CONSTANTS ============
    
    /// @notice Role identifier for admin functions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Role identifier for emergency functions
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    /// @notice USDC token decimals for internal accounting
    uint8 public constant USDC_DECIMALS = 6;
    
    /// @notice Native ETH token representation
    address public constant NATIVE_TOKEN = address(0);
    
    /// @notice Minimum deposit amount in USD (1 USD)
    uint256 public constant MIN_DEPOSIT_USD = 1 * 10**USDC_DECIMALS;

    // ============ IMMUTABLE VARIABLES ============
    
    /// @notice Maximum withdrawal limit per transaction in USD
    uint256 public immutable WITHDRAWAL_LIMIT_USD;
    
    /// @notice Total bank capacity limit in USD
    uint256 public immutable BANK_CAP_USD;
    
    /// @notice Chainlink ETH/USD price feed aggregator
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    // ============ STATE VARIABLES ============
    
    /// @notice Total value deposited in USD (6 decimals)
    uint256 public totalDepositedUSD;
    
    /// @notice Total number of deposits made
    uint256 public totalDeposits;
    
    /// @notice Total number of withdrawals made
    uint256 public totalWithdrawals;
    
    /// @notice Emergency pause state
    bool public emergencyPaused;
    
    /// @notice Set of supported ERC20 tokens
    mapping(address => TokenInfo) public supportedTokens;
    
    /// @notice Nested mapping: user => token => balance (in USDC decimals)
    mapping(address => mapping(address => uint256)) public userBalances;
    
    /// @notice User total balance in USD
    mapping(address => uint256) public userTotalBalanceUSD;

    // ============ TYPES ============
    
    /// @notice Token information structure
    struct TokenInfo {
        bool isSupported;
        uint8 decimals;
        AggregatorV3Interface priceFeed;
        string symbol;
    }

    // ============ CUSTOM ERRORS ============
    
    error ZeroAmount();
    error TokenNotSupported(address token);
    error ExceedsBankCap(uint256 requested, uint256 available);
    error ExceedsWithdrawalLimit(uint256 requested, uint256 limit);
    error InsufficientBalance(uint256 requested, uint256 available);
    error TransferFailed();
    error EmergencyPaused();
    error InvalidPriceFeed();
    error PriceDataStale();

    // ============ MODIFIERS ============
    
    /// @notice Ensures contract is not in emergency pause
    modifier whenNotPaused() {
        if (emergencyPaused) revert EmergencyPaused();
        _;
    }
    
    /// @notice Validates that amount is greater than zero
    modifier validAmount(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }
    
    /// @notice Validates that token is supported
    modifier onlySupportedToken(address token) {
        if (!supportedTokens[token].isSupported) revert TokenNotSupported(token);
        _;
    }

    // ============ CONSTRUCTOR ============
    
    /// @notice Initializes KipuBankV2 with specified parameters
    /// @param _withdrawalLimitUSD Maximum withdrawal limit per transaction in USD (6 decimals)
    /// @param _bankCapUSD Total bank capacity limit in USD (6 decimals)
    /// @param _ethUsdPriceFeed Chainlink ETH/USD price feed address
    constructor(
        uint256 _withdrawalLimitUSD,
        uint256 _bankCapUSD,
        address _ethUsdPriceFeed
    ) {
        WITHDRAWAL_LIMIT_USD = _withdrawalLimitUSD;
        BANK_CAP_USD = _bankCapUSD;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        
        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        
        // Add native ETH support
        supportedTokens[NATIVE_TOKEN] = TokenInfo({
            isSupported: true,
            decimals: 18,
            priceFeed: ethUsdPriceFeed,
            symbol: "ETH"
        });
        
        emit TokenAdded(NATIVE_TOKEN, "ETH", 18);
    }

    // ============ EXTERNAL FUNCTIONS ============
    
    /// @notice Deposits native ETH into the bank
    function depositETH() 
        external 
        payable 
        whenNotPaused 
        validAmount(msg.value) 
        nonReentrant 
    {
        _deposit(NATIVE_TOKEN, msg.value, msg.value);
    }
    
    /// @notice Deposits ERC20 tokens into the bank
    /// @param token Address of the ERC20 token
    /// @param amount Amount of tokens to deposit
    function depositToken(address token, uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        onlySupportedToken(token) 
        nonReentrant 
    {
        if (token == NATIVE_TOKEN) revert TokenNotSupported(token);
        
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _deposit(token, amount, 0);
    }
    
    /// @notice Withdraws native ETH from the bank
    /// @param amount Amount to withdraw in ETH
    function withdrawETH(uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        nonReentrant 
    {
        _withdraw(NATIVE_TOKEN, amount);
    }
    
    /// @notice Withdraws ERC20 tokens from the bank
    /// @param token Address of the ERC20 token
    /// @param amount Amount of tokens to withdraw
    function withdrawToken(address token, uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        onlySupportedToken(token) 
        nonReentrant 
    {
        if (token == NATIVE_TOKEN) revert TokenNotSupported(token);
        _withdraw(token, amount);
    }

    // ============ VIEW FUNCTIONS ============
    
    /// @notice Gets user balance for a specific token in USD
    /// @param user User address
    /// @param token Token address
    /// @return Balance in USD (6 decimals)
    function getUserBalance(address user, address token) external view returns (uint256) {
        return userBalances[user][token];
    }
    
    /// @notice Gets user total balance across all tokens in USD
    /// @param user User address
    /// @return Total balance in USD (6 decimals)
    function getUserTotalBalance(address user) external view returns (uint256) {
        return userTotalBalanceUSD[user];
    }
    
    /// @notice Gets current ETH price in USD
    /// @return price ETH price in USD (8 decimals)
    function getETHPrice() public view returns (uint256 price) {
        (, int256 answer, , uint256 updatedAt,) = ethUsdPriceFeed.latestRoundData();
        
        if (answer <= 0) revert InvalidPriceFeed();
        if (block.timestamp - updatedAt > 3600) revert PriceDataStale(); // 1 hour staleness
        
        return uint256(answer);
    }
    
    /// @notice Gets token price in USD
    /// @param token Token address
    /// @return price Token price in USD (8 decimals)
    function getTokenPrice(address token) public view returns (uint256 price) {
        if (!supportedTokens[token].isSupported) revert TokenNotSupported(token);
        
        if (token == NATIVE_TOKEN) {
            return getETHPrice();
        }
        
        AggregatorV3Interface priceFeed = supportedTokens[token].priceFeed;
        (, int256 answer, , uint256 updatedAt,) = priceFeed.latestRoundData();
        
        if (answer <= 0) revert InvalidPriceFeed();
        if (block.timestamp - updatedAt > 3600) revert PriceDataStale();
        
        return uint256(answer);
    }
    
    /// @notice Converts token amount to USD value
    /// @param token Token address
    /// @param amount Token amount
    /// @return usdValue Value in USD (6 decimals)
    function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue) {
        uint256 tokenPrice = getTokenPrice(token);
        uint8 tokenDecimals = supportedTokens[token].decimals;
        
        return amount.convertToTargetDecimals(tokenDecimals, USDC_DECIMALS, tokenPrice, 8);
    }
    
    /// @notice Converts USD amount to token amount
    /// @param token Token address
    /// @param usdAmount USD amount (6 decimals)
    /// @return tokenAmount Token amount
    function convertFromUSD(address token, uint256 usdAmount) public view returns (uint256 tokenAmount) {
        uint256 tokenPrice = getTokenPrice(token);
        uint8 tokenDecimals = supportedTokens[token].decimals;
        
        return usdAmount.convertFromTargetDecimals(USDC_DECIMALS, tokenDecimals, tokenPrice, 8);
    }
    
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
    ) {
        return (
            totalDepositedUSD,
            totalDeposits,
            totalWithdrawals,
            BANK_CAP_USD,
            WITHDRAWAL_LIMIT_USD,
            emergencyPaused
        );
    }

    // ============ ADMIN FUNCTIONS ============
    
    /// @notice Adds support for a new ERC20 token
    /// @param token Token contract address
    /// @param symbol Token symbol
    /// @param decimals Token decimals
    /// @param priceFeed Chainlink price feed for the token
    function addToken(
        address token,
        string memory symbol,
        uint8 decimals,
        address priceFeed
    ) external onlyRole(ADMIN_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenNotSupported(token);
        
        supportedTokens[token] = TokenInfo({
            isSupported: true,
            decimals: decimals,
            priceFeed: AggregatorV3Interface(priceFeed),
            symbol: symbol
        });
        
        emit TokenAdded(token, symbol, decimals);
    }
    
    /// @notice Removes support for an ERC20 token
    /// @param token Token contract address
    function removeToken(address token) external onlyRole(ADMIN_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenNotSupported(token);
        
        delete supportedTokens[token];
        emit TokenRemoved(token);
    }
    
    /// @notice Emergency pause function
    function emergencyPause() external onlyRole(EMERGENCY_ROLE) {
        emergencyPaused = true;
        emit EmergencyPauseToggled(true);
    }
    
    /// @notice Emergency unpause function
    function emergencyUnpause() external onlyRole(EMERGENCY_ROLE) {
        emergencyPaused = false;
        emit EmergencyPauseToggled(false);
    }

    // ============ INTERNAL FUNCTIONS ============
    
    /// @notice Internal deposit logic
    /// @param token Token address
    /// @param amount Token amount
    /// @param ethValue ETH value for native deposits
    function _deposit(address token, uint256 amount, uint256 ethValue) internal {
        uint256 usdValue = convertToUSD(token, amount);
        
        // Check minimum deposit
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        // Check bank capacity
        if (totalDepositedUSD + usdValue > BANK_CAP_USD) {
            revert ExceedsBankCap(usdValue, BANK_CAP_USD - totalDepositedUSD);
        }
        
        // Update balances
        userBalances[msg.sender][token] += usdValue;
        userTotalBalanceUSD[msg.sender] += usdValue;
        totalDepositedUSD += usdValue;
        totalDeposits++;
        
        emit Deposit(msg.sender, token, amount, usdValue, userBalances[msg.sender][token]);
    }
    
    /// @notice Internal withdrawal logic
    /// @param token Token address
    /// @param amount Token amount to withdraw
    function _withdraw(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        
        // Check withdrawal limit
        if (usdValue > WITHDRAWAL_LIMIT_USD) {
            revert ExceedsWithdrawalLimit(usdValue, WITHDRAWAL_LIMIT_USD);
        }
        
        // Check user balance
        uint256 currentBalance = userBalances[msg.sender][token];
        if (usdValue > currentBalance) {
            revert InsufficientBalance(usdValue, currentBalance);
        }
        
        // Update balances
        userBalances[msg.sender][token] -= usdValue;
        userTotalBalanceUSD[msg.sender] -= usdValue;
        totalDepositedUSD -= usdValue;
        totalWithdrawals++;
        
        // Transfer tokens
        if (token == NATIVE_TOKEN) {
            _safeTransferETH(msg.sender, amount);
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
        
        emit Withdrawal(msg.sender, token, amount, usdValue, userBalances[msg.sender][token]);
    }
    
    /// @notice Safe ETH transfer function
    /// @param to Recipient address
    /// @param amount Amount to transfer
    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert TransferFailed();
    }
}