// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeBurnToken is ERC20 {
    constructor() ERC20("FakeBurnToken", "FBT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Potential integer overflow in burn calculation
    function burnWithDecimals(uint256 amount, uint256 decimals) public returns (bool) {
        uint256 adjustedAmount = amount * (10 ** decimals);  // Overflow risk
        _burn(msg.sender, adjustedAmount);
        return true;
    }
}