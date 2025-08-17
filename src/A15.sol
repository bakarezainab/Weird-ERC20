// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableToken {
    string public constant name = "VulnerableToken";
    string public constant symbol = "VULN";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public authorized;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        owner = msg.sender;
        authorized[msg.sender] = true;
        _mint(msg.sender, 1000000 * 10**18);
    }

    // VULNERABLE: Custom fallback function
    function transferWithCustomFallback(
        address to,
        uint256 amount,
        bytes memory data,
        string memory customFallback
    ) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);

        // BUG: Allows custom fallback with potential reentrancy
        (bool success, ) = to.call(
            abi.encodeWithSignature(
                customFallback,
                msg.sender,
                amount,
                data
            )
        );
        require(success, "Fallback failed");
        
        return true;
    }

    // Protected function using ds-auth style authorization
    function mint(address to, uint256 amount) public {
        require(isAuthorized(msg.sender), "Not authorized");
        _mint(to, amount);
    }

    // VULNERABLE: Authorization check
    function isAuthorized(address caller) internal view returns (bool) {
        // BUG: Contract itself is always authorized
        if (caller == address(this)) {
            return true;
        }
        return authorized[caller];
    }

    function addAuthorized(address account) public {
        require(msg.sender == owner, "Only owner");
        authorized[account] = true;
    }

    // Standard ERC20 functions
    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // Internal mint function
    function _mint(address account, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}

contract MaliciousReceiver {
    VulnerableToken token;
    address attacker;
    bool private reentrancyGuard;

    constructor(VulnerableToken _token) {
        token = _token;
        attacker = msg.sender;
    }

    // Malicious fallback function
    function maliciousFallback(address from, uint256 amount, bytes memory) external {
        if (!reentrancyGuard) {
            reentrancyGuard = true;
            // Exploit: Mint tokens while in callback
            token.mint(attacker, amount);
        }
    }
}