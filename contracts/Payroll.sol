// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Payroll is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    struct Employee {
        address wallet;
        uint256 salary;
        address paymentToken;
        uint256 lastPaymentTime;
        bool isActive;
    }

    struct Payment {
        address employee;
        uint256 amount;
        address token;
        uint256 timestamp;
    }

    mapping(address => Employee) public employees;
    address[] public employeeList;
    Payment[] public paymentHistory;

    uint256 public constant PAYMENT_PERIOD = 30 days;

    event EmployeeAdded(address indexed employee, uint256 salary, address token);
    event EmployeeRemoved(address indexed employee);
    event SalaryUpdated(address indexed employee, uint256 newSalary);
    event PaymentProcessed(address indexed employee, uint256 amount, address token);

    error EmployeeAlreadyExists();
    error EmployeeNotFound();
    error InvalidAddress();
    error InvalidAmount();
    error PaymentTooEarly();
    error InsufficientBalance();

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __ReentrancyGuard_init();
    }

    function addEmployee(
        address _wallet,
        uint256 _salary,
        address _paymentToken
    ) external onlyOwner {
        if (_wallet == address(0)) revert InvalidAddress();
        if (_salary == 0) revert InvalidAmount();
        if (employees[_wallet].isActive) revert EmployeeAlreadyExists();

        employees[_wallet] = Employee({
            wallet: _wallet,
            salary: _salary,
            paymentToken: _paymentToken,
            lastPaymentTime: block.timestamp,
            isActive: true
        });

        employeeList.push(_wallet);
        emit EmployeeAdded(_wallet, _salary, _paymentToken);
    }

    function removeEmployee(address _wallet) external onlyOwner {
        if (!employees[_wallet].isActive) revert EmployeeNotFound();
        
        employees[_wallet].isActive = false;
        emit EmployeeRemoved(_wallet);
    }

    function updateSalary(address _wallet, uint256 _newSalary) external onlyOwner {
        if (!employees[_wallet].isActive) revert EmployeeNotFound();
        if (_newSalary == 0) revert InvalidAmount();
        
        employees[_wallet].salary = _newSalary;
        emit SalaryUpdated(_wallet, _newSalary);
    }

    function processPayment(address _employee) external nonReentrant {
        Employee storage employee = employees[_employee];
        
        if (!employee.isActive) revert EmployeeNotFound();
        if (block.timestamp < employee.lastPaymentTime + PAYMENT_PERIOD) {
            revert PaymentTooEarly();
        }

        uint256 amount = employee.salary;
        address token = employee.paymentToken;

        if (token == address(0)) {
            if (address(this).balance < amount) revert InsufficientBalance();
            payable(_employee).transfer(amount);
        } else {
            IERC20 paymentToken = IERC20(token);
            if (paymentToken.balanceOf(address(this)) < amount) {
                revert InsufficientBalance();
            }
            paymentToken.safeTransfer(_employee, amount);
        }

        employee.lastPaymentTime = block.timestamp;
        
        paymentHistory.push(Payment({
            employee: _employee,
            amount: amount,
            token: token,
            timestamp: block.timestamp
        }));

        emit PaymentProcessed(_employee, amount, token);
    }

    function batchProcessPayments(address[] calldata _employees) external {
        for (uint256 i = 0; i < _employees.length; i++) {
            if (block.timestamp >= employees[_employees[i]].lastPaymentTime + PAYMENT_PERIOD) {
                this.processPayment(_employees[i]);
            }
        }
    }

    function getEmployee(address _wallet) external view returns (Employee memory) {
        return employees[_wallet];
    }

    function getEmployeeCount() external view returns (uint256) {
        return employeeList.length;
    }

    function getPaymentHistory() external view returns (Payment[] memory) {
        return paymentHistory;
    }

    function depositFunds() external payable onlyOwner {}

    function depositTokens(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    receive() external payable {}
}
