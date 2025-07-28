const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("EmployeeRegistry", function () {
  let registry, owner, employee;

  beforeEach(async function () {
    [owner, employee] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("EmployeeRegistry");
    registry = await upgrades.deployProxy(Registry, [owner.address]);
  });

  it("Should register employee", async function () {
    await registry.registerEmployee(
      employee.address,
      "John Doe",
      "john@example.com",
      "Developer"
    );
    expect(await registry.isRegistered(employee.address)).to.be.true;
  });
});
