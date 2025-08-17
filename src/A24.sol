// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FreeMintToken is ERC20 {
    constructor() ERC20("FreeMintToken", "FMT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Anyone can mint unlimited tokens
    function getToken(uint256 amount) public returns (bool) {
        _mint(msg.sender, amount);  // No access control
        return true;
    }
}