// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract RentalContract {
    address public owner;
    
    struct Tenant {
        string name;
        string addressInfo;
        uint256 deposit;
        bool isActive;
    }
    
    struct Property {
        address owner;
        string name;
        string propertyType;
        uint256 rentStartDate;
        uint256 rentEndDate;
        uint256 rentAmount;
        bool isActive;
    }
    
    mapping(address => Tenant) public tenants;
    mapping(address => Property) public properties;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyPropertyOwner(address propertyAddress) {
        require(properties[propertyAddress].owner == msg.sender, "Only property owner can call this function");
        _;
    }
    
    event NewTenant(address indexed tenantAddress, string name);
    event NewProperty(address indexed propertyAddress, string name);
    
    function addTenant(
        address tenantAddress,
        string memory name,
        string memory addressInfo,
        uint256 deposit
    ) external onlyOwner {
        tenants[tenantAddress] = Tenant(name, addressInfo, deposit, true);
        emit NewTenant(tenantAddress, name);
    }
    
    function addProperty(
        address propertyAddress,
        string memory name,
        string memory propertyType,
        uint256 rentStartDate,
        uint256 rentEndDate,
        uint256 rentAmount
    ) external onlyOwner {
        properties[propertyAddress] = Property(msg.sender, name, propertyType, rentStartDate, rentEndDate, rentAmount, true);
        emit NewProperty(propertyAddress, name);
    }
    
    function rentProperty(address propertyAddress) external payable {
        Property storage property = properties[propertyAddress];
        require(property.isActive, "Property is not available for rent");
        require(msg.value == property.rentAmount, "Incorrect rent amount");
        require(tenants[msg.sender].isActive == true, "Tenant is not registered");
        require(tenants[msg.sender].deposit >= msg.value, "Insufficient deposit");
        
        tenants[msg.sender].deposit -= msg.value;
        property.isActive = false;
    }
    
    function endRental(address propertyAddress) external onlyPropertyOwner(propertyAddress) {
        Property storage property = properties[propertyAddress];
        require(!property.isActive, "Property is already active for rent");
        property.isActive = true;
    }
    
    function reportIssue(address tenantAddress, string memory issue) external onlyOwner {
    }
    
}
