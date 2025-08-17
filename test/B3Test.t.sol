// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/B3.sol";

contract B3Test is Test {
    NoReturnTransferFromToken token;
    address owner = address(0x1);
    address spender = address(0x2);
    address recipient = address(0x3);

    function setUp() public {
        token = new NoReturnTransferFromToken();
        vm.prank(owner);
        token.approve(spender, 500e18);
        vm.prank(owner);
        token.transfer(owner, 1000e18);
    }

    function testStandardInterfaceCall() public {
        IERC20 erc20 = IERC20(address(token));
        
        vm.prank(spender);
        vm.expectRevert(); // Will revert due to missing return value
        erc20.transferFrom(owner, recipient, 100e18);

        assertEq(token.balanceOf(recipient), 0);
    }

    function testDirectCallWorks() public {
        vm.prank(spender);
        token.transferFrom(owner, recipient, 100e18); // Works directly
        
        assertEq(token.balanceOf(recipient), 100e18);
        assertEq(token.allowance(owner, spender), 400e18);
    }

    function testCompliantTransferFrom() public {
        vm.prank(spender);
        bool success = token.compliantTransferFrom(owner, recipient, 100e18);
        
        assertTrue(success);
        assertEq(token.balanceOf(recipient), 100e18);
        assertEq(token.allowance(owner, spender), 400e18);
    }

    // Helper function for direct transfers
    function transfer(address to, uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }
}

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}