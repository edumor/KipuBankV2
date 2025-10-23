// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ============ IMPORTS ============
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title KipuBankV2
 * @author Eduardo Moreno
 * @notice Advanced banking contract with multi-token support and Chainlink price feeds
 * @dev Implements role-based access control, single state reads, and short error strings
 * @custom:security Follows CEI pattern, uses ReentrancyGuard, single storage access per function
 * @custom:version 2.0.0
 */
contract KipuBankV2 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ CONSTANTS ============
    
    /// @notice Role identifier for main admin functions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Role identifier for emergency pause functions
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    /// @notice Native ETH token representation
    address public constant NATIVE_TOKEN = address(0);
    
    /// @notice Minimum deposit amount in USD (1 USD with 6 decimals)
    uint256 public constant MIN_DEPOSIT_USD = 1e6;

    // ============ IMMUTABLE VARIABLES ============
    
    /// @notice Maximum withdrawal limit per transaction in USD (6 decimals)
    uint256 public immutable WITHDRAWAL_LIMIT_USD;
    
    /// @notice Total bank capacity limit in USD (6 decimals)
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
    
    /// @notice Mapping of supported tokens to their information
    mapping(address => TokenInfo) public supportedTokens;
    
    /// @notice Nested mapping: user => token => balance (in USD with 6 decimals)
    mapping(address => mapping(address => uint256)) public userBalances;
    
    /// @notice User total balance in USD (6 decimals)
    mapping(address => uint256) public userTotalBalanceUSD;

    // ============ STRUCTS ============
    
    /// @notice Token information structure
    struct TokenInfo {
        bool isSupported;
        uint8 decimals;
        AggregatorV3Interface priceFeed;
        string symbol;
    }

    // ============ EVENTS ============
    
    /// @notice Emitted when a user deposits tokens
    event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
    
    /// @notice Emitted when a user withdraws tokens
    event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
    
    /// @notice Emitted when a new token is added
    event TokenAdded(address indexed token, string symbol, uint8 decimals);
    
    /// @notice Emitted when a token is removed
    event TokenRemoved(address indexed token);
    
    /// @notice Emitted when emergency pause is toggled
    event EmergencyPauseToggled(bool paused);

    // ============ CUSTOM ERRORS ============
    
    /// @notice Error when amount is zero
    error ZeroAmount();
    
    /// @notice Error when token is not supported
    error TokenNotSupported();
    
    /// @notice Error when deposit exceeds bank capacity
    error CapExceeded();
    
    /// @notice Error when withdrawal exceeds limit
    error LimitExceeded();
    
    /// @notice Error when user has insufficient balance
    error LowBalance();
    
    /// @notice Error when transfer fails
    error TransferFailed();
    
    /// @notice Error when contract is paused
    error Paused();
    
    /// @notice Error when price feed is invalid
    error BadPriceFeed();
    
    /// @notice Error when price data is stale
    error StalePrice();

    // ============ MODIFIERS ============
    
    /// @notice Ensures contract is not in emergency pause
    modifier whenNotPaused() {
        if (emergencyPaused) revert Paused();
        _;
    }
    
    /// @notice Validates that amount is greater than zero
    modifier validAmount(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }
    
    /// @notice Validates that token is supported
    modifier onlySupportedToken(address token) {
        if (!supportedTokens[token].isSupported) revert TokenNotSupported();
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
        _deposit(NATIVE_TOKEN, msg.value);
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
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _deposit(token, amount);
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
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
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
    
    /// @notice Gets current ETH price in USD from Chainlink feed
    /// @return price ETH price in USD with 8 decimals
    function getETHPrice() public view returns (uint256 price) {
        (, int256 answer, , uint256 updatedAt,) = ethUsdPriceFeed.latestRoundData();
        
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > 3600) revert StalePrice();
        
        return uint256(answer);
    }
    
    /// @notice Gets token price in USD from Chainlink feed
    /// @param token Token address
    /// @return price Token price in USD with 8 decimals
    function getTokenPrice(address token) public view returns (uint256 price) {
        if (!supportedTokens[token].isSupported) revert TokenNotSupported();
        
        if (token == NATIVE_TOKEN) {
            return getETHPrice();
        }
        
        AggregatorV3Interface priceFeed = supportedTokens[token].priceFeed;
        (, int256 answer, , uint256 updatedAt,) = priceFeed.latestRoundData();
        
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > 3600) revert StalePrice();
        
        return uint256(answer);
    }
    
    /// @notice Converts token amount to USD value with proper decimal handling
    /// @param token Token address
    /// @param amount Token amount
    /// @return usdValue Value in USD with 6 decimals
    function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue) {
        uint256 tokenPrice = getTokenPrice(token);
        uint8 tokenDecimals = supportedTokens[token].decimals;
        
        // Convert: (amount * price) / (10^tokenDecimals * 10^8 / 10^6)
        // Simplified: (amount * price) / (10^(tokenDecimals + 2))
        return (amount * tokenPrice) / (10 ** (tokenDecimals + 2));
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
    
    /// @notice Adds support for a new ERC20 token (ADMIN_ROLE only)
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
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        supportedTokens[token] = TokenInfo({
            isSupported: true,
            decimals: decimals,
            priceFeed: AggregatorV3Interface(priceFeed),
            symbol: symbol
        });
        
        emit TokenAdded(token, symbol, decimals);
    }
    
    /// @notice Removes support for an ERC20 token (ADMIN_ROLE only)
    /// @param token Token contract address
    function removeToken(address token) external onlyRole(ADMIN_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        delete supportedTokens[token];
        emit TokenRemoved(token);
    }
    
    /// @notice Emergency pause function (EMERGENCY_ROLE only)
    function emergencyPause() external onlyRole(EMERGENCY_ROLE) {
        emergencyPaused = true;
        emit EmergencyPauseToggled(true);
    }
    
    /// @notice Emergency unpause function (EMERGENCY_ROLE only)
    function emergencyUnpause() external onlyRole(EMERGENCY_ROLE) {
        emergencyPaused = false;
        emit EmergencyPauseToggled(false);
    }

    // ============ INTERNAL FUNCTIONS ============
    
    /// @notice Internal deposit logic with single state access pattern
    /// @param token Token address
    /// @param amount Token amount
    function _deposit(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        
        // Checks
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        // Single read of state variables
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        // Effects - Single write to each state variable
        uint256 newUserBalance = currentUserBalance + usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal + usdValue;
        totalDepositedUSD = currentTotalDeposited + usdValue;
        totalDeposits = currentTotalDeposits + 1;
        
        // Interactions
        emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
    }
    
    /// @notice Internal withdrawal logic with single state access pattern
    /// @param token Token address
    /// @param amount Token amount to withdraw
    function _withdraw(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        
        // Checks
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        
        // Single read of state variables
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
        if (usdValue > currentUserBalance) revert LowBalance();
        
        // Effects - Single write to each state variable
        uint256 newUserBalance = currentUserBalance - usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal - usdValue;
        totalDepositedUSD = currentTotalDeposited - usdValue;
        totalWithdrawals = currentTotalWithdrawals + 1;
        
        // Interactions
        if (token == NATIVE_TOKEN) {
            _safeTransferETH(msg.sender, amount);
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
        
        emit Withdrawal(msg.sender, token, amount, usdValue, newUserBalance);
    }
    
    /// @notice Safe ETH transfer function
    /// @param to Recipient address
    /// @param amount Amount to transfer
    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert TransferFailed();
    }
    
    /// @notice Fallback function to receive ETH
    receive() external payable {
        if (msg.value > 0) {
            this.depositETH();
        }
    }
}