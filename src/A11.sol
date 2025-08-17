// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract WeirdTokenA11ToA16 {    

    string public name = "WeirdToken";
    string public symbol = "WEIRD";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public walletAddress;
    bool public tokenTransfer;
    
    constructor(address _walletAddress) {
        walletAddress = _walletAddress;
        tokenTransfer = true;
        _mint(_walletAddress, 1000000 * 10**18);
    }    
    
    mapping(address => bool) public unlockaddress;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public nonces;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokenTransfer(bool enabled);    

    // VULNERABLE MODIFIER: Should be == not !=
    modifier onlyFromWallet {
        require(msg.sender != walletAddress); // BUG: Wrong condition
        _;
    }

    modifier isTokenTransfer {
        if(!tokenTransfer) {
            require(unlockaddress[msg.sender], "Transfers locked");
        }
        _;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public isTokenTransfer returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    //..............................BEGINNING OF A11..................................................................

    // VULNERABLE: Anyone EXCEPT wallet can call these
    function enableTokenTransfer() external onlyFromWallet {
        tokenTransfer = true;
        emit TokenTransfer(true);
    }

    function disableTokenTransfer() external onlyFromWallet {
        tokenTransfer = false;
        emit TokenTransfer(false);
    }

    function setUnlockAddress(address _addr, bool _status) external {
        require(msg.sender == walletAddress, "Only admin");
        unlockaddress[_addr] = _status;
    }

    //...........................END OF A11..................................................................
    function _transfer(address from, address to, uint256 amount) internal {
        require(_balances[from] >= amount, "Insufficient balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    //..................................BEGINNING OF A12..................................................................

    // VULNERABLE: Missing address(0) check in transferProxy

    function transferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(_from, _to, _value, _fee, nonces[_from], name)
        );

        // BUG: If _from = address(0), ecrecover returns address(0), bypassing check!
        if (_from != ecrecover(hash, _v, _r, _s)) revert();

        // Transfer logic
        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);

        // Fee payment
        _balances[_from] -= _fee;
        _balances[msg.sender] += _fee;
        emit Transfer(_from, msg.sender, _fee);

        nonces[_from]++;
        return true;
    }
    //.............................END OF A12.................................................................


    //..................................BEGINNING OF A13..................................................................

    function approveProxy(
        address _from,
        address _spender,
        uint256 _value,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(_from, _spender, _value, nonces[_from], name)
        );

        // BUG: If _from = address(0), ecrecover returns address(0), bypassing check!
        if (_from != ecrecover(hash, _v, _r, _s)) revert();

        _allowances[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        nonces[_from]++;
        return true;
    }
    //.............................END OF A13.................................................................


    //..................................BEGINNING OF A15..................................................................
    function transferWithCustomFallback(
        address to,
        uint256 amount,
        bytes memory data,
        string memory customFallback
    ) public returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);

        // BUG: Allows custom fallback with potential reentrancy
        (bool success, ) = to.call(
            abi.encodeWithSignature(
                customFallback,
                msg.sender,
                amount,
                data
            )
        );
        require(success, "Fallback failed");
        
        return true;
    }
    //.............................END OF A15.................................................................


    //..................................BEGINNING OF A16..................................................................

    // Vulnerable function: Allows arbitrary calls on behalf of the token contract
    function unsafeCall(address target, bytes memory data) public payable {
        (bool success, ) = target.call{value: msg.value}(data);
        require(success, "Call failed");
    }    

    // ERC20 transfer with callback (similar to ERC223/ERC827 vulnerability)
    function transferWithCallback(address to, uint256 amount, bytes memory data) public {
        _transfer(msg.sender, to, amount);
        (bool success, ) = to.call(abi.encodeWithSignature("tokenFallback(address,uint256,bytes)", msg.sender, amount, data));
        require(success, "Callback failed");
    }

    //.............................END OF A16.................................................................
    
    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= amount, "Insufficient allowance");
        _approve(owner, spender, currentAllowance - amount);
    }

    // Internal functions
    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}