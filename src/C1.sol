// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CentralControlToken {
    mapping(address => uint256) public balanceOf;
    string public name = "CentralControlToken";
    string public symbol = "CCT";
    uint8 public decimals = 18;
    
    address public centralAccount;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        centralAccount = msg.sender;
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

    modifier onlyCentralAccount() {
        require(msg.sender == centralAccount, "Only central account");
        _;
    }

    // VULNERABLE: Central account can transfer anyone's tokens
    function zeroFeeTransfer(
        address from,
        address to, 
        uint256 amount
    ) public onlyCentralAccount returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // Normal transfer function
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}