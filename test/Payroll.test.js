const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("Payroll Contract", function () {
  let payroll, owner, employee;

  beforeEach(async function () {
    [owner, employee] = await ethers.getSigners();
    const Payroll = await ethers.getContractFactory("Payroll");
    payroll = await upgrades.deployProxy(Payroll, [owner.address]);
  });

  it("Should add employee", async function () {
    await payroll.addEmployee(
      employee.address,
      ethers.parseEther("1.0"),
      ethers.ZeroAddress
    );
    const emp = await payroll.getEmployee(employee.address);
    expect(emp.wallet).to.equal(employee.address);
  });

  it("Should process payment", async function () {
    await payroll.addEmployee(
      employee.address,
      ethers.parseEther("1.0"),
      ethers.ZeroAddress
    );
    
    await owner.sendTransaction({
      to: await payroll.getAddress(),
      value: ethers.parseEther("2.0")
    });

    await ethers.provider.send("evm_increaseTime", [31 * 24 * 60 * 60]);
    await payroll.processPayment(employee.address);
    
    const emp = await payroll.getEmployee(employee.address);
    expect(emp.lastPaymentTime).to.be.gt(0);
  });
});
