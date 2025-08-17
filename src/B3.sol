// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoReturnTransferFromToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "NoReturnTransferFrom";
    string public symbol = "NTF";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

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

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}