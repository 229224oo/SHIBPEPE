// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract GoldenNodeReferral {
    address public owner;
    address public usdtAddress;
    address public receiveAddress;
    
    struct User {
        address referrer;
        uint256 directAmount;
        uint256 totalAmount;
        uint256 nodeCount;
        mapping(address => bool) directReferrals;
        address[] directReferralList;
    }
    
    mapping(address => User) public users;
    uint256 public totalUsers;
    
    event ReferralBound(address indexed user, address indexed referrer);
    event NodePurchased(address indexed user, uint256 amount, address indexed referrer);
    
    constructor(address _usdtAddress, address _receiveAddress) {
        owner = msg.sender;
        usdtAddress = _usdtAddress;
        receiveAddress = _receiveAddress;
    }
    
    function bindReferrer(address _referrer) external {
        require(users[msg.sender].referrer == address(0), "Referrer already bound");
        require(_referrer != msg.sender, "Cannot refer yourself");
        
        users[msg.sender].referrer = _referrer;
        
        if (!users[_referrer].directReferrals[msg.sender]) {
            users[_referrer].directReferrals[msg.sender] = true;
            users[_referrer].directReferralList.push(msg.sender);
        }
        
        emit ReferralBound(msg.sender, _referrer);
    }
    
    function getReferrer(address _user) external view returns (address) {
        return users[_user].referrer;
    }
    
    function purchaseNode(uint256 _amount) external {
        IERC20 usdt = IERC20(usdtAddress);
        
        require(usdt.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance");
        
        bool success = usdt.transferFrom(msg.sender, receiveAddress, _amount);
        require(success, "Transfer failed");
        
        users[msg.sender].nodeCount += 1;
        
        address referrer = users[msg.sender].referrer;
        
        if (referrer != address(0)) {
            users[referrer].directAmount += _amount;
            
            address current = referrer;
            for (uint256 i = 0; i < 15; i++) {
                users[current].totalAmount += _amount;
                current = users[current].referrer;
                if (current == address(0)) break;
            }
        }
        
        emit NodePurchased(msg.sender, _amount, referrer);
    }
    
    function getUserStats(address _user) external view returns (
        uint256 nodeCount,
        uint256 directAmount,
        uint256 totalAmount,
        address referrer,
        uint256 directCount
    ) {
        User storage user = users[_user];
        return (
            user.nodeCount,
            user.directAmount,
            user.totalAmount,
            user.referrer,
            user.directReferralList.length
        );
    }
    
    function getDirectReferrals(address _user) external view returns (address[] memory) {
        return users[_user].directReferralList;
    }
    
    function setReceiveAddress(address _newAddress) external {
        require(msg.sender == owner, "Only owner");
        receiveAddress = _newAddress;
    }
    
    function withdraw() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }
}