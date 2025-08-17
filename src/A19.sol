// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BalanceCheckedToken is ERC20 {
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() ERC20("BalanceCheckedToken", "BCT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Balance check in approve()
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(balanceOf(msg.sender) >= amount, "Amount exceeds balance"); // Problematic check
        _approve(msg.sender, spender, amount);
        return true;
    }

    // Override to expose internal _allowances
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
}