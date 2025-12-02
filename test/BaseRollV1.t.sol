// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../contracts/BaseRollV1.sol";

contract BaseRollV1Test is Test {
    BaseRollV1 public baseRoll;
    address public admin;
    address public orgOwner;
    address public employee;

    event OrganizationRegistered(uint256 indexed orgId, address indexed owner, string name);
    event EmployeeAdded(uint256 indexed orgId, uint256 indexed employeeId, address indexed wallet, uint256 baseSalary);

    function setUp() public {
        admin = makeAddr("admin");
        orgOwner = makeAddr("orgOwner");
        employee = makeAddr("employee");

        BaseRollV1 implementation = new BaseRollV1();
        bytes memory initData = abi.encodeCall(BaseRollV1.initialize, (admin));
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);

        baseRoll = BaseRollV1(address(proxy));
    }

    function test_Initialize() public view {
        assertTrue(baseRoll.hasRole(baseRoll.DEFAULT_ADMIN_ROLE(), admin));
        assertEq(baseRoll.version(), "1.0.0");
    }

    function test_RegisterOrganization() public {
        vm.startPrank(orgOwner);

        vm.expectEmit(true, true, false, true);
        emit OrganizationRegistered(1, orgOwner, "Acme Corp");

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        assertEq(orgId, 1);

        BaseRollV1.Organization memory org = baseRoll.getOrganization(orgId);
        assertEq(org.owner, orgOwner);
        assertEq(org.name, "Acme Corp");
        assertTrue(org.active);

        vm.stopPrank();
    }

    function test_RegisterOrganization_RevertIfAlreadyExists() public {
        vm.startPrank(orgOwner);

        baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.expectRevert(BaseRollV1.OrganizationAlreadyExists.selector);
        baseRoll.registerOrganization("Another Corp", "metadata");

        vm.stopPrank();
    }

    function test_SetOrgMetadata() public {
        vm.startPrank(orgOwner);

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "initial");
        baseRoll.setOrgMetadata(orgId, "updated");

        BaseRollV1.Organization memory org = baseRoll.getOrganization(orgId);
        assertEq(org.metadata, "updated");

        vm.stopPrank();
    }

    function test_SetOrgMetadata_RevertIfNotOwner() public {
        vm.prank(orgOwner);
        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.prank(makeAddr("stranger"));
        vm.expectRevert(BaseRollV1.NotOrganizationOwner.selector);
        baseRoll.setOrgMetadata(orgId, "hacked");
    }

    function test_AddEmployee() public {
        vm.startPrank(orgOwner);

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.expectEmit(true, true, true, true);
        emit EmployeeAdded(orgId, 1, employee, 5000 ether);

        uint256 employeeId = baseRoll.addEmployee(orgId, employee, 5000 ether);

        assertEq(employeeId, 1);

        BaseRollV1.Employee memory emp = baseRoll.getEmployee(employeeId);
        assertEq(emp.wallet, employee);
        assertEq(emp.baseSalary, 5000 ether);
        assertEq(emp.orgId, orgId);
        assertTrue(emp.active);

        vm.stopPrank();
    }

    function test_AddEmployee_RevertIfZeroAddress() public {
        vm.startPrank(orgOwner);

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.expectRevert(BaseRollV1.InvalidAddress.selector);
        baseRoll.addEmployee(orgId, address(0), 5000 ether);

        vm.stopPrank();
    }

    function test_AddEmployee_RevertIfZeroSalary() public {
        vm.startPrank(orgOwner);

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.expectRevert(BaseRollV1.InvalidSalary.selector);
        baseRoll.addEmployee(orgId, employee, 0);

        vm.stopPrank();
    }

    function test_AddEmployee_RevertIfNotOwner() public {
        vm.prank(orgOwner);
        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.prank(makeAddr("stranger"));
        vm.expectRevert(BaseRollV1.NotOrganizationOwner.selector);
        baseRoll.addEmployee(orgId, employee, 5000 ether);
    }

    function test_DeactivateEmployee() public {
        vm.startPrank(orgOwner);

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");
        uint256 employeeId = baseRoll.addEmployee(orgId, employee, 5000 ether);

        baseRoll.deactivateEmployee(orgId, employeeId);

        BaseRollV1.Employee memory emp = baseRoll.getEmployee(employeeId);
        assertFalse(emp.active);

        vm.stopPrank();
    }

    function test_DeactivateEmployee_RevertIfNotOwner() public {
        vm.prank(orgOwner);
        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        vm.prank(orgOwner);
        uint256 employeeId = baseRoll.addEmployee(orgId, employee, 5000 ether);

        vm.prank(makeAddr("stranger"));
        vm.expectRevert(BaseRollV1.NotOrganizationOwner.selector);
        baseRoll.deactivateEmployee(orgId, employeeId);
    }

    function test_GetOrgEmployees() public {
        vm.startPrank(orgOwner);

        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        baseRoll.addEmployee(orgId, makeAddr("emp1"), 5000 ether);
        baseRoll.addEmployee(orgId, makeAddr("emp2"), 6000 ether);
        baseRoll.addEmployee(orgId, makeAddr("emp3"), 7000 ether);

        uint256[] memory employees = baseRoll.getOrgEmployees(orgId);
        assertEq(employees.length, 3);

        vm.stopPrank();
    }

    function test_GetOwnerOrg() public {
        vm.prank(orgOwner);
        uint256 orgId = baseRoll.registerOrganization("Acme Corp", "metadata");

        assertEq(baseRoll.getOwnerOrg(orgOwner), orgId);
    }
}
