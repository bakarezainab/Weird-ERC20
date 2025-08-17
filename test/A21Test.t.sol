// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A21.sol";

contract InconsistentTokenTest is Test {
    InconsistentToken token;
    address admin = address(0x1);
    address user = address(0x2);
    address spender = address(0x3);
    address recipient = address(0x4);

    function setUp() public {
        token = new InconsistentToken();
        vm.prank(admin);
        token.transfer(user, 1000e18);
    }

    function testInconsistentAllowance() public {
        // 1. User approves spender for 500 tokens
        vm.prank(user);
        token.approve(spender, 500e18);
        assertEq(token.allowance(user, spender), 500e18);

        // 2. Spender transfers 100 tokens
        vm.prank(spender);
        token.transferFrom(user, recipient, 100e18);

        // 3. Check allowances:
        // - Spender's allowance not reduced (BUG)
        assertEq(token.allowance(user, spender), 500e18);
        // - Recipient's allowance was modified (WRONG)
        assertEq(token.allowance(user, recipient), type(uint256).max - 100e18); // Underflow!
    }

    function testAllowanceUnderflow() public {
        // 1. User approves spender
        vm.prank(user);
        token.approve(spender, 500e18);

        // 2. Spender transfers with uninitialized recipient allowance
        vm.prank(spender);
        token.transferFrom(user, recipient, 100e18); // Causes underflow
        
        // 3. Check underflow result
        assertGt(token.allowance(user, recipient), 2**255); // Extremely large number
    }
}