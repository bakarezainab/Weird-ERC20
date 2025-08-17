// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/C1.sol";

contract C1Test is Test {
    CentralControlToken token;
    address admin = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    address attacker = address(0x4);

    function setUp() public {
        vm.prank(admin);
        token = new CentralControlToken();
        
        vm.prank(admin);
        token.transfer(user1, 1000e18);
    }

    function testCentralAccountAbuse() public {
        // 1. Verify initial balances
        assertEq(token.balanceOf(user1), 1000e18);
        assertEq(token.balanceOf(user2), 0);

        // 2. Admin (centralAccount) transfers user1's funds without approval
        vm.prank(admin);
        token.zeroFeeTransfer(user1, user2, 500e18);

        // 3. Verify funds were moved without user1's consent
        assertEq(token.balanceOf(user1), 500e18);
        assertEq(token.balanceOf(user2), 500e18);
    }

    function testNormalUserCannotAbuse() public {
        // Regular users can't use zeroFeeTransfer
        vm.prank(user1);
        vm.expectRevert("Only central account");
        token.zeroFeeTransfer(user1, user2, 100e18);
    }

    function testCompliantVersion() public {
        CompliantToken compliantToken = new CompliantToken();
        vm.prank(admin);
        compliantToken.transfer(user1, 1000e18);

        // Even admin can't transfer others' funds
        vm.prank(admin);
        vm.expectRevert("ERC20: insufficient allowance");
        compliantToken.transferFrom(user1, user2, 100e18);
    }
}

contract CompliantToken is ERC20 {
    constructor() ERC20("CompliantToken", "CT") {
        _mint(msg.sender, 1000000 * 10**18);
    }
    
    // No special transfer privileges for any account
}