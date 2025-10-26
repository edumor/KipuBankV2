// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*//////////////////////////////////////////////////////////////
                            LIBRARIES
//////////////////////////////////////////////////////////////*/

using SafeERC20 for IERC20;

/**
 * @title KipuBankV2
 * @author Eduardo Moreno - Ethereum Developers ETH_KIPU
 * @notice Enhanced banking system supporting multi-token deposits with USD limits
 * @dev Implements ERC20 support, Chainlink oracle integration, and role-based access
 * @custom:security-contact security@kipubank.com
 */
contract KipuBankV2 is Ownable {
    
    /*//////////////////////////////////////////////////////////////
                        TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Struct to store token configuration
    struct TokenConfig {
        bool isSupported;
        uint8 decimals;
        AggregatorV3Interface priceFeed;
    }
    
    /*//////////////////////////////////////////////////////////////
                    IMMUTABLE & CONSTANT VARIABLES
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Native token address representation
    address private constant NATIVE_TOKEN = address(0);
    
    /// @notice Maximum withdrawal limit in USDC decimals (1000 USD)
    uint256 private constant WITHDRAWAL_LIMIT_USD = 1000 * 10**6;
    
    /// @notice Bank capacity limit in USDC decimals (100,000 USD)
    uint256 private constant BANK_CAP_USD = 100_000 * 10**6;
    
    /// @notice Decimal normalization factor (18 decimals to 6 decimals)
    uint256 private constant DECIMAL_FACTOR = 10**20;
    
    /// @notice Oracle heartbeat threshold in seconds
    uint256 private constant ORACLE_HEARTBEAT = 3600;
    
    /// @notice Target decimals for internal accounting (USDC standard)
    uint8 private constant TARGET_DECIMALS = 6;

    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Total value deposited in USD (6 decimals)
    uint256 private s_totalDepositedUSD;
    
    /// @notice Total number of deposits made
    uint256 private s_totalDeposits;
    
    /// @notice Total number of withdrawals made
    uint256 private s_totalWithdrawals;
    
    /// @notice Emergency pause status
    bool private s_paused;

    /*//////////////////////////////////////////////////////////////
                            MAPPINGS
    //////////////////////////////////////////////////////////////*/
    
    /// @notice User balances: user => token => balance (in USD, 6 decimals)
    mapping(address user => mapping(address token => uint256 balanceUSD)) private s_balances;
    
    /// @notice Token configuration mapping
    mapping(address token => TokenConfig config) private s_tokenConfig;
    
    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Emitted when a deposit is made
    event KipuBankV2_Deposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 valueUSD,
        uint256 newBalance
    );
    
    /// @notice Emitted when a withdrawal is made
    event KipuBankV2_Withdrawal(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 valueUSD,
        uint256 newBalance
    );
    
    /// @notice Emitted when a token is added
    event KipuBankV2_TokenAdded(address indexed token, address indexed priceFeed);
    
    /// @notice Emitted when a token is removed
    event KipuBankV2_TokenRemoved(address indexed token);
    
    /// @notice Emitted when contract is paused
    event KipuBankV2_Paused(address indexed by);
    
    /// @notice Emitted when contract is unpaused
    event KipuBankV2_Unpaused(address indexed by);
    
    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/
    
    error KipuBankV2_ZeroAmount();
    error KipuBankV2_ZeroAddress();
    error KipuBankV2_TokenNotSupported(address token);
    error KipuBankV2_BankCapExceeded(uint256 requested, uint256 available);
    error KipuBankV2_WithdrawalLimitExceeded(uint256 requested, uint256 limit);
    error KipuBankV2_InsufficientBalance(uint256 requested, uint256 available);
    error KipuBankV2_TransferFailed();
    error KipuBankV2_OracleStalePrice();
    error KipuBankV2_OracleInvalidPrice();
    error KipuBankV2_ContractPaused();
    error KipuBankV2_TokenAlreadySupported(address token);
    
    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Ensures contract is not paused
    modifier whenNotPaused() {
        if (s_paused) revert KipuBankV2_ContractPaused();
        _;
    }
    
    /// @notice Validates amount is greater than zero
    modifier validAmount(uint256 amount) {
        if (amount == 0) revert KipuBankV2_ZeroAmount();
        _;
    }
    
    /// @notice Validates address is not zero
    modifier validAddress(address addr) {
        if (addr == address(0)) revert KipuBankV2_ZeroAddress();
        _;
    }
    
    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Initializes KipuBankV2 with owner and ETH support
     * @param initialOwner Address of the contract owner
     * @param ethPriceFeed Chainlink ETH/USD price feed address
     */
    constructor(
        address initialOwner,
        address ethPriceFeed
    ) Ownable(initialOwner) validAddress(ethPriceFeed) {
        s_tokenConfig[NATIVE_TOKEN] = TokenConfig({
            isSupported: true,
            decimals: 18,
            priceFeed: AggregatorV3Interface(ethPriceFeed)
        });
        
        emit KipuBankV2_TokenAdded(NATIVE_TOKEN, ethPriceFeed);
    }
    
    /*//////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Deposits native ETH into the bank
     * @dev Converts ETH to USD using Chainlink oracle
     */
    function depositETH() external payable whenNotPaused validAmount(msg.value) {
        uint256 valueUSD = _convertToUSD(NATIVE_TOKEN, msg.value);
        
        // ✅ Cache all state variables at the beginning (1 SLOAD each)
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 cachedTotalDeposits = s_totalDeposits;
        uint256 cachedUserBalance = s_balances[msg.sender][NATIVE_TOKEN];
        
        // Checks
        uint256 newTotalDeposited = cachedTotalDeposited + valueUSD;
        if (newTotalDeposited > BANK_CAP_USD) {
            revert KipuBankV2_BankCapExceeded(
                valueUSD,
                BANK_CAP_USD - cachedTotalDeposited
            );
        }
        
        // Effects - calculate new values in memory
        uint256 newUserBalance = cachedUserBalance + valueUSD;
        uint256 newTotalDeposits = cachedTotalDeposits + 1;
        
        // ✅ Write all state variables at the end (1 SSTORE each)
        s_balances[msg.sender][NATIVE_TOKEN] = newUserBalance;
        s_totalDepositedUSD = newTotalDeposited;
        s_totalDeposits = newTotalDeposits;
        
        // Interactions (events only, no external calls)
        emit KipuBankV2_Deposit(
            msg.sender,
            NATIVE_TOKEN,
            msg.value,
            valueUSD,
            newUserBalance
        );
    }
    
    /**
     * @notice Deposits ERC20 tokens into the bank
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to deposit
     */
    function depositERC20(
        address token,
        uint256 amount
    ) external whenNotPaused validAmount(amount) {
        // Checks
        TokenConfig memory config = s_tokenConfig[token];
        if (!config.isSupported) revert KipuBankV2_TokenNotSupported(token);
        
        uint256 valueUSD = _convertToUSD(token, amount);
        
        // ✅ Cache all state variables at the beginning (1 SLOAD each)
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 cachedTotalDeposits = s_totalDeposits;
        uint256 cachedUserBalance = s_balances[msg.sender][token];
        
        uint256 newTotalDeposited = cachedTotalDeposited + valueUSD;
        if (newTotalDeposited > BANK_CAP_USD) {
            revert KipuBankV2_BankCapExceeded(
                valueUSD,
                BANK_CAP_USD - cachedTotalDeposited
            );
        }
        
        // Effects - calculate new values in memory
        uint256 newUserBalance = cachedUserBalance + valueUSD;
        uint256 newTotalDeposits = cachedTotalDeposits + 1;
        
        // ✅ Write all state variables at the end (1 SSTORE each)
        s_balances[msg.sender][token] = newUserBalance;
        s_totalDepositedUSD = newTotalDeposited;
        s_totalDeposits = newTotalDeposits;
        
        emit KipuBankV2_Deposit(
            msg.sender,
            token,
            amount,
            valueUSD,
            newUserBalance
        );
        
        // Interactions
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }
    
    /**
     * @notice Withdraws native ETH from the bank
     * @param amount Amount of ETH to withdraw (in wei)
     */
    function withdrawETH(
        uint256 amount
    ) external whenNotPaused validAmount(amount) {
        uint256 valueUSD = _convertToUSD(NATIVE_TOKEN, amount);
        
        // ✅ Cache all state variables at the beginning (1 SLOAD each)
        uint256 cachedUserBalance = s_balances[msg.sender][NATIVE_TOKEN];
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 cachedTotalWithdrawals = s_totalWithdrawals;
        
        // Checks
        if (valueUSD > WITHDRAWAL_LIMIT_USD) {
            revert KipuBankV2_WithdrawalLimitExceeded(valueUSD, WITHDRAWAL_LIMIT_USD);
        }
        
        if (valueUSD > cachedUserBalance) {
            revert KipuBankV2_InsufficientBalance(valueUSD, cachedUserBalance);
        }
        
        // Effects - calculate new values in memory
        uint256 newUserBalance = cachedUserBalance - valueUSD;
        uint256 newTotalDeposited = cachedTotalDeposited - valueUSD;
        uint256 newTotalWithdrawals = cachedTotalWithdrawals + 1;
        
        // ✅ Write all state variables at the end (1 SSTORE each)
        s_balances[msg.sender][NATIVE_TOKEN] = newUserBalance;
        s_totalDepositedUSD = newTotalDeposited;
        s_totalWithdrawals = newTotalWithdrawals;
        
        emit KipuBankV2_Withdrawal(
            msg.sender,
            NATIVE_TOKEN,
            amount,
            valueUSD,
            newUserBalance
        );
        
        // Interactions
        _safeTransferETH(msg.sender, amount);
    }
    
    /**
     * @notice Withdraws ERC20 tokens from the bank
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to withdraw
     */
    function withdrawERC20(
        address token,
        uint256 amount
    ) external whenNotPaused validAmount(amount) {
        // Checks
        TokenConfig memory config = s_tokenConfig[token];
        if (!config.isSupported) revert KipuBankV2_TokenNotSupported(token);
        
        uint256 valueUSD = _convertToUSD(token, amount);
        
        // ✅ Cache all state variables at the beginning (1 SLOAD each)
        uint256 cachedUserBalance = s_balances[msg.sender][token];
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 cachedTotalWithdrawals = s_totalWithdrawals;
        
        if (valueUSD > WITHDRAWAL_LIMIT_USD) {
            revert KipuBankV2_WithdrawalLimitExceeded(valueUSD, WITHDRAWAL_LIMIT_USD);
        }
        
        if (valueUSD > cachedUserBalance) {
            revert KipuBankV2_InsufficientBalance(valueUSD, cachedUserBalance);
        }
        
        // Effects - calculate new values in memory
        uint256 newUserBalance = cachedUserBalance - valueUSD;
        uint256 newTotalDeposited = cachedTotalDeposited - valueUSD;
        uint256 newTotalWithdrawals = cachedTotalWithdrawals + 1;
        
        // ✅ Write all state variables at the end (1 SSTORE each)
        s_balances[msg.sender][token] = newUserBalance;
        s_totalDepositedUSD = newTotalDeposited;
        s_totalWithdrawals = newTotalWithdrawals;
        
        emit KipuBankV2_Withdrawal(
            msg.sender,
            token,
            amount,
            valueUSD,
            newUserBalance
        );
        
        // Interactions
        IERC20(token).safeTransfer(msg.sender, amount);
    }
    
    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Adds support for a new ERC20 token
     * @param token Address of the token to add
     * @param priceFeed Chainlink price feed for the token
     * @param decimals Number of decimals the token uses
     */
    function addToken(
        address token,
        address priceFeed,
        uint8 decimals
    ) external onlyOwner validAddress(token) validAddress(priceFeed) {
        if (s_tokenConfig[token].isSupported) {
            revert KipuBankV2_TokenAlreadySupported(token);
        }
        
        s_tokenConfig[token] = TokenConfig({
            isSupported: true,
            decimals: decimals,
            priceFeed: AggregatorV3Interface(priceFeed)
        });
        
        emit KipuBankV2_TokenAdded(token, priceFeed);
    }
    
    /**
     * @notice Removes support for a token
     * @param token Address of the token to remove
     */
    function removeToken(address token) external onlyOwner {
        TokenConfig memory config = s_tokenConfig[token];
        if (!config.isSupported) {
            revert KipuBankV2_TokenNotSupported(token);
        }
        
        delete s_tokenConfig[token];
        
        emit KipuBankV2_TokenRemoved(token);
    }
    
    /**
     * @notice Pauses all deposit and withdrawal operations
     */
    function pause() external onlyOwner {
        s_paused = true;
        emit KipuBankV2_Paused(msg.sender);
    }
    
    /**
     * @notice Unpauses all deposit and withdrawal operations
     */
    function unpause() external onlyOwner {
        s_paused = false;
        emit KipuBankV2_Unpaused(msg.sender);
    }
    
    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Gets user balance for a specific token in USD
     * @param user Address of the user
     * @param token Address of the token
     * @return Balance in USD (6 decimals)
     */
    function getBalance(
        address user,
        address token
    ) external view returns (uint256) {
        return s_balances[user][token];
    }
    
    /**
     * @notice Gets general bank information
     * @return totalDepUSD Total deposited in USD
     * @return totalDeps Total number of deposits
     * @return totalWiths Total number of withdrawals
     * @return bankCapUSD Bank capacity in USD
     * @return withdrawLimitUSD Withdrawal limit in USD
     * @return paused Pause status
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
            s_totalDepositedUSD,
            s_totalDeposits,
            s_totalWithdrawals,
            BANK_CAP_USD,
            WITHDRAWAL_LIMIT_USD,
            s_paused
        );
    }
    
    /**
     * @notice Gets token configuration
     * @param token Address of the token
     * @return isSupported Whether token is supported
     * @return decimals Token decimals
     * @return priceFeed Price feed address
     */
    function getTokenConfig(address token) external view returns (
        bool isSupported,
        uint8 decimals,
        address priceFeed
    ) {
        TokenConfig memory config = s_tokenConfig[token];
        return (
            config.isSupported,
            config.decimals,
            address(config.priceFeed)
        );
    }
    
    /**
     * @notice Gets current price from oracle
     * @param token Token address
     * @return price Current price in USD (8 decimals)
     */
    function getPrice(address token) external view returns (uint256 price) {
        TokenConfig memory config = s_tokenConfig[token];
        if (!config.isSupported) revert KipuBankV2_TokenNotSupported(token);
        
        return _getOraclePrice(config.priceFeed);
    }
    
    /*//////////////////////////////////////////////////////////////
                        INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Converts token amount to USD value
     * @param token Token address (use NATIVE_TOKEN for ETH)
     * @param amount Amount in token's smallest unit
     * @return valueUSD Value in USD (6 decimals)
     */
    function _convertToUSD(
        address token,
        uint256 amount
    ) internal view returns (uint256 valueUSD) {
        TokenConfig memory config = s_tokenConfig[token];
        
        uint256 priceUSD = _getOraclePrice(config.priceFeed);
        
        // Normalize to 6 decimals
        uint256 decimalAdjustment;
        if (config.decimals > TARGET_DECIMALS) {
            decimalAdjustment = 10 ** (config.decimals - TARGET_DECIMALS);
            valueUSD = (amount * priceUSD) / (10**8 * decimalAdjustment);
        } else {
            decimalAdjustment = 10 ** (TARGET_DECIMALS - config.decimals);
            valueUSD = (amount * priceUSD * decimalAdjustment) / 10**8;
        }
    }
    
    /**
     * @notice Gets price from Chainlink oracle
     * @param priceFeed Price feed interface
     * @return price Price in USD (8 decimals)
     */
    function _getOraclePrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256 price) {
        (, int256 answer,, uint256 updatedAt,) = priceFeed.latestRoundData();
        
        if (answer <= 0) revert KipuBankV2_OracleInvalidPrice();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) {
            revert KipuBankV2_OracleStalePrice();
        }
        
        price = uint256(answer);
    }
    
    /**
     * @notice Safely transfers ETH to an address
     * @param to Recipient address
     * @param amount Amount to transfer (in wei)
     */
    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success,) = payable(to).call{value: amount}("");
        if (!success) revert KipuBankV2_TransferFailed();
    }
}