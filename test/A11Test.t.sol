// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/A11.sol";

contract WeirdTokenA11Test is Test {
    WeirdTokenA11 token;
    address admin = address(0x1);
    address user = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        token = new WeirdTokenA11(admin);
        vm.prank(admin);
        token.transfer(user, 1000e18);
    }

    function testAdminCannotDisableTransfers() public {
        vm.prank(admin);
        vm.expectRevert(); // Should revert because admin is excluded!
        token.disableTokenTransfer();
        
        assertTrue(token.tokenTransfer()); // Still enabled
    }

    function testAttackerCanDisableTransfers() public {
        vm.prank(attacker);
        token.disableTokenTransfer(); // Should succeed
        
        assertFalse(token.tokenTransfer()); // Now disabled
    }

    function testLockedTransfer() public {
        // Attacker disables transfers
        vm.prank(attacker);
        token.disableTokenTransfer();

        // User tries to transfer (should fail)
        vm.prank(user);
        vm.expectRevert("Transfers locked");
        token.transfer(attacker, 100e18);

        // Admin whitelists user
        vm.prank(admin);
        token.setUnlockAddress(user, true);

        // Now user can transfer
        vm.prank(user);
        token.transfer(attacker, 100e18);
        assertEq(token.balanceOf(attacker), 100e18);
    }
}