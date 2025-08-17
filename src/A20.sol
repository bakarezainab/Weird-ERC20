// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ReApproveToken is ERC20 {
    constructor() ERC20("ReApproveToken", "RAT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // Standard approve function vulnerable to front-running
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}