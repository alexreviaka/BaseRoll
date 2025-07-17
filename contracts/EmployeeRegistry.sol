// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract EmployeeRegistry is Initializable, OwnableUpgradeable {
    struct EmployeeInfo {
        string name;
        string email;
        string position;
        uint256 joinedAt;
        bool isActive;
    }

    mapping(address => EmployeeInfo) private employeeData;
    mapping(address => bool) private registeredEmployees;
    address[] private employeeAddresses;

    event EmployeeRegistered(address indexed wallet, string name, string position);
    event EmployeeUpdated(address indexed wallet);
    event EmployeeDeactivated(address indexed wallet);

    error EmployeeAlreadyRegistered();
    error EmployeeNotFound();
    error InvalidAddress();

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function registerEmployee(
        address _wallet,
        string memory _name,
        string memory _email,
        string memory _position
    ) external onlyOwner {
        if (_wallet == address(0)) revert InvalidAddress();
        if (registeredEmployees[_wallet]) revert EmployeeAlreadyRegistered();

        employeeData[_wallet] = EmployeeInfo({
            name: _name,
            email: _email,
            position: _position,
            joinedAt: block.timestamp,
            isActive: true
        });

        registeredEmployees[_wallet] = true;
        employeeAddresses.push(_wallet);

        emit EmployeeRegistered(_wallet, _name, _position);
    }

    function updateEmployee(
        address _wallet,
        string memory _name,
        string memory _email,
        string memory _position
    ) external onlyOwner {
        if (!registeredEmployees[_wallet]) revert EmployeeNotFound();

        EmployeeInfo storage employee = employeeData[_wallet];
        employee.name = _name;
        employee.email = _email;
        employee.position = _position;

        emit EmployeeUpdated(_wallet);
    }

    function deactivateEmployee(address _wallet) external onlyOwner {
        if (!registeredEmployees[_wallet]) revert EmployeeNotFound();
        
        employeeData[_wallet].isActive = false;
        emit EmployeeDeactivated(_wallet);
    }

    function getEmployeeInfo(address _wallet) external view returns (EmployeeInfo memory) {
        if (!registeredEmployees[_wallet]) revert EmployeeNotFound();
        return employeeData[_wallet];
    }

    function isRegistered(address _wallet) external view returns (bool) {
        return registeredEmployees[_wallet];
    }

    function getAllEmployees() external view returns (address[] memory) {
        return employeeAddresses;
    }

    function getActiveEmployeeCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < employeeAddresses.length; i++) {
            if (employeeData[employeeAddresses[i]].isActive) {
                count++;
            }
        }
        return count;
    }
}
