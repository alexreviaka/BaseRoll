const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PayrollFactory", function () {
  let factory, implementation, owner, company;

  beforeEach(async function () {
    [owner, company] = await ethers.getSigners();
    
    const Payroll = await ethers.getContractFactory("Payroll");
    implementation = await Payroll.deploy();
    await implementation.waitForDeployment();
    
    const PayrollFactory = await ethers.getContractFactory("PayrollFactory");
    factory = await PayrollFactory.deploy(await implementation.getAddress());
    await factory.waitForDeployment();
  });

  it("Should create payroll instance", async function () {
    const tx = await factory.connect(company).createPayroll();
    const receipt = await tx.wait();
    
    const payrolls = await factory.getCompanyPayrolls(company.address);
    expect(payrolls.length).to.equal(1);
  });

  it("Should track multiple payrolls per company", async function () {
    await factory.connect(company).createPayroll();
    await factory.connect(company).createPayroll();
    
    const payrolls = await factory.getCompanyPayrolls(company.address);
    expect(payrolls.length).to.equal(2);
  });
});
