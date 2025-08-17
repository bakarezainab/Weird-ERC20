// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsecureToken {
    string public constant name = "InsecureToken";
    string public constant symbol = "INSEC";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // VULNERABLE: Misnamed constructor (should be constructor() or contract name)
    function insecuretoken() public {
        owner = msg.sender;
        _mint(owner, 1000000 * 10**18);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
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