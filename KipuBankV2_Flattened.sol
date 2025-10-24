// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// File: @openzeppelin/contracts/utils/Context.sol
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol
interface IAccessControl {
    error AccessControlUnauthorizedAccount(address account, bytes32 role);
    error AccessControlBadConfirmation();

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address callerConfirmation) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    mapping(bytes32 role => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }
        _revokeRole(role, callerConfirmation);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

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
abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol
interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/utils/Address.sol
library Address {
    error AddressInsufficientBalance(address account);
    error AddressEmptyCode(address target);
    error FailedInnerCall();

    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    function verifyCallResultFromTarget(address target, bool success, bytes memory returndata) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol
library SafeERC20 {
    using Address for address;

    error SafeERC20FailedOperation(address token);
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/KipuBankV2.sol
contract KipuBankV2 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct TokenInfo {
        bool isSupported;
        uint8 decimals;
        AggregatorV3Interface priceFeed;
        string symbol;
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    address public constant NATIVE_TOKEN = address(0);
    uint256 public constant MIN_DEPOSIT_USD = 1e6;
    uint16 public constant ORACLE_HEARTBEAT = 3600;

    uint256 public immutable WITHDRAWAL_LIMIT_USD;
    uint256 public immutable BANK_CAP_USD;
    AggregatorV3Interface public immutable ethUsdPriceFeed;

    uint256 public totalDepositedUSD;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    bool public emergencyPaused;
    
    mapping(address => TokenInfo) public supportedTokens;
    mapping(address => mapping(address => uint256)) public userBalances;
    mapping(address => uint256) public userTotalBalanceUSD;

    event Deposit(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
    event Withdrawal(address indexed user, address indexed token, uint256 amount, uint256 usdValue, uint256 newBalance);
    event TokenAdded(address indexed token, string symbol, uint8 decimals);
    event TokenRemoved(address indexed token);
    event EmergencyPauseToggled(bool paused);

    error ZeroAmount();
    error TokenNotSupported();
    error CapExceeded();
    error LimitExceeded();
    error LowBalance();
    error TransferFailed();
    error Paused();
    error BadPriceFeed();
    error StalePrice();

    modifier whenNotPaused() {
        if (emergencyPaused) revert Paused();
        _;
    }
    
    modifier validAmount(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }

    constructor(uint256 _withdrawalLimitUSD, uint256 _bankCapUSD, address _ethUsdPriceFeed) {
        WITHDRAWAL_LIMIT_USD = _withdrawalLimitUSD;
        BANK_CAP_USD = _bankCapUSD;
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        
        supportedTokens[NATIVE_TOKEN] = TokenInfo({
            isSupported: true,
            decimals: 18,
            priceFeed: ethUsdPriceFeed,
            symbol: "ETH"
        });
        
        emit TokenAdded(NATIVE_TOKEN, "ETH", 18);
    }

    function depositETH() external payable whenNotPaused validAmount(msg.value) nonReentrant {
        _deposit(NATIVE_TOKEN, msg.value);
    }
    
    function depositToken(address token, uint256 amount) external whenNotPaused validAmount(amount) nonReentrant {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 usdValue = (amount * uint256(answer)) / (10 ** (tokenInfo.decimals + 2));
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        uint256 currentTotalDeposited = totalDepositedUSD;
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 newUserBalance = currentUserBalance + usdValue;
        
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] += usdValue;
        totalDepositedUSD = currentTotalDeposited + usdValue;
        totalDeposits++;
        
        emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }
    
    function withdrawETH(uint256 amount) external whenNotPaused validAmount(amount) nonReentrant {
        _withdraw(NATIVE_TOKEN, amount);
    }
    
    function withdrawToken(address token, uint256 amount) external whenNotPaused validAmount(amount) nonReentrant {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 usdValue = (amount * uint256(answer)) / (10 ** (tokenInfo.decimals + 2));
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        if (usdValue > currentUserBalance) revert LowBalance();
        
        uint256 newUserBalance = currentUserBalance - usdValue;
        
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] -= usdValue;
        totalDepositedUSD -= usdValue;
        totalWithdrawals++;
        
        emit Withdrawal(msg.sender, token, amount, usdValue, newUserBalance);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function getUserBalance(address user, address token) external view returns (uint256) {
        return userBalances[user][token];
    }
    
    function getUserTotalBalance(address user) external view returns (uint256) {
        return userTotalBalanceUSD[user];
    }
    
    function getETHPrice() public view returns (uint256 price) {
        (, int256 answer, , uint256 updatedAt, ) = ethUsdPriceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        return uint256(answer);
    }
    
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
    
    function convertToUSD(address token, uint256 amount) public view returns (uint256 usdValue) {
        if (token == NATIVE_TOKEN) {
            uint256 ethPrice = getETHPrice();
            return (amount * ethPrice) / 1e20;
        }
        
        TokenInfo memory tokenInfo = supportedTokens[token];
        if (!tokenInfo.isSupported) revert TokenNotSupported();
        
        (, int256 answer, , uint256 updatedAt, ) = tokenInfo.priceFeed.latestRoundData();
        if (answer <= 0) revert BadPriceFeed();
        if (block.timestamp - updatedAt > ORACLE_HEARTBEAT) revert StalePrice();
        
        uint256 tokenPrice = uint256(answer);
        return (amount * tokenPrice) / (10 ** (tokenInfo.decimals + 2));
    }
    
    function getBankInfo() external view returns (uint256, uint256, uint256, uint256, uint256, bool) {
        return (totalDepositedUSD, totalDeposits, totalWithdrawals, BANK_CAP_USD, WITHDRAWAL_LIMIT_USD, emergencyPaused);
    }

    function addToken(address token, string memory symbol, uint8 decimals, address priceFeed) external onlyRole(ADMIN_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        supportedTokens[token] = TokenInfo({
            isSupported: true,
            decimals: decimals,
            priceFeed: AggregatorV3Interface(priceFeed),
            symbol: symbol
        });
        emit TokenAdded(token, symbol, decimals);
    }
    
    function removeToken(address token) external onlyRole(ADMIN_ROLE) {
        if (token == NATIVE_TOKEN) revert TokenNotSupported();
        delete supportedTokens[token];
        emit TokenRemoved(token);
    }
    
    function emergencyPause() external onlyRole(EMERGENCY_ROLE) {
        emergencyPaused = true;
        emit EmergencyPauseToggled(true);
    }
    
    function emergencyUnpause() external onlyRole(EMERGENCY_ROLE) {
        emergencyPaused = false;
        emit EmergencyPauseToggled(false);
    }

    function _deposit(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        if (usdValue < MIN_DEPOSIT_USD) revert ZeroAmount();
        
        uint256 currentTotalDeposited = totalDepositedUSD;
        if (currentTotalDeposited + usdValue > BANK_CAP_USD) revert CapExceeded();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        uint256 newUserBalance = currentUserBalance + usdValue;
        
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] += usdValue;
        totalDepositedUSD = currentTotalDeposited + usdValue;
        totalDeposits++;
        
        emit Deposit(msg.sender, token, amount, usdValue, newUserBalance);
    }
    
    function _withdraw(address token, uint256 amount) internal {
        uint256 usdValue = convertToUSD(token, amount);
        if (usdValue > WITHDRAWAL_LIMIT_USD) revert LimitExceeded();
        
        uint256 currentUserBalance = userBalances[msg.sender][token];
        if (usdValue > currentUserBalance) revert LowBalance();
        
        uint256 newUserBalance = currentUserBalance - usdValue;
        
        userBalances[msg.sender][token] = newUserBalance;
        userTotalBalanceUSD[msg.sender] -= usdValue;
        totalDepositedUSD -= usdValue;
        totalWithdrawals++;
        
        emit Withdrawal(msg.sender, token, amount, usdValue, newUserBalance);
        
        if (token == NATIVE_TOKEN) {
            _safeTransferETH(msg.sender, amount);
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }
    
    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert TransferFailed();
    }
    
    receive() external payable {
        if (msg.value > 0) {
            this.depositETH();
        }
    }
}