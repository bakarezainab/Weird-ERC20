// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Angelglorycoin is ERC20 {
    address public admin;

    // VULNERABLE: Misnamed constructor (should be either "constructor" or "Angelglorycoin")
    function TokenERC20() public ERC20("Angelglorycoin", "AGC") {
        admin = msg.sender;
        _mint(msg.sender, 1_000_000 * 10**18);
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == admin, "Only admin");
        _mint(to, amount);
    }
}