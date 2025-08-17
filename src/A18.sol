// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VulnerableToken is ERC20 {
    mapping(address => mapping(address => uint256)) public allowed;

    constructor() ERC20("VulnerableToken", "VULN") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Missing allowance check (like EDUCoin bug)
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        require(_to != address(0), "Invalid recipient");
        require(balanceOf(_from) >= _value, "Insufficient balance");

        _transfer(_from, _to, _value);
        
        // BUG 1: Missing allowance check
        // BUG 2: Unsafe allowance subtraction (potential underflow)
        allowed[_from][msg.sender] -= _value;
        
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}