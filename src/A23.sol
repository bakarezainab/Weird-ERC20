// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeBurnToken {
    string public constant name = "FakeBurnToken";
    string public constant symbol = "FBT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    address admin;
    
    mapping(address => uint256) public balanceOf;
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    // constructor() {
    //     _mint(msg.sender, 1000000 * 10**18);
    // }

    //.............................BEGINNING OF A25...................................................................

    function withoutConstructor() public  {
        admin = msg.sender;
        _mint(msg.sender, 1_000_000 * 10**18);
    }
    //..............................END OF A25...................................................................
    //...........................BEGINNING OF A23...................................................................

    // VULNERABLE: Potential integer overflow in burn calculation
    function burnWithDecimals(uint256 amount, uint256 _decimals) public returns (bool) {
        uint256 adjustedAmount = amount * (10 ** _decimals);  // Overflow risk
        _burn(msg.sender, adjustedAmount);
        return true;
    }
    //...............................END OF A23...................................................................
    //..............................BEGINNING OF A24..................................................................
    // VULNERABLE: Anyone can mint unlimited tokens
    function getToken(uint256 amount) public returns (bool) {
        _mint(msg.sender, amount);  // No access control
        return true;
    }
    //..............................END OF A24...................................................................

    // Standard ERC20 functions
    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Internal functions
    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        balanceOf[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}