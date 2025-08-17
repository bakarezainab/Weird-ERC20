// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoReturnToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "NoReturnToken";
    string public symbol = "NRT";
    uint8 public decimals = 18;
    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }
    // Event to match ERC20 (though not strictly needed for the test)
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);   

    //.............................BEGINNING OF B1...................................................................
    // VULNERABLE: Missing return value (non-compliant with ERC20)
    function transfer(address to, uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    // Compliant version for comparison
    function compliantTransfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    //.............................END OF B1...................................................................
    //..............................BEGINNING OF B2..................................................................
    // VULNERABLE: Missing return value (non-compliant with ERC20)
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    // Compliant version for comparison
    function compliantApprove(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    //..............................END OF B2..................................................................

    //..............................BEGINNING OF B3...................................................................
    // VULNERABLE: Missing return value
    function transferFrom(address from, address to, uint256 amount) public {
        uint256 currentAllowance = allowance[from][msg.sender];
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(currentAllowance >= amount, "Insufficient allowance");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] = currentAllowance - amount;
        emit Transfer(from, to, amount);
    }

    // Compliant version for comparison
    function compliantTransferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(currentAllowance >= amount, "Insufficient allowance");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] = currentAllowance - amount;
        emit Transfer(from, to, amount);
        return true;
    }
    //..............................END OF B3...................................................................
      
}