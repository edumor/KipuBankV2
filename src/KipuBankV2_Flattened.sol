// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/KipuBankV2.sol


pragma solidity 0.8.26;

/*//////////////////////////////////////////////////////////////
                            IMPORTS
//////////////////////////////////////////////////////////////*/





/*//////////////////////////////////////////////////////////////
                            LIBRARIES
//////////////////////////////////////////////////////////////*/

using SafeERC20 for IERC20;

/**
 * @title KipuBankV2
 * @author Eduardo Moreno
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
        
        // Checks
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 newTotalDeposited = cachedTotalDeposited + valueUSD;
        
        if (newTotalDeposited > BANK_CAP_USD) {
            revert KipuBankV2_BankCapExceeded(
                valueUSD,
                BANK_CAP_USD - cachedTotalDeposited
            );
        }
        
        // Effects
        uint256 cachedUserBalance = s_balances[msg.sender][NATIVE_TOKEN];
        uint256 newUserBalance = cachedUserBalance + valueUSD;
        
        s_balances[msg.sender][NATIVE_TOKEN] = newUserBalance;
        s_totalDepositedUSD = newTotalDeposited;
        s_totalDeposits++;
        
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
        
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 newTotalDeposited = cachedTotalDeposited + valueUSD;
        
        if (newTotalDeposited > BANK_CAP_USD) {
            revert KipuBankV2_BankCapExceeded(
                valueUSD,
                BANK_CAP_USD - cachedTotalDeposited
            );
        }
        
        // Effects
        uint256 cachedUserBalance = s_balances[msg.sender][token];
        uint256 newUserBalance = cachedUserBalance + valueUSD;
        
        s_balances[msg.sender][token] = newUserBalance;
        s_totalDepositedUSD = newTotalDeposited;
        s_totalDeposits++;
        
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
        
        // Checks
        if (valueUSD > WITHDRAWAL_LIMIT_USD) {
            revert KipuBankV2_WithdrawalLimitExceeded(valueUSD, WITHDRAWAL_LIMIT_USD);
        }
        
        uint256 cachedUserBalance = s_balances[msg.sender][NATIVE_TOKEN];
        if (valueUSD > cachedUserBalance) {
            revert KipuBankV2_InsufficientBalance(valueUSD, cachedUserBalance);
        }
        
        // Effects
        uint256 newUserBalance = cachedUserBalance - valueUSD;
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 cachedTotalWithdrawals = s_totalWithdrawals;
        
        s_balances[msg.sender][NATIVE_TOKEN] = newUserBalance;
        s_totalDepositedUSD = cachedTotalDeposited - valueUSD;
        s_totalWithdrawals = cachedTotalWithdrawals + 1;
        
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
        
        if (valueUSD > WITHDRAWAL_LIMIT_USD) {
            revert KipuBankV2_WithdrawalLimitExceeded(valueUSD, WITHDRAWAL_LIMIT_USD);
        }
        
        uint256 cachedUserBalance = s_balances[msg.sender][token];
        if (valueUSD > cachedUserBalance) {
            revert KipuBankV2_InsufficientBalance(valueUSD, cachedUserBalance);
        }
        
        // Effects
        uint256 newUserBalance = cachedUserBalance - valueUSD;
        uint256 cachedTotalDeposited = s_totalDepositedUSD;
        uint256 cachedTotalWithdrawals = s_totalWithdrawals;
        
        s_balances[msg.sender][token] = newUserBalance;
        s_totalDepositedUSD = cachedTotalDeposited - valueUSD;
        s_totalWithdrawals = cachedTotalWithdrawals + 1;
        
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
     * @param token Token address
     * @param amount Amount in token decimals
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
     * @param amount Amount to transfer
     */
    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success,) = payable(to).call{value: amount}("");
        if (!success) revert KipuBankV2_TransferFailed();
    }
}