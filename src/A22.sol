// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MistypedConstructorToken is ERC20 {
    address public admin;

    // VULNERABLE: Mistyped constructor (using 'function' keyword)
    function constructor() public ERC20("MistypedToken", "MST") {
        admin = msg.sender;
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == admin, "Only admin");
        _mint(to, amount);
    }
}