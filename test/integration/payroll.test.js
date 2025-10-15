const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Payroll Integration", function () {
  it("Should handle full payroll workflow", async function () {
    const [owner, employee] = await ethers.getSigners();
    
    const Payroll = await ethers.getContractFactory("Payroll");
    const payroll = await Payroll.deploy();
    
    await payroll.addEmployee(
      employee.address,
      ethers.parseEther("1.0"),
      ethers.ZeroAddress
    );
    
    const emp = await payroll.getEmployee(employee.address);
    expect(emp.wallet).to.equal(employee.address);
  });
});
