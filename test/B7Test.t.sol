// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/B7.sol";

contract B7Test is Test {
    NoApprovalEventToken token;
    address owner = address(0x1);
    address spender = address(0x2);

    function setUp() public {
        token = new NoApprovalEventToken();
    }

    function testMissingApprovalEvent() public {
        // Attempt to detect Approval event (should fail)
        vm.expectEmit(false, false, false, false);
        emit Approval(owner, spender, 100e18); // This won't match
        
        vm.prank(owner);
        token.approve(spender, 100e18);

        // Verify allowance was set despite missing event
        assertEq(token.allowance(owner, spender), 100e18);
    }

    function testCompliantVersion() public {
        CompliantToken compliantToken = new CompliantToken();
        
        // Proper event emission test
        vm.expectEmit(true, true, false, false);
        emit IERC20.Approval(owner, spender, 100e18);
        
        vm.prank(owner);
        compliantToken.approve(spender, 100e18);
    }
}

contract CompliantToken is IERC20 {
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    string public override name = "CompliantToken";
    string public override symbol = "CT";
    uint8 public override decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = 1000000 * 10**18;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}