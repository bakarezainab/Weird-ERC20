// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoApprovalEventToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "NoApprovalEvent";
    string public symbol = "NAE";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    // Missing: event Approval declaration

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

    // VULNERABLE: Missing Approval event
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}