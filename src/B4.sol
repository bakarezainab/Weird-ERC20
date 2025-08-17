// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoDecimalsToken {
    mapping(address => uint256) public balanceOf;
    string public name = "NoDecimalsToken";
    string public symbol = "NDT";
    uint8 public DECIMALS = 18;  // Problem: Uppercase and no interface

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}