const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PaymentScheduler", function () {
  it("Should create schedule", async function () {
    const [owner] = await ethers.getSigners();
    const Scheduler = await ethers.getContractFactory("PaymentScheduler");
    const scheduler = await Scheduler.deploy();
    await scheduler.waitForDeployment();
    
    const tx = await scheduler.createSchedule(owner.address, 2);
    await tx.wait();
    expect(await scheduler.scheduleCount()).to.equal(1);
  });
});
