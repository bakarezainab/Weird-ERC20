// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UnsafeCallToken is ERC20 {
    constructor() ERC20("UnsafeCallToken", "UCT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // Vulnerable function: Allows arbitrary calls on behalf of the token contract
    function unsafeCall(address target, bytes memory data) public payable {
        (bool success, ) = target.call{value: msg.value}(data);
        require(success, "Call failed");
    }    

    // ERC20 transfer with callback (similar to ERC223/ERC827 vulnerability)
    function transferWithCallback(address to, uint256 amount, bytes memory data) public {
        _transfer(msg.sender, to, amount);
        (bool success, ) = to.call(abi.encodeWithSignature("tokenFallback(address,uint256,bytes)", msg.sender, amount, data));
        require(success, "Callback failed");
    }
}