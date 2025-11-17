const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("Deploying BaseRoll contracts...");

  // Deploy Payroll implementation
  const Payroll = await ethers.getContractFactory("Payroll");
  console.log("Deploying Payroll implementation...");
  const payrollImpl = await Payroll.deploy();
  await payrollImpl.waitForDeployment();
  
  // Deploy Factory
  const PayrollFactory = await ethers.getContractFactory("PayrollFactory");
  const factory = await PayrollFactory.deploy(await payrollImpl.getAddress());
  await factory.waitForDeployment();
  
  console.log("PayrollFactory deployed to:", await factory.getAddress());
  
  // Deploy Employee Registry
  const EmployeeRegistry = await ethers.getContractFactory("EmployeeRegistry");
  const [deployer] = await ethers.getSigners();
  const registry = await upgrades.deployProxy(EmployeeRegistry, [deployer.address]);
  await registry.waitForDeployment();
  
  console.log("EmployeeRegistry deployed to:", await registry.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
