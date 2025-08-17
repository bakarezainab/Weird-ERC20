// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InconsistentToken is ERC20 {
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() ERC20("InconsistentToken", "ICT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Checks msg.sender's allowance but modifies _to's allowance
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(amount <= _allowances[from][msg.sender], "Insufficient allowance");
        
        // BUG: Modifies wrong allowance mapping
        _allowances[from][to] -= amount; // Should be [from][msg.sender]
        
        _transfer(from, to, amount);
        return true;
    }

    // Expose allowances for testing
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
}