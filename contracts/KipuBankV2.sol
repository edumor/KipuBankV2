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
 * @author Eduardo Moreno - Módulo 3 Ethereum Developer Program
 * @notice Multi-token banking system with Chainlink price feeds and role-based access control
 * @dev Implements Module 3 concepts: AccessControl, SafeERC20, multi-token support, Chainlink oracles
 * @custom:security CEI pattern, ReentrancyGuard, single storage access optimization
 * @custom:module Based on Module 3 - DonationsV2 pattern with banking functionality
 */
contract KipuBankV2 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ CONSTANTS (Module 3 Pattern) ============
    
    /// @notice Admin role for token management and configuration
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Emergency role for pause functionality
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    /// @notice Native ETH representation as taught in Module 3
    address public constant NATIVE_TOKEN = address(0);
    
    /// @notice Minimum deposit: 1 USD normalized to 6 decimals (USDC standard)
    uint256 public constant MIN_DEPOSIT_USD = 1e6;

    // ============ IMMUTABLE STATE (Module 3 Best Practice) ============
    
    /// @notice Per-transaction withdrawal limit in USD (6 decimals)
    uint256 public immutable WITHDRAWAL_LIMIT_USD;
    
    /// @notice Total bank capacity in USD (6 decimals) 
    uint256 public immutable BANK_CAP_USD;
    
    /// @notice Chainlink ETH/USD price feed (as taught in Module 3)
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    // ============ STATE VARIABLES (Module 3 Architecture) ============
    
    /// @notice Total deposited value normalized to USD (6 decimals)
    uint256 public totalDepositedUSD;
    
    /// @notice Counter for total deposits (gas-efficient tracking)
    uint256 public totalDeposits;
    
    /// @notice Counter for total withdrawals (gas-efficient tracking)
    uint256 public totalWithdrawals;
    
    /// @notice Emergency pause flag (security feature from Module 3)
    bool public emergencyPaused;
    
    /// @notice Token registry with price feed integration (Module 3 pattern)
    mapping(address => TokenInfo) public supportedTokens;
    
    /// @notice User balances: user => token => USD amount (Module 3 normalization)
    mapping(address => mapping(address => uint256)) public userBalances;
    
    /// @notice User totals in USD for efficient queries (Module 3 optimization)
    mapping(address => uint256) public userTotalBalanceUSD;

    // ============ STRUCTS (Module 3 Data Architecture) ============
    
    /// @notice Token metadata and price feed configuration (Module 3 pattern)
    struct TokenInfo {
        bool isSupported;                   // Token whitelist status
        uint8 decimals;                     // Token decimal places
        AggregatorV3Interface priceFeed;    // Chainlink price oracle
        string symbol;                      // Human-readable identifier
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

    // ============ CONSTRUCTOR (Module 3 Pattern) ============
    
    /// @notice Initializes KipuBankV2 following Module 3 architecture
    /// @param _withdrawalLimitUSD Per-transaction limit in USD (6 decimals)
    /// @param _bankCapUSD Total capacity in USD (6 decimals) 
    /// @param _ethUsdPriceFeed Chainlink ETH/USD aggregator address
    /// @dev Sets up AccessControl roles and registers native ETH with address(0)
    constructor(
        uint256 _withdrawalLimitUSD,
        uint256 _bankCapUSD,
        address _ethUsdPriceFeed
    ) {
        WITHDRAWAL_LIMIT_USD = _withdrawalLimitUSD;
        BANK_CAP_USD = _bankCapUSD;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        
        // AccessControl setup (Module 3 pattern)
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        
        // Register native ETH as address(0) (Module 3 standard)
        supportedTokens[NATIVE_TOKEN] = TokenInfo({
            isSupported: true,
            decimals: 18,
            priceFeed: ethUsdPriceFeed,
            symbol: "ETH"
        });
        
        emit TokenAdded(NATIVE_TOKEN, "ETH", 18);
    }

    // ============ DEPOSIT FUNCTIONS (Module 3 Multi-token Pattern) ============
    
    /// @notice Deposit native ETH using address(0) representation
    /// @dev Follows Module 3 pattern for native token handling
    function depositETH() 
        external 
        payable 
        whenNotPaused 
        validAmount(msg.value) 
        nonReentrant 
    {
        _deposit(NATIVE_TOKEN, msg.value);
    }
    
    /// @notice Deposit ERC20 tokens with SafeERC20 protection
    /// @param token ERC20 contract address
    /// @param amount Token amount to deposit
    /// @dev Uses SafeERC20.safeTransferFrom as taught in Module 3
    function depositToken(address token, uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        onlySupportedToken(token) 
        nonReentrant 
    {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        // Module 3 pattern: SafeERC20 for secure transfers
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _deposit(token, amount);
    }
    
    // ============ WITHDRAWAL FUNCTIONS (Module 3 Multi-token Pattern) ============
    
    /// @notice Withdraw native ETH using address(0) representation
    /// @param amount ETH amount to withdraw
    /// @dev Follows Module 3 pattern for native token handling
    function withdrawETH(uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        nonReentrant 
    {
        _withdraw(NATIVE_TOKEN, amount);
    }
    
    /// @notice Withdraw ERC20 tokens with SafeERC20 protection
    /// @param token ERC20 contract address
    /// @param amount Token amount to withdraw
    /// @dev Uses SafeERC20.safeTransfer as taught in Module 3
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
    
    // ============ CHAINLINK PRICE FEEDS (Module 3 Integration) ============
    
    /// @notice Get ETH price from Chainlink oracle with staleness check
    /// @return price ETH price in USD (8 decimals from Chainlink)
    /// @dev Implements Module 3 pattern for Chainlink data validation
    function getETHPrice() public view returns (uint256 price) {
        (, int256 answer, , uint256 updatedAt,) = ethUsdPriceFeed.latestRoundData();
        
        // Module 3 validation: positive price and freshness check
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > 3600) revert StalePrice(); // 1 hour staleness
        
        return uint256(answer);
    }
    
    /// @notice Get token price from Chainlink with validation
    /// @param token Token address (use address(0) for ETH)
    /// @return price Token price in USD (8 decimals from Chainlink)
    /// @dev Module 3 pattern: unified price feed access for all tokens
    function getTokenPrice(address token) public view returns (uint256 price) {
        if (!supportedTokens[token].isSupported) revert TokenNotSupported();
        
        // Handle native ETH (address(0)) as per Module 3
        if (token == NATIVE_TOKEN) {
            return getETHPrice();
        }
        
        // ERC20 token price feed
        AggregatorV3Interface priceFeed = supportedTokens[token].priceFeed;
        (, int256 answer, , uint256 updatedAt,) = priceFeed.latestRoundData();
        
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > 3600) revert StalePrice();
        
        return uint256(answer);
    }
    
    /// @notice Convert token amount to USD with decimal normalization
    /// @param token Token address (address(0) for ETH)
    /// @param amount Token amount in native decimals
    /// @return usdValue Normalized value in USD (6 decimals like USDC)
    /// @dev Module 3 pattern: normalize all values to 6 decimal USD representation
    function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue) {
        uint256 tokenPrice = getTokenPrice(token);        // 8 decimals from Chainlink
        uint8 tokenDecimals = supportedTokens[token].decimals;
        
        // Module 3 normalization formula:
        // (amount * price) / (10^tokenDecimals * 10^8 / 10^6)
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

    // ============ INTERNAL LOGIC (Module 3 CEI Pattern) ============
    
    /// @notice Internal deposit with CEI pattern and single state access
    /// @param token Token address (address(0) for ETH) 
    /// @param amount Token amount in native decimals
    /// @dev Implements Module 3 patterns: CEI, single storage reads, USD normalization
    function _deposit(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        
        // CHECKS (Module 3 CEI Pattern)
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        // Single state reads (Module 3 gas optimization)
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        // EFFECTS (Module 3 CEI Pattern - single writes)
        uint256 newUserBalance = currentUserBalance + usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal + usdValue;
        totalDepositedUSD = currentTotalDeposited + usdValue;
        totalDeposits = currentTotalDeposits + 1;
        
        // INTERACTIONS (Module 3 CEI Pattern)
        emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
    }
    
    /// @notice Internal withdrawal with CEI pattern and single state access
    /// @param token Token address (address(0) for ETH)
    /// @param amount Token amount to withdraw in native decimals
    /// @dev Implements Module 3 patterns: CEI, single storage reads, safe transfers
    function _withdraw(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        
        // CHECKS (Module 3 CEI Pattern)
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        
        // Single state reads (Module 3 gas optimization)
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
        if (usdValue > currentUserBalance) revert LowBalance();
        
        // EFFECTS (Module 3 CEI Pattern - single writes)
        uint256 newUserBalance = currentUserBalance - usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal - usdValue;
        totalDepositedUSD = currentTotalDeposited - usdValue;
        totalWithdrawals = currentTotalWithdrawals + 1;
        
        // INTERACTIONS (Module 3 CEI Pattern - external calls last)
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
    
    /// @notice Receive function for direct ETH deposits (Module 3 pattern)
    /// @dev Automatically converts received ETH to bank deposit
    receive() external payable {
        if (msg.value > 0) {
            this.depositETH();
        }
    }
}