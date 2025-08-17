// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/B4.sol";

contract B4Test is Test {
    NoDecimalsToken token;
    address owner = address(0x1);

    function setUp() public {
        token = new NoDecimalsToken();
    }

    function testInterfaceIncompatibility() public {
        // Standard ERC20 interface expects decimals() function
        IERC20 erc20 = IERC20(address(token));
        
        vm.expectRevert(); // Will revert due to missing decimals() function
        erc20.decimals();
    }

    function testDirectAccessWorks() public {
        // Direct access to uppercase variable still works
        assertEq(token.DECIMALS(), 18);
    }

    function testCompliantVersion() public {
        // Deploy a compliant version for comparison
        CompliantToken compliantToken = new CompliantToken();
        IERC20 erc20Compliant = IERC20(address(compliantToken));
        
        assertEq(erc20Compliant.decimals(), 18);
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);
    // Other standard ERC20 functions...
}

contract CompliantToken {
    mapping(address => uint256) public balanceOf;
    string public name = "CompliantToken";
    string public symbol = "CT";
    uint8 public decimals = 18;  // Lowercase and has interface

    function decimals() public view returns (uint8) {
        return decimals;
    }

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }
}