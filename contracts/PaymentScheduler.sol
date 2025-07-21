// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PaymentScheduler is Initializable, OwnableUpgradeable {
    enum Frequency { WEEKLY, BIWEEKLY, MONTHLY }
    
    struct Schedule {
        address payrollContract;
        Frequency frequency;
        uint256 nextPaymentTime;
        bool isActive;
    }
    
    mapping(uint256 => Schedule) public schedules;
    uint256 public scheduleCount;
    
    event ScheduleCreated(uint256 indexed scheduleId, address payroll, Frequency frequency);
    event PaymentExecuted(uint256 indexed scheduleId, uint256 timestamp);
    
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }
    
    function createSchedule(
        address _payroll,
        Frequency _frequency
    ) external onlyOwner returns (uint256) {
        uint256 scheduleId = scheduleCount++;
        
        schedules[scheduleId] = Schedule({
            payrollContract: _payroll,
            frequency: _frequency,
            nextPaymentTime: block.timestamp + getFrequencyDuration(_frequency),
            isActive: true
        });
        
        emit ScheduleCreated(scheduleId, _payroll, _frequency);
        return scheduleId;
    }
    
    function getFrequencyDuration(Frequency _freq) internal pure returns (uint256) {
        if (_freq == Frequency.WEEKLY) return 7 days;
        if (_freq == Frequency.BIWEEKLY) return 14 days;
        return 30 days;
    }
}
