// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract BaseRollV2 is Initializable, UUPSUpgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ORG_OWNER_ROLE = keccak256("ORG_OWNER_ROLE");

    enum PayrollPeriod {
        WEEKLY,
        BIWEEKLY,
        MONTHLY
    }

    enum CycleStatus {
        PENDING,
        EXECUTED,
        FINALIZED
    }

    enum EmployeeStatus {
        ACTIVE,
        INACTIVE,
        TERMINATED
    }

    struct Organization {
        uint256 id;
        address owner;
        string name;
        string metadata;
        uint256 createdAt;
        bool active;
    }

    struct EmployeeMetadata {
        string role;
        string department;
        string jurisdictionCode;
        string customData;
    }

    struct Employee {
        uint256 id;
        uint256 orgId;
        address primaryWallet;
        address[] payoutAddresses;
        uint256[] payoutPercentages;
        EmployeeMetadata metadata;
        EmployeeStatus status;
        uint256 addedAt;
        uint256 updatedAt;
    }

    struct CompensationComponent {
        uint256 baseAmount;
        uint256 bonusAmount;
        address tokenAddress;
        uint256 tokenAmount;
        uint256 vestingDuration;
        uint256 vestingCliff;
    }

    struct CompensationProfile {
        uint256 id;
        uint256 employeeId;
        CompensationComponent compensation;
        uint256 effectiveFrom;
        uint256 effectiveUntil;
        bool active;
        uint256 createdAt;
    }

    struct PayrollCycleEmployee {
        uint256 employeeId;
        uint256 baseAmount;
        uint256 bonusAmount;
        uint256 totalAmount;
        bool paid;
    }

    struct PayrollCycle {
        uint256 id;
        uint256 orgId;
        PayrollPeriod period;
        uint256 startTime;
        uint256 endTime;
        CycleStatus status;
        uint256 totalAmount;
        uint256 executedAt;
        uint256 finalizedAt;
        address paymentToken;
    }

    uint256 private _orgIdCounter;
    uint256 private _employeeIdCounter;
    uint256 private _compensationIdCounter;
    uint256 private _cycleIdCounter;

    mapping(uint256 => Organization) private _organizations;
    mapping(uint256 => Employee) private _employees;
    mapping(uint256 => CompensationProfile) private _compensations;
    mapping(uint256 => PayrollCycle) private _cycles;

    mapping(uint256 => uint256[]) private _orgEmployees;
    mapping(uint256 => uint256[]) private _employeeCompensations;
    mapping(uint256 => uint256[]) private _orgCycles;
    mapping(uint256 => PayrollCycleEmployee[]) private _cycleEmployees;

    mapping(address => uint256) private _ownerToOrg;
    mapping(address => mapping(uint256 => bool)) private _isOrgEmployee;

    event OrganizationRegistered(uint256 indexed orgId, address indexed owner, string name);
    event OrganizationMetadataUpdated(uint256 indexed orgId, string metadata);

    event EmployeeAdded(uint256 indexed orgId, uint256 indexed employeeId, address indexed primaryWallet, string role);
    event EmployeeUpdated(uint256 indexed employeeId, string metadata);
    event EmployeeStatusChanged(uint256 indexed employeeId, EmployeeStatus oldStatus, EmployeeStatus newStatus);
    event EmployeePayoutAddressesUpdated(uint256 indexed employeeId, address[] addresses);

    event CompensationProfileCreated(
        uint256 indexed profileId, uint256 indexed employeeId, uint256 baseAmount, uint256 effectiveFrom
    );
    event CompensationProfileUpdated(uint256 indexed profileId, uint256 effectiveUntil);

    event PayrollCycleCreated(uint256 indexed cycleId, uint256 indexed orgId, uint256 startTime, uint256 endTime);
    event PayrollCycleExecuted(uint256 indexed cycleId, uint256 totalAmount);
    event PayrollCycleFinalized(uint256 indexed cycleId);
    event EmployeePaymentProcessed(uint256 indexed cycleId, uint256 indexed employeeId, uint256 amount);

    error OrganizationAlreadyExists();
    error OrganizationNotFound();
    error OrganizationNotActive();
    error EmployeeNotFound();
    error EmployeeAlreadyExists();
    error EmployeeNotActive();
    error NotOrganizationOwner();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidPayoutConfiguration();
    error InvalidTimeRange();
    error CompensationProfileNotFound();
    error CompensationProfileNotActive();
    error PayrollCycleNotFound();
    error PayrollCycleAlreadyExecuted();
    error PayrollCycleNotExecuted();
    error PayrollCycleAlreadyFinalized();
    error InsufficientBalance();
    error PaymentFailed();
    error InvalidEmployeeStatus();

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
            id: orgId, owner: msg.sender, name: name, metadata: metadata, createdAt: block.timestamp, active: true
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

    function addEmployee(
        uint256 orgId,
        address primaryWallet,
        address[] calldata payoutAddresses,
        uint256[] calldata payoutPercentages,
        EmployeeMetadata calldata metadata
    )
        external
        returns (uint256)
    {
        if (primaryWallet == address(0)) revert InvalidAddress();

        Organization storage org = _organizations[orgId];
        if (org.id == 0) revert OrganizationNotFound();
        if (org.owner != msg.sender) revert NotOrganizationOwner();
        if (_isOrgEmployee[primaryWallet][orgId]) revert EmployeeAlreadyExists();

        if (payoutAddresses.length > 0) {
            if (payoutAddresses.length != payoutPercentages.length) {
                revert InvalidPayoutConfiguration();
            }

            uint256 totalPercentage;
            for (uint256 i = 0; i < payoutPercentages.length; i++) {
                if (payoutAddresses[i] == address(0)) revert InvalidAddress();
                totalPercentage += payoutPercentages[i];
            }

            if (totalPercentage != 10_000) revert InvalidPayoutConfiguration();
        }

        unchecked {
            ++_employeeIdCounter;
        }

        uint256 employeeId = _employeeIdCounter;

        _employees[employeeId] = Employee({
            id: employeeId,
            orgId: orgId,
            primaryWallet: primaryWallet,
            payoutAddresses: payoutAddresses,
            payoutPercentages: payoutPercentages,
            metadata: metadata,
            status: EmployeeStatus.ACTIVE,
            addedAt: block.timestamp,
            updatedAt: block.timestamp
        });

        _orgEmployees[orgId].push(employeeId);
        _isOrgEmployee[primaryWallet][orgId] = true;

        emit EmployeeAdded(orgId, employeeId, primaryWallet, metadata.role);

        return employeeId;
    }

    function updateEmployeeMetadata(uint256 employeeId, EmployeeMetadata calldata metadata) external {
        Employee storage employee = _employees[employeeId];

        if (employee.id == 0) revert EmployeeNotFound();

        Organization storage org = _organizations[employee.orgId];
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        employee.metadata = metadata;
        employee.updatedAt = block.timestamp;

        emit EmployeeUpdated(employeeId, "metadata");
    }

    function updateEmployeePayoutAddresses(
        uint256 employeeId,
        address[] calldata payoutAddresses,
        uint256[] calldata payoutPercentages
    )
        external
    {
        Employee storage employee = _employees[employeeId];

        if (employee.id == 0) revert EmployeeNotFound();

        Organization storage org = _organizations[employee.orgId];
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        if (payoutAddresses.length != payoutPercentages.length) {
            revert InvalidPayoutConfiguration();
        }

        if (payoutAddresses.length > 0) {
            uint256 totalPercentage;
            for (uint256 i = 0; i < payoutPercentages.length; i++) {
                if (payoutAddresses[i] == address(0)) revert InvalidAddress();
                totalPercentage += payoutPercentages[i];
            }

            if (totalPercentage != 10_000) revert InvalidPayoutConfiguration();
        }

        employee.payoutAddresses = payoutAddresses;
        employee.payoutPercentages = payoutPercentages;
        employee.updatedAt = block.timestamp;

        emit EmployeePayoutAddressesUpdated(employeeId, payoutAddresses);
    }

    function setEmployeeStatus(uint256 employeeId, EmployeeStatus newStatus) external {
        Employee storage employee = _employees[employeeId];

        if (employee.id == 0) revert EmployeeNotFound();

        Organization storage org = _organizations[employee.orgId];
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        EmployeeStatus oldStatus = employee.status;

        if (oldStatus == newStatus) revert InvalidEmployeeStatus();

        employee.status = newStatus;
        employee.updatedAt = block.timestamp;

        if (newStatus != EmployeeStatus.ACTIVE) {
            _isOrgEmployee[employee.primaryWallet][employee.orgId] = false;
        } else {
            _isOrgEmployee[employee.primaryWallet][employee.orgId] = true;
        }

        emit EmployeeStatusChanged(employeeId, oldStatus, newStatus);
    }

    function createCompensationProfile(
        uint256 employeeId,
        CompensationComponent calldata compensation,
        uint256 effectiveFrom
    )
        external
        returns (uint256)
    {
        Employee storage employee = _employees[employeeId];

        if (employee.id == 0) revert EmployeeNotFound();

        Organization storage org = _organizations[employee.orgId];
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        if (compensation.baseAmount == 0 && compensation.bonusAmount == 0 && compensation.tokenAmount == 0) {
            revert InvalidAmount();
        }

        if (effectiveFrom < block.timestamp) revert InvalidTimeRange();

        uint256[] storage existingProfiles = _employeeCompensations[employeeId];
        for (uint256 i = 0; i < existingProfiles.length; i++) {
            CompensationProfile storage existing = _compensations[existingProfiles[i]];
            if (existing.active && existing.effectiveUntil == 0) {
                existing.effectiveUntil = effectiveFrom;
                existing.active = false;
                emit CompensationProfileUpdated(existing.id, effectiveFrom);
            }
        }

        unchecked {
            ++_compensationIdCounter;
        }

        uint256 profileId = _compensationIdCounter;

        _compensations[profileId] = CompensationProfile({
            id: profileId,
            employeeId: employeeId,
            compensation: compensation,
            effectiveFrom: effectiveFrom,
            effectiveUntil: 0,
            active: true,
            createdAt: block.timestamp
        });

        _employeeCompensations[employeeId].push(profileId);

        emit CompensationProfileCreated(profileId, employeeId, compensation.baseAmount, effectiveFrom);

        return profileId;
    }

    function createPayrollCycle(
        uint256 orgId,
        PayrollPeriod period,
        uint256 startTime,
        uint256 endTime,
        address paymentToken
    )
        external
        returns (uint256)
    {
        Organization storage org = _organizations[orgId];

        if (org.id == 0) revert OrganizationNotFound();
        if (org.owner != msg.sender) revert NotOrganizationOwner();
        if (!org.active) revert OrganizationNotActive();

        if (startTime >= endTime) revert InvalidTimeRange();
        if (paymentToken == address(0)) revert InvalidAddress();

        unchecked {
            ++_cycleIdCounter;
        }

        uint256 cycleId = _cycleIdCounter;

        _cycles[cycleId] = PayrollCycle({
            id: cycleId,
            orgId: orgId,
            period: period,
            startTime: startTime,
            endTime: endTime,
            status: CycleStatus.PENDING,
            totalAmount: 0,
            executedAt: 0,
            finalizedAt: 0,
            paymentToken: paymentToken
        });

        _orgCycles[orgId].push(cycleId);

        uint256[] memory employeeIds = _orgEmployees[orgId];

        for (uint256 i = 0; i < employeeIds.length; i++) {
            Employee storage employee = _employees[employeeIds[i]];

            if (employee.status != EmployeeStatus.ACTIVE) continue;

            CompensationProfile memory activeComp = _getActiveCompensation(employeeIds[i], startTime);

            if (activeComp.id == 0) continue;

            uint256 totalAmount = activeComp.compensation.baseAmount + activeComp.compensation.bonusAmount;

            _cycleEmployees[cycleId].push(
                PayrollCycleEmployee({
                    employeeId: employeeIds[i],
                    baseAmount: activeComp.compensation.baseAmount,
                    bonusAmount: activeComp.compensation.bonusAmount,
                    totalAmount: totalAmount,
                    paid: false
                })
            );
        }

        emit PayrollCycleCreated(cycleId, orgId, startTime, endTime);

        return cycleId;
    }

    function executePayrollCycle(uint256 cycleId) external nonReentrant {
        PayrollCycle storage cycle = _cycles[cycleId];

        if (cycle.id == 0) revert PayrollCycleNotFound();

        Organization storage org = _organizations[cycle.orgId];
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        if (cycle.status != CycleStatus.PENDING) revert PayrollCycleAlreadyExecuted();

        PayrollCycleEmployee[] storage employees = _cycleEmployees[cycleId];

        uint256 totalRequired;
        for (uint256 i = 0; i < employees.length; i++) {
            if (!employees[i].paid) {
                totalRequired += employees[i].totalAmount;
            }
        }

        IERC20Upgradeable token = IERC20Upgradeable(cycle.paymentToken);
        uint256 balance = token.balanceOf(msg.sender);

        if (balance < totalRequired) revert InsufficientBalance();

        uint256 totalPaid;

        for (uint256 i = 0; i < employees.length; i++) {
            if (employees[i].paid) continue;

            Employee storage employee = _employees[employees[i].employeeId];
            uint256 amount = employees[i].totalAmount;

            if (employee.payoutAddresses.length > 0) {
                for (uint256 j = 0; j < employee.payoutAddresses.length; j++) {
                    uint256 payoutAmount = (amount * employee.payoutPercentages[j]) / 10_000;
                    token.safeTransferFrom(msg.sender, employee.payoutAddresses[j], payoutAmount);
                }
            } else {
                token.safeTransferFrom(msg.sender, employee.primaryWallet, amount);
            }

            employees[i].paid = true;
            totalPaid += amount;

            emit EmployeePaymentProcessed(cycleId, employees[i].employeeId, amount);
        }

        cycle.status = CycleStatus.EXECUTED;
        cycle.totalAmount = totalPaid;
        cycle.executedAt = block.timestamp;

        emit PayrollCycleExecuted(cycleId, totalPaid);
    }

    function finalizePayrollCycle(uint256 cycleId) external {
        PayrollCycle storage cycle = _cycles[cycleId];

        if (cycle.id == 0) revert PayrollCycleNotFound();

        Organization storage org = _organizations[cycle.orgId];
        if (org.owner != msg.sender) revert NotOrganizationOwner();

        if (cycle.status != CycleStatus.EXECUTED) revert PayrollCycleNotExecuted();
        if (cycle.finalizedAt != 0) revert PayrollCycleAlreadyFinalized();

        cycle.status = CycleStatus.FINALIZED;
        cycle.finalizedAt = block.timestamp;

        emit PayrollCycleFinalized(cycleId);
    }

    function _getActiveCompensation(
        uint256 employeeId,
        uint256 timestamp
    )
        internal
        view
        returns (CompensationProfile memory)
    {
        uint256[] storage profiles = _employeeCompensations[employeeId];

        for (uint256 i = 0; i < profiles.length; i++) {
            CompensationProfile storage profile = _compensations[profiles[i]];

            if (
                profile.effectiveFrom <= timestamp
                    && (profile.effectiveUntil == 0 || profile.effectiveUntil > timestamp)
            ) {
                return profile;
            }
        }

        return CompensationProfile({
            id: 0,
            employeeId: 0,
            compensation: CompensationComponent({
                baseAmount: 0,
                bonusAmount: 0,
                tokenAddress: address(0),
                tokenAmount: 0,
                vestingDuration: 0,
                vestingCliff: 0
            }),
            effectiveFrom: 0,
            effectiveUntil: 0,
            active: false,
            createdAt: 0
        });
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

    function getCompensationProfile(uint256 profileId) external view returns (CompensationProfile memory) {
        CompensationProfile memory profile = _compensations[profileId];
        if (profile.id == 0) revert CompensationProfileNotFound();
        return profile;
    }

    function getPayrollCycle(uint256 cycleId) external view returns (PayrollCycle memory) {
        PayrollCycle memory cycle = _cycles[cycleId];
        if (cycle.id == 0) revert PayrollCycleNotFound();
        return cycle;
    }

    function getOrgEmployees(uint256 orgId) external view returns (uint256[] memory) {
        return _orgEmployees[orgId];
    }

    function getEmployeeCompensations(uint256 employeeId) external view returns (uint256[] memory) {
        return _employeeCompensations[employeeId];
    }

    function getOrgCycles(uint256 orgId) external view returns (uint256[] memory) {
        return _orgCycles[orgId];
    }

    function getCycleEmployees(uint256 cycleId) external view returns (PayrollCycleEmployee[] memory) {
        return _cycleEmployees[cycleId];
    }

    function getActiveCompensation(
        uint256 employeeId,
        uint256 timestamp
    )
        external
        view
        returns (CompensationProfile memory)
    {
        return _getActiveCompensation(employeeId, timestamp);
    }

    function getOwnerOrg(address owner) external view returns (uint256) {
        return _ownerToOrg[owner];
    }

    function version() external pure returns (string memory) {
        return "2.0.0";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) { }

    uint256[50] private __gap;
}
