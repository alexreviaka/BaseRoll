// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Payroll.sol";

contract PayrollFactory is Initializable, OwnableUpgradeable {
    address public payrollImplementation;
    address[] public allPayrolls;
    mapping(address => address[]) public companyPayrolls;
    
    event PayrollCreated(address indexed company, address payroll);
    
    function initialize(address _implementation, address _owner) public initializer {
        __Ownable_init(_owner);
        payrollImplementation = _implementation;
    }
    
    function createPayroll() external returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy(
            payrollImplementation,
            abi.encodeWithSignature("initialize(address)", msg.sender)
        );
        
        address payrollAddress = address(proxy);
        allPayrolls.push(payrollAddress);
        companyPayrolls[msg.sender].push(payrollAddress);
        
        emit PayrollCreated(msg.sender, payrollAddress);
        return payrollAddress;
    }
    
    function getCompanyPayrolls(address _company) external view returns (address[] memory) {
        return companyPayrolls[_company];
    }
}
