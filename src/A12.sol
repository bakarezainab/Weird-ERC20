// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyToken {
    string public constant name = "ProxyToken";
    string public constant symbol = "PROXY";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balances;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _mint(msg.sender, 1000000 * 10**18);
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
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);

        // Fee payment
        balances[_from] -= _fee;
        balances[msg.sender] += _fee;
        emit Transfer(_from, msg.sender, _fee);

        nonces[_from]++;
        return true;
    }
    //.............................END OF A12.................................................................

    // Standard ERC20 functions
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    // Internal mint function
    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}