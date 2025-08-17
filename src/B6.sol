// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NoSymbolToken is ERC20 {
    string public SYMBOL;  // Problem: Uppercase and shadows parent

    constructor() ERC20("NoSymbolToken", "NST") {
        SYMBOL = "NST";  // Shadows the inherited symbol
        _mint(msg.sender, 1000000 * 10**18);
    }

    // Missing symbol() function override
}