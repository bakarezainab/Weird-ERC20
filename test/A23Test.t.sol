// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A23.sol";

contract A23Test is Test {
    FakeBurnToken token;
    address user = address(0x1);

    function setUp() public {
        token = new FakeBurnToken();
        vm.prank(token.owner());
        token.transfer(user, 1000e18);
    }

    function testFakeBurnAttack() public {
        // 1. User has initial balance
        uint256 initialBalance = token.balanceOf(user);
        assertEq(initialBalance, 1000e18);

        // 2. User attempts to burn 100 tokens with large decimals
        vm.prank(user);
        token.burnWithDecimals(100, 78); // 10^78 overflows to 0

        // 3. Check results
        assertEq(token.balanceOf(user), initialBalance); // No tokens burned!
        assertEq(token.totalSupply(), 1000000 * 10**18); // Supply unchanged
    }

    function testSafeBurn() public {
        // Normal burn works correctly
        vm.prank(user);
        token.burnWithDecimals(100, 18); // Burns 100 tokens properly
        assertEq(token.balanceOf(user), 900e18);
    }
}