const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Payroll E2E", function () {
  this.timeout(60000);

  it("Complete payroll workflow", async function () {
    const [owner, employee] = await ethers.getSigners();
    
    // Deploy contracts
    const Payroll = await ethers.getContractFactory("Payroll");
    const payroll = await Payroll.deploy();
    await payroll.waitForDeployment();
    
    // Add employee
    await payroll.addEmployee(
      employee.address,
      ethers.parseEther("1.0"),
      ethers.ZeroAddress
    );
    
    // Fund contract
    await owner.sendTransaction({
      to: await payroll.getAddress(),
      value: ethers.parseEther("2.0")
    });
    
    // Fast forward time
    await ethers.provider.send("evm_increaseTime", [31 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine");
    
    // Process payment
    await payroll.processPayment(employee.address);
    
    const emp = await payroll.getEmployee(employee.address);
    expect(emp.lastPaymentTime).to.be.gt(0);
  });
});
