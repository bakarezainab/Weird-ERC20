// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/FakeBurnToken.sol";

contract FakeBurnTokenTest is Test {
    FakeBurnToken token;
    address admin = address(0x1);
    address user = address(0x2);

    function setUp() public {
        token = new FakeBurnToken();
        vm.prank(admin);
        token.transfer(user, 1000e18);
    }

    function testFakeBurnAttack() public {
        // 1. User has initial balance
        uint256 initialBalance = token.balanceOf(user);
        assertEq(initialBalance, 1000e18);

        // 2. User "burns" tokens with large decimals (causing overflow to 0)
        vm.prank(user);
        token.burnWithDecimals(100, 78); // 10^78 overflows to 0

        // 3. Check results - no tokens actually burned
        assertEq(token.balanceOf(user), initialBalance);
        assertEq(token.totalSupply(), 1000000 * 10**18);
    }

    function testSafeBurn() public {
        // Normal burn works correctly
        uint256 initialBalance = token.balanceOf(user);
        vm.prank(user);
        token.burnWithDecimals(100, 18); // Burns 100 tokens properly
        
        assertEq(token.balanceOf(user), initialBalance - 100e18);
    }

    function testOverflowProtection() public {
        // Should revert on overflow
        vm.prank(user);
        vm.expectRevert();
        token.burnWithDecimals(1, 100); // Impossible exponent
    }
}