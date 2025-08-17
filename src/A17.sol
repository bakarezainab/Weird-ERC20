// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsecureOwnerToken {
    string public constant name = "InsecureOwnerToken";
    string public constant symbol = "IOT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        _mint(owner, 1000000 * 10**18);
    }

    //..................................BEGINNING OF A17..................................................................

    // VULNERABLE: No access control - anyone can change owner!
    function setOwner(address _owner) public returns (bool) {
        owner = _owner;
        return true;
    }
    //.............................END OF A17.................................................................

    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint");
        _mint(to, amount);
    }

    // Standard ERC20 functions
    function transfer(address to, uint256 amount) public returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    /// same as above
    require(_to != address(0), "Transfer to zero address");
    require(balances[_from] >= _value);
    require(balances[_to] + _value > balances[_to]);

    uint previousBalances = balances[_from] + balances[_to];
    balances[_from] -= _value;
    balances[_to] += _value;
    allowance[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    assert(balances[_from] + balances[_to] == previousBalances);

    return true;
}

    // function transferFrom(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) public returns (bool) {
    //     allowance[from][msg.sender] -= amount;
    //     balances[from] -= amount;
    //     balances[to] += amount;
    //     emit Transfer(from, to, amount);
    //     return true;
    // }

    // Internal mint function
    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}