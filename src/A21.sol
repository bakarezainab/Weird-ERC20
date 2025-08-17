// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InconsistentToken {
    string public constant name = "InconsistentToken";
    string public constant symbol = "ICT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Checks msg.sender's allowance but modifies to's allowance
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= _allowances[from][msg.sender], "Insufficient allowance");
        
        // BUG: Modifies wrong allowance mapping
        _allowances[from][to] -= amount; // Should be [from][msg.sender]
        
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // Standard ERC20 functions
    function transfer(address to, uint256 amount) public returns (bool) {
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }    
    //.............................BEGINNING OF A23...................................................................
    // VULNERABLE: Potential integer overflow in burn calculation
    function burnWithDecimals(uint256 amount, uint256 _decimals) public returns (bool) {
        uint256 adjustedAmount = amount * (10 ** _decimals);  // Overflow risk
        _burn(msg.sender, adjustedAmount);
        return true;
    }
    function _burn(address account, uint256 amount) internal {
        balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    //.............................END OF A23...................................................................
    //.............................BEGINNING OF A24...................................................................
    function getToken(uint256 _value) public returns (bool success){
    uint newTokens = _value;
    balances[msg.sender] += newTokens;
    success = true;
}
    //.............................END OF A24...................................................................

// Internal mint function
    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}