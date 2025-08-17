// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/B2.sol";

contract B2Test is Test {
    NoReturnApproveToken token;
    address owner = address(0x1);
    address spender = address(0x2);

    function setUp() public {
        token = new NoReturnApproveToken();
    }

    function testStandardInterfaceCall() public {
        // Standard ERC20 interface
        IERC20 erc20 = IERC20(address(token));
        
        vm.expectRevert(); // Will revert due to missing return value
        erc20.approve(spender, 100e18);

        assertEq(token.allowance(owner, spender), 0);
    }

    function testDirectCallWorks() public {
        // Direct call works (but non-compliant)
        token.approve(spender, 100e18);
        assertEq(token.allowance(owner, spender), 100e18);
    }

    function testCompliantApprove() public {
        // Compliant version works with interface
        bool success = token.compliantApprove(spender, 100e18);
        assertTrue(success);
        assertEq(token.allowance(owner, spender), 100e18);
    }
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}