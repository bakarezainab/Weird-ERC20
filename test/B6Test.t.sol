// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/B6.sol";

contract B6Test is Test {
    NoSymbolToken token;
    address owner = address(0x1);

    function setUp() public {
        token = new NoSymbolToken();
    }

    function testInterfaceIncompatibility() public {
        // Standard ERC20 interface call
        IERC20 erc20 = IERC20(address(token));
        
        // This will work because of OpenZeppelin's base implementation
        // But demonstrates the shadowing problem
        assertEq(erc20.symbol(), "NST");
        
        // Direct access shows the shadowed variable
        assertEq(token.SYMBOL(), "NST");
    }

    function testStorageInconsistency() public {
        // Shows the shadowing problem
        assertEq(token.symbol(), "NST");  // From ERC20
        assertEq(token.SYMBOL(), "NST"); // From child
        
        // Change the shadowed variable
        token.SYMBOL = "NEW";
        
        // Parent returns original value
        assertEq(token.symbol(), "NST");
        // Child returns new value
        assertEq(token.SYMBOL(), "NEW");
    }

    function testCompliantVersion() public {
        CompliantToken compliantToken = new CompliantToken();
        assertEq(compliantToken.symbol(), "CT");
    }
}

interface IERC20 {
    function symbol() external view returns (string memory);
}

contract CompliantToken is ERC20 {
    constructor() ERC20("CompliantToken", "CT") {
        _mint(msg.sender, 1000000 * 10**18);
    }
    
    // Properly inherits symbol() from ERC20
}