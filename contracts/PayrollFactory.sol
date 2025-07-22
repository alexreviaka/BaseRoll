// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Payroll.sol";

contract PayrollFactory is Ownable {
    address public payrollImplementation;
    address[] public allPayrolls;
    mapping(address => address[]) public companyPayrolls;
    
    event PayrollCreated(address indexed company, address payroll);
    
    constructor(address _implementation) Ownable(msg.sender) {
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
