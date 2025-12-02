// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract BaseRollV1 is Initializable, UUPSUpgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ORG_OWNER_ROLE = keccak256("ORG_OWNER_ROLE");

    struct Organization {
        uint256 id;
        address owner;
        string name;
        string metadata;
        uint256 createdAt;
        bool active;
    }

    struct Employee {
        uint256 id;
        uint256 orgId;
        address wallet;
        uint256 baseSalary;
        uint256 addedAt;
        bool active;
    }

    uint256 private _orgIdCounter;
    uint256 private _employeeIdCounter;

    mapping(uint256 => Organization) private _organizations;
    mapping(uint256 => Employee) private _employees;
    mapping(uint256 => uint256[]) private _orgEmployees;
    mapping(address => uint256) private _ownerToOrg;
    mapping(address => mapping(uint256 => bool)) private _isOrgEmployee;

    event OrganizationRegistered(uint256 indexed orgId, address indexed owner, string name);
    event OrganizationMetadataUpdated(uint256 indexed orgId, string metadata);
    event EmployeeAdded(uint256 indexed orgId, uint256 indexed employeeId, address indexed wallet, uint256 baseSalary);
    event EmployeeDeactivated(uint256 indexed orgId, uint256 indexed employeeId);

    error OrganizationAlreadyExists();
    error OrganizationNotFound();
    error EmployeeNotFound();
    error NotOrganizationOwner();
    error InvalidAddress();
    error InvalidSalary();
    error EmployeeAlreadyExists();
    error EmployeeNotActive();

    function initialize(address admin) public initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    function registerOrganization(string calldata name, string calldata metadata) external returns (uint256) {
        if (_ownerToOrg[msg.sender] != 0) revert OrganizationAlreadyExists();

        unchecked {
            ++_orgIdCounter;
        }

        uint256 orgId = _orgIdCounter;

        _organizations[orgId] = Organization({
            id: orgId,
            owner: msg.sender,
            name: name,
            metadata: metadata,
            createdAt: block.timestamp,
            active: true
        });

        _ownerToOrg[msg.sender] = orgId;
        _grantRole(ORG_OWNER_ROLE, msg.sender);

        emit OrganizationRegistered(orgId, msg.sender, name);

        return orgId;
    }

    function setOrgMetadata(uint256 orgId, string calldata metadata) external {
        Organization storage org = _organizations[orgId];

        if (org.id == 0) revert OrganizationNotFound();
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        org.metadata = metadata;

        emit OrganizationMetadataUpdated(orgId, metadata);
    }

    function addEmployee(uint256 orgId, address wallet, uint256 baseSalary) external returns (uint256) {
        if (wallet == address(0)) revert InvalidAddress();
        if (baseSalary == 0) revert InvalidSalary();

        Organization storage org = _organizations[orgId];

        if (org.id == 0) revert OrganizationNotFound();
        if (org.owner != msg.sender) revert NotOrganizationOwner();
        if (_isOrgEmployee[wallet][orgId]) revert EmployeeAlreadyExists();

        unchecked {
            ++_employeeIdCounter;
        }

        uint256 employeeId = _employeeIdCounter;

        _employees[employeeId] = Employee({
            id: employeeId,
            orgId: orgId,
            wallet: wallet,
            baseSalary: baseSalary,
            addedAt: block.timestamp,
            active: true
        });

        _orgEmployees[orgId].push(employeeId);
        _isOrgEmployee[wallet][orgId] = true;

        emit EmployeeAdded(orgId, employeeId, wallet, baseSalary);

        return employeeId;
    }

    function deactivateEmployee(uint256 orgId, uint256 employeeId) external {
        Organization storage org = _organizations[orgId];
        Employee storage employee = _employees[employeeId];

        if (org.id == 0) revert OrganizationNotFound();
        if (org.owner != msg.sender) revert NotOrganizationOwner();
        if (employee.id == 0) revert EmployeeNotFound();
        if (employee.orgId != orgId) revert EmployeeNotFound();
        if (!employee.active) revert EmployeeNotActive();

        employee.active = false;
        _isOrgEmployee[employee.wallet][orgId] = false;

        emit EmployeeDeactivated(orgId, employeeId);
    }

    function getOrganization(uint256 orgId) external view returns (Organization memory) {
        Organization memory org = _organizations[orgId];
        if (org.id == 0) revert OrganizationNotFound();
        return org;
    }

    function getEmployee(uint256 employeeId) external view returns (Employee memory) {
        Employee memory employee = _employees[employeeId];
        if (employee.id == 0) revert EmployeeNotFound();
        return employee;
    }

    function getOrgEmployees(uint256 orgId) external view returns (uint256[] memory) {
        return _orgEmployees[orgId];
    }

    function getOwnerOrg(address owner) external view returns (uint256) {
        return _ownerToOrg[owner];
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    uint256[50] private __gap;
}
