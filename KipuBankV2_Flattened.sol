// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts (last updated v5.4.0) (access/IAccessControl.sol)

pragma solidity >=0.8.4;

/**
 * @dev External interface of AccessControl declared to support ERC-165 detection.
 */
interface IAccessControl {
    /**
     * @dev The `account` is missing a role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    /**
     * @dev The caller of a function is not the expected one.
     *
     * NOTE: Don't confuse with {AccessControlUnauthorizedAccount}.
     */
    error AccessControlBadConfirmation();

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted to signal this.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call. This account bears the admin role (for the granted role).
     * Expected in cases where the role was granted using the internal {AccessControl-_grantRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

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

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/ERC165.sol)

pragma solidity ^0.8.20;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC-165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 */
abstract contract ERC165 is IERC165 {
    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts (last updated v5.4.0) (access/AccessControl.sol)

pragma solidity ^0.8.20;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
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


pragma solidity ^0.8.20;

// ============ IMPORTS ============






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
        if (emergencyPaused) revert Paused();
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
        
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        // CEI: Checks - Calcular USD value con un solo acceso a storage
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 usdValue = (amount * uint256(answer)) / (10 ** (tokenInfo.decimals + 2));
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        uint256 currentTotalDeposited = totalDepositedUSD;
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        // CEI: Effects
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        
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
        
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        // CEI: Checks - Calcular USD value con un solo acceso a storage
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 usdValue = (amount * uint256(answer)) / (10 ** (tokenInfo.decimals + 2));
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        if (usdValue > currentUserBalance) revert LowBalance();
        
        // CEI: Effects
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
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
        emergencyPaused = true;
        emit EmergencyPauseToggled(true);
    }
    
    /**
     * @notice Deactivates emergency pause to resume normal operations
     * @dev Only emergency role can execute. Re-enables all deposits and withdrawals
     * @dev Should only be used after resolving the emergency condition
     */
    function emergencyUnpause() external onlyRole(EMERGENCY_ROLE) {
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
        // CEI: Checks
        uint256 usdValue = convertToUSD(token, amount);
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        // Verificar límite del banco
        uint256 currentTotalDeposited = totalDepositedUSD;
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        // CEI: Effects
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposits = totalDeposits;
        
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
        // CEI: Checks
        uint256 usdValue = convertToUSD(token, amount);
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        if (usdValue > currentUserBalance) revert LowBalance();
        
        // CEI: Effects
        uint256 currentUserTotal = userTotalBalanceUSD[msg.sender];
        uint256 currentTotalDeposited = totalDepositedUSD;
        uint256 currentTotalWithdrawals = totalWithdrawals;
        
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