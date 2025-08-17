// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A21.sol";

contract A21Test is Test {
    InconsistentToken token;
    address admin = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address charlie = address(0x4);

    function setUp() public {
        token = new InconsistentToken();
        vm.prank(admin);
        token.transfer(alice, 1000e18);
    }

    function testInconsistentAllowance() public {
        // 1. Alice approves Bob to spend 500 tokens
        vm.prank(alice);
        token.approve(bob, 500e18);
        assertEq(token.allowance(alice, bob), 500e18);

        // 2. Charlie calls transferFrom (with Alice's tokens)
        vm.prank(charlie);
        token.transferFrom(alice, bob, 100e18);

        // 3. Check allowances:
        // - Bob's allowance should be reduced (but isn't)
        assertEq(token.allowance(alice, bob), 500e18); // Not reduced!
        // - Wrong allowance (Alice->Bob) was modified instead
        assertEq(token.allowance(alice, charlie), type(uint256).max - 100e18); // Underflow!
        
        // 4. Funds were still transferred
        assertEq(token.balanceOf(bob), 100e18);
    }

    function testAllowanceUnderflow() public {
        // 1. Alice approves Bob
        vm.prank(alice);
        token.approve(bob, 500e18);

        // 2. Charlie transfers with uninitialized allowance
        vm.prank(charlie);
        token.transferFrom(alice, bob, 100e18); // Causes underflow on Alice->Charlie allowance
        
        // 3. Check underflow result
        assertGt(token.allowance(alice, charlie), 2**255); // Extremely large number
    }
}