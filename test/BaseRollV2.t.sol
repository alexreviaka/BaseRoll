// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/BaseRollV2.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock USDC", "USDC") {
        _mint(msg.sender, 1_000_000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract BaseRollV2Test is Test {
    BaseRollV2 public baseRoll;
    MockERC20 public token;

    address public admin;
    address public orgOwner;
    address public employee1;
    address public employee2;
    address public employee3;
    address public payoutAddress1;
    address public payoutAddress2;

    uint256 public orgId;

    event OrganizationRegistered(uint256 indexed orgId, address indexed owner, string name);
    event EmployeeAdded(uint256 indexed orgId, uint256 indexed employeeId, address indexed primaryWallet, string role);
    event EmployeeStatusChanged(
        uint256 indexed employeeId, BaseRollV2.EmployeeStatus oldStatus, BaseRollV2.EmployeeStatus newStatus
    );
    event CompensationProfileCreated(
        uint256 indexed profileId, uint256 indexed employeeId, uint256 baseAmount, uint256 effectiveFrom
    );
    event PayrollCycleCreated(uint256 indexed cycleId, uint256 indexed orgId, uint256 startTime, uint256 endTime);
    event PayrollCycleExecuted(uint256 indexed cycleId, uint256 totalAmount);
    event EmployeePaymentProcessed(uint256 indexed cycleId, uint256 indexed employeeId, uint256 amount);

    function setUp() public {
        admin = makeAddr("admin");
        orgOwner = makeAddr("orgOwner");
        employee1 = makeAddr("employee1");
        employee2 = makeAddr("employee2");
        employee3 = makeAddr("employee3");
        payoutAddress1 = makeAddr("payoutAddress1");
        payoutAddress2 = makeAddr("payoutAddress2");

        BaseRollV2 implementation = new BaseRollV2();
        bytes memory initData = abi.encodeCall(BaseRollV2.initialize, (admin));
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);

        baseRoll = BaseRollV2(address(proxy));

        token = new MockERC20();
        token.transfer(orgOwner, 500_000 ether);

        vm.startPrank(orgOwner);
        orgId = baseRoll.registerOrganization("Acme Corp", "metadata");
        vm.stopPrank();
    }

    function test_Initialize() public view {
        assertTrue(baseRoll.hasRole(baseRoll.DEFAULT_ADMIN_ROLE(), admin));
        assertEq(baseRoll.version(), "2.0.0");
    }

    function test_RegisterOrganization() public {
        address newOwner = makeAddr("newOwner");

        vm.startPrank(newOwner);

        vm.expectEmit(true, true, false, true);
        emit OrganizationRegistered(2, newOwner, "New Corp");

        uint256 newOrgId = baseRoll.registerOrganization("New Corp", "metadata");

        assertEq(newOrgId, 2);

        BaseRollV2.Organization memory org = baseRoll.getOrganization(newOrgId);
        assertEq(org.owner, newOwner);
        assertEq(org.name, "New Corp");
        assertTrue(org.active);

        vm.stopPrank();
    }

    function test_AddEmployeeWithSingleWallet() public {
        vm.startPrank(orgOwner);

        address[] memory payoutAddresses = new address[](0);
        uint256[] memory payoutPercentages = new uint256[](0);

        BaseRollV2.EmployeeMetadata memory metadata = BaseRollV2.EmployeeMetadata({
            role: "Engineer", department: "Engineering", jurisdictionCode: "US", customData: ""
        });

        uint256 employeeId = baseRoll.addEmployee(orgId, employee1, payoutAddresses, payoutPercentages, metadata);

        BaseRollV2.Employee memory emp = baseRoll.getEmployee(employeeId);
        assertEq(emp.primaryWallet, employee1);
        assertEq(uint256(emp.status), uint256(BaseRollV2.EmployeeStatus.ACTIVE));
        assertEq(emp.metadata.role, "Engineer");

        vm.stopPrank();
    }

    function test_AddEmployeeWithMultiplePayoutAddresses() public {
        vm.startPrank(orgOwner);

        address[] memory payoutAddresses = new address[](2);
        payoutAddresses[0] = payoutAddress1;
        payoutAddresses[1] = payoutAddress2;

        uint256[] memory payoutPercentages = new uint256[](2);
        payoutPercentages[0] = 7000;
        payoutPercentages[1] = 3000;

        BaseRollV2.EmployeeMetadata memory metadata = BaseRollV2.EmployeeMetadata({
            role: "Engineer", department: "Engineering", jurisdictionCode: "US", customData: ""
        });

        uint256 employeeId = baseRoll.addEmployee(orgId, employee1, payoutAddresses, payoutPercentages, metadata);

        BaseRollV2.Employee memory emp = baseRoll.getEmployee(employeeId);
        assertEq(emp.payoutAddresses.length, 2);
        assertEq(emp.payoutAddresses[0], payoutAddress1);
        assertEq(emp.payoutPercentages[0], 7000);
        assertEq(emp.payoutAddresses[1], payoutAddress2);
        assertEq(emp.payoutPercentages[1], 3000);

        vm.stopPrank();
    }

    function test_AddEmployee_RevertInvalidPayoutPercentages() public {
        vm.startPrank(orgOwner);

        address[] memory payoutAddresses = new address[](2);
        payoutAddresses[0] = payoutAddress1;
        payoutAddresses[1] = payoutAddress2;

        uint256[] memory payoutPercentages = new uint256[](2);
        payoutPercentages[0] = 6000;
        payoutPercentages[1] = 3000;

        BaseRollV2.EmployeeMetadata memory metadata = BaseRollV2.EmployeeMetadata({
            role: "Engineer", department: "Engineering", jurisdictionCode: "US", customData: ""
        });

        vm.expectRevert(BaseRollV2.InvalidPayoutConfiguration.selector);
        baseRoll.addEmployee(orgId, employee1, payoutAddresses, payoutPercentages, metadata);

        vm.stopPrank();
    }

    function test_CreateCompensationProfile() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        BaseRollV2.CompensationComponent memory compensation = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 1000 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        uint256 effectiveFrom = block.timestamp;

        vm.expectEmit(true, true, false, true);
        emit CompensationProfileCreated(1, employeeId, 5000 ether, effectiveFrom);

        uint256 profileId = baseRoll.createCompensationProfile(employeeId, compensation, effectiveFrom);

        BaseRollV2.CompensationProfile memory profile = baseRoll.getCompensationProfile(profileId);
        assertEq(profile.employeeId, employeeId);
        assertEq(profile.compensation.baseAmount, 5000 ether);
        assertEq(profile.compensation.bonusAmount, 1000 ether);
        assertTrue(profile.active);

        vm.stopPrank();
    }

    function test_UpdateSalaryBetweenCycles() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        BaseRollV2.CompensationComponent memory comp1 = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 0,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        uint256 profile1Id = baseRoll.createCompensationProfile(employeeId, comp1, block.timestamp);

        vm.warp(block.timestamp + 30 days);

        BaseRollV2.CompensationComponent memory comp2 = BaseRollV2.CompensationComponent({
            baseAmount: 6000 ether,
            bonusAmount: 500 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        uint256 profile2Id = baseRoll.createCompensationProfile(employeeId, comp2, block.timestamp);

        BaseRollV2.CompensationProfile memory oldProfile = baseRoll.getCompensationProfile(profile1Id);
        assertFalse(oldProfile.active);
        assertEq(oldProfile.effectiveUntil, block.timestamp);

        BaseRollV2.CompensationProfile memory newProfile = baseRoll.getCompensationProfile(profile2Id);
        assertTrue(newProfile.active);
        assertEq(newProfile.compensation.baseAmount, 6000 ether);

        vm.stopPrank();
    }

    function test_CreatePayrollCycle() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        BaseRollV2.CompensationComponent memory compensation = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 1000 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(employeeId, compensation, block.timestamp);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        vm.expectEmit(true, true, false, true);
        emit PayrollCycleCreated(1, orgId, startTime, endTime);

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        BaseRollV2.PayrollCycle memory cycle = baseRoll.getPayrollCycle(cycleId);
        assertEq(cycle.orgId, orgId);
        assertEq(cycle.startTime, startTime);
        assertEq(cycle.endTime, endTime);
        assertEq(uint256(cycle.status), uint256(BaseRollV2.CycleStatus.PENDING));

        BaseRollV2.PayrollCycleEmployee[] memory cycleEmployees = baseRoll.getCycleEmployees(cycleId);
        assertEq(cycleEmployees.length, 1);
        assertEq(cycleEmployees[0].employeeId, employeeId);
        assertEq(cycleEmployees[0].totalAmount, 6000 ether);

        vm.stopPrank();
    }

    function test_ExecutePayrollCycle() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        BaseRollV2.CompensationComponent memory compensation = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 1000 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(employeeId, compensation, block.timestamp);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        token.approve(address(baseRoll), 10_000 ether);

        uint256 balanceBefore = token.balanceOf(employee1);

        vm.expectEmit(true, true, false, true);
        emit PayrollCycleExecuted(cycleId, 6000 ether);

        baseRoll.executePayrollCycle(cycleId);

        uint256 balanceAfter = token.balanceOf(employee1);

        assertEq(balanceAfter - balanceBefore, 6000 ether);

        BaseRollV2.PayrollCycle memory cycle = baseRoll.getPayrollCycle(cycleId);
        assertEq(uint256(cycle.status), uint256(BaseRollV2.CycleStatus.EXECUTED));
        assertEq(cycle.totalAmount, 6000 ether);

        vm.stopPrank();
    }

    function test_ExecutePayrollCycleWithMultipleEmployees() public {
        vm.startPrank(orgOwner);

        uint256 emp1Id = _addBasicEmployee(employee1, "Engineer");
        uint256 emp2Id = _addBasicEmployee(employee2, "Designer");
        uint256 emp3Id = _addBasicEmployee(employee3, "Manager");

        BaseRollV2.CompensationComponent memory comp1 = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 1000 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        BaseRollV2.CompensationComponent memory comp2 = BaseRollV2.CompensationComponent({
            baseAmount: 4000 ether,
            bonusAmount: 500 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        BaseRollV2.CompensationComponent memory comp3 = BaseRollV2.CompensationComponent({
            baseAmount: 7000 ether,
            bonusAmount: 2000 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(emp1Id, comp1, block.timestamp);
        baseRoll.createCompensationProfile(emp2Id, comp2, block.timestamp);
        baseRoll.createCompensationProfile(emp3Id, comp3, block.timestamp);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        uint256 totalRequired = 6000 ether + 4500 ether + 9000 ether;

        token.approve(address(baseRoll), totalRequired);

        baseRoll.executePayrollCycle(cycleId);

        assertEq(token.balanceOf(employee1), 6000 ether);
        assertEq(token.balanceOf(employee2), 4500 ether);
        assertEq(token.balanceOf(employee3), 9000 ether);

        vm.stopPrank();
    }

    function test_ExecutePayrollCycleWithMultiplePayoutAddresses() public {
        vm.startPrank(orgOwner);

        address[] memory payoutAddresses = new address[](2);
        payoutAddresses[0] = payoutAddress1;
        payoutAddresses[1] = payoutAddress2;

        uint256[] memory payoutPercentages = new uint256[](2);
        payoutPercentages[0] = 7000;
        payoutPercentages[1] = 3000;

        BaseRollV2.EmployeeMetadata memory metadata = BaseRollV2.EmployeeMetadata({
            role: "Engineer", department: "Engineering", jurisdictionCode: "US", customData: ""
        });

        uint256 employeeId = baseRoll.addEmployee(orgId, employee1, payoutAddresses, payoutPercentages, metadata);

        BaseRollV2.CompensationComponent memory compensation = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 1000 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(employeeId, compensation, block.timestamp);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        token.approve(address(baseRoll), 10_000 ether);

        baseRoll.executePayrollCycle(cycleId);

        assertEq(token.balanceOf(payoutAddress1), 4200 ether);
        assertEq(token.balanceOf(payoutAddress2), 1800 ether);

        vm.stopPrank();
    }

    function test_DeactivateEmployeeMidCycle() public {
        vm.startPrank(orgOwner);

        uint256 emp1Id = _addBasicEmployee(employee1, "Engineer");
        uint256 emp2Id = _addBasicEmployee(employee2, "Designer");

        BaseRollV2.CompensationComponent memory comp = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 0,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(emp1Id, comp, block.timestamp);
        baseRoll.createCompensationProfile(emp2Id, comp, block.timestamp);

        uint256 startTime = block.timestamp;

        vm.warp(startTime + 15 days);

        baseRoll.setEmployeeStatus(emp1Id, BaseRollV2.EmployeeStatus.INACTIVE);

        vm.warp(startTime + 20 days);

        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        BaseRollV2.PayrollCycleEmployee[] memory cycleEmployees = baseRoll.getCycleEmployees(cycleId);

        assertEq(cycleEmployees.length, 1);
        assertEq(cycleEmployees[0].employeeId, emp2Id);

        token.approve(address(baseRoll), 10_000 ether);
        baseRoll.executePayrollCycle(cycleId);

        assertEq(token.balanceOf(employee1), 0);
        assertEq(token.balanceOf(employee2), 5000 ether);

        vm.stopPrank();
    }

    function test_ReactivateEmployee() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        vm.expectEmit(true, false, false, true);
        emit EmployeeStatusChanged(employeeId, BaseRollV2.EmployeeStatus.ACTIVE, BaseRollV2.EmployeeStatus.INACTIVE);

        baseRoll.setEmployeeStatus(employeeId, BaseRollV2.EmployeeStatus.INACTIVE);

        BaseRollV2.Employee memory emp = baseRoll.getEmployee(employeeId);
        assertEq(uint256(emp.status), uint256(BaseRollV2.EmployeeStatus.INACTIVE));

        vm.expectEmit(true, false, false, true);
        emit EmployeeStatusChanged(employeeId, BaseRollV2.EmployeeStatus.INACTIVE, BaseRollV2.EmployeeStatus.ACTIVE);

        baseRoll.setEmployeeStatus(employeeId, BaseRollV2.EmployeeStatus.ACTIVE);

        emp = baseRoll.getEmployee(employeeId);
        assertEq(uint256(emp.status), uint256(BaseRollV2.EmployeeStatus.ACTIVE));

        vm.stopPrank();
    }

    function test_TerminateEmployee() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        baseRoll.setEmployeeStatus(employeeId, BaseRollV2.EmployeeStatus.TERMINATED);

        BaseRollV2.Employee memory emp = baseRoll.getEmployee(employeeId);
        assertEq(uint256(emp.status), uint256(BaseRollV2.EmployeeStatus.TERMINATED));

        vm.stopPrank();
    }

    function test_CreateCycleExcludesInactiveEmployees() public {
        vm.startPrank(orgOwner);

        uint256 emp1Id = _addBasicEmployee(employee1, "Engineer");
        uint256 emp2Id = _addBasicEmployee(employee2, "Designer");
        uint256 emp3Id = _addBasicEmployee(employee3, "Manager");

        BaseRollV2.CompensationComponent memory comp = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 0,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(emp1Id, comp, block.timestamp);
        baseRoll.createCompensationProfile(emp2Id, comp, block.timestamp);
        baseRoll.createCompensationProfile(emp3Id, comp, block.timestamp);

        baseRoll.setEmployeeStatus(emp2Id, BaseRollV2.EmployeeStatus.INACTIVE);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        BaseRollV2.PayrollCycleEmployee[] memory cycleEmployees = baseRoll.getCycleEmployees(cycleId);

        assertEq(cycleEmployees.length, 2);

        bool hasEmp1 = false;
        bool hasEmp3 = false;

        for (uint256 i = 0; i < cycleEmployees.length; i++) {
            if (cycleEmployees[i].employeeId == emp1Id) hasEmp1 = true;
            if (cycleEmployees[i].employeeId == emp3Id) hasEmp3 = true;
            assertTrue(cycleEmployees[i].employeeId != emp2Id);
        }

        assertTrue(hasEmp1);
        assertTrue(hasEmp3);

        vm.stopPrank();
    }

    function test_CreateCycleWithZeroEmployees() public {
        vm.startPrank(orgOwner);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        BaseRollV2.PayrollCycleEmployee[] memory cycleEmployees = baseRoll.getCycleEmployees(cycleId);
        assertEq(cycleEmployees.length, 0);

        vm.stopPrank();
    }

    function test_ExecuteCycleWithZeroEmployees() public {
        vm.startPrank(orgOwner);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        baseRoll.executePayrollCycle(cycleId);

        BaseRollV2.PayrollCycle memory cycle = baseRoll.getPayrollCycle(cycleId);
        assertEq(uint256(cycle.status), uint256(BaseRollV2.CycleStatus.EXECUTED));
        assertEq(cycle.totalAmount, 0);

        vm.stopPrank();
    }

    function test_FinalizePayrollCycle() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        BaseRollV2.CompensationComponent memory compensation = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 0,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(employeeId, compensation, block.timestamp);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        token.approve(address(baseRoll), 10_000 ether);
        baseRoll.executePayrollCycle(cycleId);

        baseRoll.finalizePayrollCycle(cycleId);

        BaseRollV2.PayrollCycle memory cycle = baseRoll.getPayrollCycle(cycleId);
        assertEq(uint256(cycle.status), uint256(BaseRollV2.CycleStatus.FINALIZED));
        assertGt(cycle.finalizedAt, 0);

        vm.stopPrank();
    }

    function test_EmployeeWithoutCompensationExcludedFromCycle() public {
        vm.startPrank(orgOwner);

        uint256 emp1Id = _addBasicEmployee(employee1, "Engineer");
        _addBasicEmployee(employee2, "Designer");

        BaseRollV2.CompensationComponent memory comp = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 0,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(emp1Id, comp, block.timestamp);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 30 days;

        uint256 cycleId =
            baseRoll.createPayrollCycle(orgId, BaseRollV2.PayrollPeriod.MONTHLY, startTime, endTime, address(token));

        BaseRollV2.PayrollCycleEmployee[] memory cycleEmployees = baseRoll.getCycleEmployees(cycleId);

        assertEq(cycleEmployees.length, 1);
        assertEq(cycleEmployees[0].employeeId, emp1Id);

        vm.stopPrank();
    }

    function test_GetActiveCompensationForTimestamp() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        uint256 time1 = block.timestamp;

        BaseRollV2.CompensationComponent memory comp1 = BaseRollV2.CompensationComponent({
            baseAmount: 5000 ether,
            bonusAmount: 0,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(employeeId, comp1, time1);

        vm.warp(time1 + 30 days);
        uint256 time2 = block.timestamp;

        BaseRollV2.CompensationComponent memory comp2 = BaseRollV2.CompensationComponent({
            baseAmount: 6000 ether,
            bonusAmount: 500 ether,
            tokenAddress: address(0),
            tokenAmount: 0,
            vestingDuration: 0,
            vestingCliff: 0
        });

        baseRoll.createCompensationProfile(employeeId, comp2, time2);

        BaseRollV2.CompensationProfile memory activeAtTime1 =
            baseRoll.getActiveCompensation(employeeId, time1 + 15 days);
        assertEq(activeAtTime1.compensation.baseAmount, 5000 ether);

        BaseRollV2.CompensationProfile memory activeAtTime2 =
            baseRoll.getActiveCompensation(employeeId, time2 + 15 days);
        assertEq(activeAtTime2.compensation.baseAmount, 6000 ether);

        vm.stopPrank();
    }

    function test_MultipleCompensationUpdates() public {
        vm.startPrank(orgOwner);

        uint256 employeeId = _addBasicEmployee(employee1, "Engineer");

        uint256[] memory times = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);

        for (uint256 i = 0; i < 4; i++) {
            times[i] = block.timestamp + (i * 30 days);
            amounts[i] = 5000 ether + (i * 500 ether);

            BaseRollV2.CompensationComponent memory comp = BaseRollV2.CompensationComponent({
                baseAmount: amounts[i],
                bonusAmount: 0,
                tokenAddress: address(0),
                tokenAmount: 0,
                vestingDuration: 0,
                vestingCliff: 0
            });

            baseRoll.createCompensationProfile(employeeId, comp, times[i]);
        }

        uint256[] memory profiles = baseRoll.getEmployeeCompensations(employeeId);
        assertEq(profiles.length, 4);

        for (uint256 i = 0; i < 3; i++) {
            BaseRollV2.CompensationProfile memory profile = baseRoll.getCompensationProfile(profiles[i]);
            assertFalse(profile.active);
            assertEq(profile.effectiveUntil, times[i + 1]);
        }

        BaseRollV2.CompensationProfile memory lastProfile = baseRoll.getCompensationProfile(profiles[3]);
        assertTrue(lastProfile.active);
        assertEq(lastProfile.effectiveUntil, 0);

        vm.stopPrank();
    }

    function _addBasicEmployee(address wallet, string memory role) internal returns (uint256) {
        address[] memory payoutAddresses = new address[](0);
        uint256[] memory payoutPercentages = new uint256[](0);

        BaseRollV2.EmployeeMetadata memory metadata = BaseRollV2.EmployeeMetadata({
            role: role, department: "Engineering", jurisdictionCode: "US", customData: ""
        });

        return baseRoll.addEmployee(orgId, wallet, payoutAddresses, payoutPercentages, metadata);
    }
}
