// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoReturnToken {
    mapping(address => uint256) public balanceOf;
    string public name = "NoReturnToken";
    string public symbol = "NRT";
    uint8 public decimals = 18;

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

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

    // Event to match ERC20 (though not strictly needed for the test)
    event Transfer(address indexed from, address indexed to, uint256 value);
}