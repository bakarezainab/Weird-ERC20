// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/B5.sol";

contract B5Test is Test {
    NoNameToken token;
    address owner = address(0x1);

    function setUp() public {
        token = new NoNameToken();
    }

    function testInterfaceIncompatibility() public {
        // Standard ERC20 interface expects name() function
        IERC20 erc20 = IERC20(address(token));
        
        vm.expectRevert(); // Will revert due to missing name() function
        erc20.name();
    }

    function testDirectAccessWorks() public {
        // Direct access to uppercase variable still works
        assertEq(token.NAME(), "NoNameToken");
    }

    function testCompliantVersion() public {
        // Deploy a compliant version for comparison
        CompliantToken compliantToken = new CompliantToken();
        IERC20 erc20Compliant = IERC20(address(compliantToken));
        
        assertEq(erc20Compliant.name(), "CompliantToken");
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract CompliantToken {
    mapping(address => uint256) public balanceOf;
    string public name = "CompliantToken";  // Lowercase and has interface
    string public symbol = "CT";
    uint8 public decimals = 18;

    function name() public view returns (string memory) {
        return name;
    }

    function symbol() public view returns (string memory) {
        return symbol;
    }

    function decimals() public view returns (uint8) {
        return decimals;
    }

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }
}