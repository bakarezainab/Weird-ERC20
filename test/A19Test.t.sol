// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A19.sol";

contract A19Test is Test {
    BalanceCheckedToken token;
    address admin = address(0x1);
    address user = address(0x2);
    address exchange = address(0x3);

    function setUp() public {
        token = new BalanceCheckedToken();
        vm.prank(admin);
        token.transfer(user, 1000e18);
    }

    function testApprovalBalanceCheckProblem() public {
        // 1. User approves exchange for 500 tokens (less than balance)
        vm.prank(user);
        token.approve(exchange, 500e18);
        assertEq(token.allowance(user, exchange), 500e18);

        // 2. User transfers out 800 tokens (balance now 200)
        vm.prank(user);
        token.transfer(address(0xdead), 800e18);

        // 3. PROBLEM: Exchange can still transfer the full 500 approved tokens
        vm.prank(exchange);
        token.transferFrom(user, exchange, 500e18); // Should fail but succeeds

        // 4. Exchange got more than user's current balance
        assertEq(token.balanceOf(exchange), 500e18);
        assertEq(token.balanceOf(user), 0); // User balance was negative if not for ERC20 checks
    }

    function testExchangeIntegrationFailure() public {
        // 1. Exchange tries to get approval for future trades
        vm.prank(exchange);
        vm.expectRevert("Amount exceeds balance");
        token.approve(user, type(uint256).max); // Standard exchange pattern fails
    }
}