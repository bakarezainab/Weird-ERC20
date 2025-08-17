// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NoReturnApproveToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "NoReturnApproveToken";
    string public symbol = "NAT";
    uint8 public decimals = 18;

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

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

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}