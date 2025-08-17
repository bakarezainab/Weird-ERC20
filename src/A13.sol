// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ApproveProxyToken is ERC20 {
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address => uint256)) public allowed;

    constructor() ERC20("ApproveProxyToken", "APT") {
        _mint(msg.sender, 1000000 * 10**18);
    }

    // Vulnerable approveProxy function (missing address(0) check)
    function approveProxy(
        address _from,
        address _spender,
        uint256 _value,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(_from, _spender, _value, nonces[_from], name())
        );

        // BUG: If _from = address(0), ecrecover returns address(0), bypassing check!
        if (_from != ecrecover(hash, _v, _r, _s)) revert();

        allowed[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        nonces[_from]++;
        return true;
    }
}