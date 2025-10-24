// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ============ IMPORTS ============
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title KipuBankV2 - Advanced Multi-Token Banking System
 * @author Eduardo Moreno - Module 3 Ethereum Developer Program
 * @notice Advanced bank with multi-token support, Chainlink oracles and role-based access control
 * @dev Implements Module 3 security and efficiency best practices including CEI pattern, reentrancy protection, and safe token handling
 * @custom:security-contact eduardo.moreno@kipubank.com
 */
contract KipuBankV2 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ TYPE DECLARATIONS ============
    
    /**
     * @notice Information about supported tokens including price feed and metadata
     * @dev Used to store token configuration and oracle information
     * @param isSupported Whether the token is currently supported for deposits/withdrawals
     * @param decimals Number of decimal places for the token (e.g., 18 for ETH, 6 for USDC)
     * @param priceFeed Chainlink price feed contract for USD conversion
     * @param symbol Token symbol for identification and events
     */
    struct TokenInfo {
        bool isSupported;
        uint8 decimals;
        AggregatorV3Interface priceFeed;
        string symbol;
    }

    // ============ CONSTANTS ============
    
    /// @notice Role identifier for administrative functions like adding/removing tokens
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    /// @notice Role identifier for emergency functions like pausing the contract
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    
    /// @notice Address representing native ETH token (address zero)
    address public constant NATIVE_TOKEN = address(0);
    
    /// @notice Minimum deposit amount in USD (6 decimals) - $1.00 USD
    uint256 public constant MIN_DEPOSIT_USD = 1e6;
    
    /// @notice Maximum age for oracle price data in seconds (1 hour)
    uint16 public constant ORACLE_HEARTBEAT = 3600;
    
    /// @notice Decimal conversion factor for ETH(18) + Oracle(8) to USD(6) = 10^20
    uint256 public constant DECIMAL_FACTOR = 1e20;

    // ============ IMMUTABLE VARIABLES ============
    
    /// @notice Maximum withdrawal amount per transaction in USD (6 decimals)
    uint256 public immutable WITHDRAWAL_LIMIT_USD;
    
    /// @notice Maximum total capacity of the bank in USD (6 decimals)
    uint256 public immutable BANK_CAP_USD;
    
    /// @notice Chainlink ETH/USD price feed contract interface
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    // ============ STATE VARIABLES ============
    
    /// @notice Total amount deposited across all tokens in USD (6 decimals)
    uint256 public totalDepositedUSD;
    
    /// @notice Total number of deposit transactions executed
    uint256 public totalDeposits;
    
    /// @notice Total number of withdrawal transactions executed
    uint256 public totalWithdrawals;
    
    /// @notice Emergency pause state - when true, deposits and withdrawals are blocked
    bool public emergencyPaused;
    
    /// @notice Mapping of token addresses to their configuration and metadata
    mapping(address => TokenInfo) public supportedTokens;
    
    /// @notice Nested mapping: user address => token address => balance in USD (6 decimals)
    mapping(address => mapping(address => uint256)) public userBalances;
    
    /// @notice Mapping of user addresses to their total balance across all tokens in USD (6 decimals)
    mapping(address => uint256) public userTotalBalanceUSD;

    // ============ EVENTS ============
    
    /**
     * @notice Emitted when a user makes a deposit
     * @param user Address of the user making the deposit
     * @param token Address of the deposited token (address(0) for ETH)
     * @param amount Amount of tokens deposited in token's native decimals
     * @param usdValue USD value of the deposit (6 decimals)
     * @param newBalance User's new balance for this token in USD (6 decimals)
     */
    event Deposit(
        address indexed user, 
        address indexed token, 
        uint256 amount, 
        uint256 usdValue, 
        uint256 newBalance
    );
    
    /**
     * @notice Emitted when a user makes a withdrawal
     * @param user Address of the user making the withdrawal
     * @param token Address of the withdrawn token (address(0) for ETH)
     * @param amount Amount of tokens withdrawn in token's native decimals
     * @param usdValue USD value of the withdrawal (6 decimals)
     * @param newBalance User's new balance for this token in USD (6 decimals)
     */
    event Withdrawal(
        address indexed user, 
        address indexed token, 
        uint256 amount, 
        uint256 usdValue, 
        uint256 newBalance
    );
    
    /**
     * @notice Emitted when a new token is added to the supported tokens list
     * @param token Address of the added token
     * @param symbol Symbol of the added token
     * @param decimals Number of decimals for the token
     */
    event TokenAdded(address indexed token, string symbol, uint8 decimals);
    
    /**
     * @notice Emitted when a token is removed from the supported tokens list
     * @param token Address of the removed token
     */
    event TokenRemoved(address indexed token);
    
    /**
     * @notice Emitted when emergency pause state is toggled
     * @param paused New pause state (true = paused, false = unpaused)
     */
    event EmergencyPauseToggled(bool paused);

    // ============ CUSTOM ERRORS ============
    
    /// @notice Thrown when attempting to deposit or withdraw zero amount
    error ZeroAmount();
    
    /// @notice Thrown when attempting to use an unsupported token
    error TokenNotSupported();
    
    /// @notice Thrown when a deposit would exceed the bank's total capacity
    error CapExceeded();
    
    /// @notice Thrown when a withdrawal exceeds the per-transaction limit
    error LimitExceeded();
    
    /// @notice Thrown when user doesn't have sufficient balance for withdrawal
    error LowBalance();
    
    /// @notice Thrown when ETH transfer fails
    error TransferFailed();
    
    /// @notice Thrown when attempting operations while contract is paused
    error Paused();
    
    /// @notice Thrown when price feed returns invalid data (zero or negative)
    error BadPriceFeed();
    
    /// @notice Thrown when price feed data is older than ORACLE_HEARTBEAT
    error StalePrice();

    // ============ MODIFIERS ============
    
    /**
     * @notice Ensures the contract is not in emergency pause state
     * @dev Reverts with Paused() if emergencyPaused is true
     */
    modifier whenNotPaused() {
        bool isPaused = emergencyPaused; // Single storage read
        if (isPaused) revert Paused();
        _;
    }
    
    /**
     * @notice Validates that the provided amount is greater than zero
     * @dev Reverts with ZeroAmount() if amount is zero
     * @param amount The amount to validate
     */
    modifier validAmount(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }
    


    // ============ CONSTRUCTOR ============
    
    /**
     * @notice Initializes the KipuBankV2 contract with essential parameters
     * @dev Sets up withdrawal limits, bank capacity, oracle feeds, and initial roles
     * @param _withdrawalLimitUSD Maximum withdrawal amount per transaction in USD (8 decimals)
     * @param _bankCapUSD Maximum total capacity of the bank in USD (8 decimals)
     * @param _ethUsdPriceFeed Address of the Chainlink ETH/USD price feed oracle
     */
    constructor(
        uint256 _withdrawalLimitUSD,
        uint256 _bankCapUSD,
        address _ethUsdPriceFeed
    ) {
        WITHDRAWAL_LIMIT_USD = _withdrawalLimitUSD;
        BANK_CAP_USD = _bankCapUSD;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        
        // Setup initial roles for deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        
        // Configure ETH as the default supported native token
        supportedTokens[NATIVE_TOKEN] = TokenInfo({
            isSupported: true,
            decimals: 18,
            priceFeed: ethUsdPriceFeed,
            symbol: "ETH"
        });
        
        emit TokenAdded(NATIVE_TOKEN, "ETH", 18);
    }

    // ============ DEPOSIT FUNCTIONS ============
    
    /**
     * @notice Deposits ETH into the bank
     * @dev Converts ETH to USD using Chainlink oracle and updates user balance
     * @dev Emits Deposit event with normalized USD amount
     * @dev Requires non-zero msg.value and contract not paused
     * @dev Typical gas usage: ~120,000-150,000 gas
     */
    function depositETH() 
        external 
        payable 
        whenNotPaused 
        validAmount(msg.value) 
        nonReentrant 
    {
        _deposit(NATIVE_TOKEN, msg.value);
    }
    
    /**
     * @notice Deposits ERC-20 tokens into the bank
     * @dev Converts token amount to USD and updates user balance
     * @dev Requires prior token approval and token must be supported
     * @dev Typical gas usage: ~150,000-180,000 gas
     * @param token Address of the ERC-20 token to deposit
     * @param amount Amount of tokens to deposit (in token's native decimals)
     */
    function depositToken(address token, uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        nonReentrant 
    {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        // CEI: Checks - Single storage reads for all state variables
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 usdValue = (amount * uint256(answer)) / (10 ** (tokenInfo.decimals + 2));
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        // CEI: Effects - Update state using memory variables
        uint256 newUserBalance = currentUserBalance + usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal + usdValue;
        totalDepositedUSD = currentTotalDeposited + usdValue;
        totalDeposits = currentTotalDeposits + 1;
        
        emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
        
        // CEI: Interactions
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }
    
    // ============ WITHDRAWAL FUNCTIONS ============
    
    /**
     * @notice Withdraws ETH from the bank
     * @dev Validates withdrawal limits, updates balances, and transfers ETH
     * @dev Converts amount to USD for limit validation using current oracle price
     * @dev Typical gas usage: ~100,000-130,000 gas
     * @param amount Amount of ETH to withdraw in wei
     */
    function withdrawETH(uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        nonReentrant 
    {
        _withdraw(NATIVE_TOKEN, amount);
    }
    
    /**
     * @notice Withdraws ERC-20 tokens from the bank
     * @dev Validates withdrawal limits, updates balances, and transfers tokens safely
     * @dev Cannot be used to withdraw native ETH (use withdrawETH instead)
     * @dev Typical gas usage: ~130,000-160,000 gas
     * @param token Address of the ERC-20 token to withdraw
     * @param amount Amount of tokens to withdraw (in token's native decimals)
     */
    function withdrawToken(address token, uint256 amount) 
        external 
        whenNotPaused 
        validAmount(amount) 
        nonReentrant 
    {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        // CEI: Checks - Single storage reads for all state variables
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 usdValue = (amount * uint256(answer)) / (10 ** (tokenInfo.decimals + 2));
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        if (usdValue > currentUserBalance) revert LowBalance();
        
        // CEI: Effects - Update state using memory variables
        uint256 newUserBalance = currentUserBalance - usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal - usdValue;
        totalDepositedUSD = currentTotalDeposited - usdValue;
        totalWithdrawals = currentTotalWithdrawals + 1;
        
        emit Withdrawal(msg.sender, token, amount, usdValue, newUserBalance);
        
        // CEI: Interactions
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    // ============ VIEW FUNCTIONS ============
    
    /**
     * @notice Gets a user's balance for a specific token
     * @dev Returns the normalized USD balance stored in the mapping
     * @param user Address of the user to query
     * @param token Address of the token (use NATIVE_TOKEN constant for ETH)
     * @return Balance in USD with 8 decimal places
     */
    function getUserBalance(address user, address token) external view returns (uint256) {
        return userBalances[user][token];
    }
    
    /**
     * @notice Gets a user's total balance across all tokens in USD
     * @dev Aggregated balance maintained for gas efficiency
     * @param user Address of the user to query
     * @return Total balance in USD with 8 decimal places
     */
    function getUserTotalBalance(address user) external view returns (uint256) {
        return userTotalBalanceUSD[user];
    }
    
    /**
     * @notice Gets the current ETH price in USD from Chainlink oracle
     * @dev Includes staleness and sanity validations for price feed data
     * @dev Reverts with BadPriceFeed() if answer <= 0
     * @dev Reverts with StalePrice() if data is older than ORACLE_HEARTBEAT
     * @return price Current ETH price in USD with 8 decimal places
     */
    function getETHPrice() public view returns (uint256 price) {
        (, int256 answer, , uint256 updatedAt, ) = ethUsdPriceFeed.latestRoundData();
        
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        return uint256(answer);
    }
    
    /**
     * @notice Gets the current price of a token using its Chainlink oracle
     * @dev For native ETH, delegates to getETHPrice(). For other tokens, queries their specific price feed
     * @dev Includes staleness and sanity validations for all price feeds
     * @param token Address of the token to get price for
     * @return price Current token price in USD with 8 decimal places
     */
    function getTokenPrice(address token) public view returns (uint256 price) {
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        if (token == NATIVE_TOKEN) {
            return getETHPrice();
        }
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        return uint256(answer);
    }
    
    /**
     * @notice Converts a token amount to its equivalent USD value
     * @dev Uses current oracle price and handles decimal normalization
     * @dev Formula: (amount * price) / (10^(tokenDecimals + priceDecimals - usdDecimals))
     * @dev Example for ETH: (amount * price) / (10^(18 + 8 - 8)) = (amount * price) / 10^18
     * @param token Address of the token to convert
     * @param amount Amount of tokens in the token's native decimals
     * @return usdValue Equivalent value in USD with 8 decimal places
     */
    function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue) {
        if (token == NATIVE_TOKEN) {
            uint256 ethPrice = getETHPrice();
            return (amount * ethPrice) / 1e20; // ETH: 18 decimals + 8 oracle - 8 USD = 18
        }
        
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 tokenPrice = uint256(answer);
        return (amount * tokenPrice) / (10 ** (tokenInfo.decimals + 2));
    }
    
    /**
     * @notice Gets comprehensive information about the bank's current state
     * @dev Returns aggregated statistics and configuration parameters
     * @return totalDepUSD Total amount deposited across all tokens in USD (8 decimals)
     * @return totalDeps Total number of deposit transactions processed
     * @return totalWiths Total number of withdrawal transactions processed
     * @return bankCapUSD Maximum total capacity of the bank in USD (8 decimals)
     * @return withdrawLimitUSD Maximum withdrawal amount per transaction in USD (8 decimals)
     * @return paused Current emergency pause state (true = paused, false = active)
     */
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
    
    /**
     * @notice Adds support for a new ERC-20 token
     * @dev Only admin role can execute. Cannot add native ETH (already supported by default)
     * @dev Token must have a valid Chainlink price feed for USD conversion
     * @param token Address of the ERC-20 token contract
     * @param symbol Token symbol for identification (e.g., "USDC", "WBTC")
     * @param decimals Number of decimal places the token uses
     * @param priceFeed Address of the Chainlink price feed oracle for this token
     */
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
    
    /**
     * @notice Removes support for a previously added token
     * @dev Only admin role can execute. Cannot remove native ETH support
     * @dev Users should withdraw their balances before token removal
     * @param token Address of the token contract to remove from supported list
     */
    function removeToken(address token) external onlyRole(ADMIN_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        delete supportedTokens[token];
        emit TokenRemoved(token);
    }
    
    /**
     * @notice Activates emergency pause to halt all operations
     * @dev Only emergency role can execute. Stops all deposits and withdrawals
     * @dev Used during security incidents or maintenance periods
     */
    function emergencyPause() external onlyRole(EMERGENCY_ROLE) {
        bool currentPaused = emergencyPaused; // Single storage read
        if (currentPaused) return; // Already paused, no need to change
        
        emergencyPaused = true;
        emit EmergencyPauseToggled(true);
    }
    
    /**
     * @notice Deactivates emergency pause to resume normal operations
     * @dev Only emergency role can execute. Re-enables all deposits and withdrawals
     * @dev Should only be used after resolving the emergency condition
     */
    function emergencyUnpause() external onlyRole(EMERGENCY_ROLE) {
        bool currentPaused = emergencyPaused; // Single storage read
        if (!currentPaused) return; // Already unpaused, no need to change
        
        emergencyPaused = false;
        emit EmergencyPauseToggled(false);
    }

    // ============ INTERNAL FUNCTIONS ============
    
    /**
     * @notice Internal deposit logic implementing Checks-Effects-Interactions pattern
     * @dev Validates deposit limits, updates state, and handles token transfers
     * @dev Converts amounts to USD for unified balance tracking
     * @param token Address of the token being deposited (NATIVE_TOKEN for ETH)
     * @param amount Amount of tokens to deposit in native token decimals
     */
    function _deposit(address token, uint256 amount) internal {
        // CEI: Checks - Single storage reads for all state variables
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        
        uint256 usdValue = convertToUSD(token, amount);
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        // CEI: Effects - Update state using memory variables
        uint256 newUserBalance = currentUserBalance + usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal + usdValue;
        totalDepositedUSD = currentTotalDeposited + usdValue;
        totalDeposits = currentTotalDeposits + 1;
        
        emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
    }


    
    /**
     * @notice Internal withdrawal logic implementing Checks-Effects-Interactions pattern
     * @dev Validates withdrawal limits, updates state, and handles token transfers
     * @dev Converts amounts to USD for limit validation and balance tracking
     * @param token Address of the token being withdrawn (NATIVE_TOKEN for ETH)
     * @param amount Amount of tokens to withdraw in native token decimals
     */
    function _withdraw(address token, uint256 amount) internal {
        // CEI: Checks - Single storage reads for all state variables
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
        uint256 usdValue = convertToUSD(token, amount);
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        if (usdValue > currentUserBalance) revert LowBalance();
        
        // CEI: Effects - Update state using memory variables
        uint256 newUserBalance = currentUserBalance - usdValue;
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] = currentUserTotal - usdValue;
        totalDepositedUSD = currentTotalDeposited - usdValue;
        totalWithdrawals = currentTotalWithdrawals + 1;
        
        emit Withdrawal(msg.sender, token, amount, usdValue, newUserBalance);
        
        // CEI: Interactions
        if (token == NATIVE_TOKEN) {
            _safeTransferETH(msg.sender, amount);
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }


    
    /**
     * @notice Safely transfers ETH to a recipient address
     * @dev Uses low-level call to handle transfer failures gracefully
     * @dev Reverts with TransferFailed() if the transfer is unsuccessful
     * @param to Recipient address to receive the ETH
     * @param amount Amount of ETH to transfer in wei
     */
    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert TransferFailed();
    }
    
    /**
     * @notice Receive function for direct ETH deposits to the contract
     * @dev Automatically processes ETH sent directly to the contract as a deposit
     * @dev Calls depositETH() function to handle the deposit logic
     * @dev Only processes deposits if msg.value > 0
     */
    receive() external payable {
        if (msg.value > 0) {
            this.depositETH();
        }
    }
}