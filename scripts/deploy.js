const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying BaseRoll contracts...");
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Deploy Payroll implementation
  const Payroll = await ethers.getContractFactory("Payroll");
  console.log("Deploying Payroll implementation...");
  const payrollImpl = await Payroll.deploy();
  await payrollImpl.waitForDeployment();
  const payrollImplAddress = await payrollImpl.getAddress();
  console.log("Payroll implementation deployed to:", payrollImplAddress);
  
  // Deploy Factory
  const PayrollFactory = await ethers.getContractFactory("PayrollFactory");
  console.log("Deploying PayrollFactory...");
  const factory = await PayrollFactory.deploy(payrollImplAddress);
  await factory.waitForDeployment();
  const factoryAddress = await factory.getAddress();
  console.log("PayrollFactory deployed to:", factoryAddress);
  
  // Deploy Employee Registry implementation
  const EmployeeRegistry = await ethers.getContractFactory("EmployeeRegistry");
  console.log("Deploying EmployeeRegistry implementation...");
  const registryImpl = await EmployeeRegistry.deploy();
  await registryImpl.waitForDeployment();
  const registryImplAddress = await registryImpl.getAddress();
  console.log("EmployeeRegistry implementation deployed to:", registryImplAddress);
  
  // Deploy ERC1967Proxy for EmployeeRegistry
  const ERC1967Proxy = await ethers.getContractFactory("ERC1967Proxy");
  const initData = registryImpl.interface.encodeFunctionData("initialize", [deployer.address]);
  console.log("Deploying EmployeeRegistry proxy...");
  const registryProxy = await ERC1967Proxy.deploy(registryImplAddress, initData);
  await registryProxy.waitForDeployment();
  const registryProxyAddress = await registryProxy.getAddress();
  console.log("EmployeeRegistry proxy deployed to:", registryProxyAddress);

  console.log("\n=== Deployment Summary ===");
  console.log("Payroll Implementation:", payrollImplAddress);
  console.log("PayrollFactory:", factoryAddress);
  console.log("EmployeeRegistry Implementation:", registryImplAddress);
  console.log("EmployeeRegistry Proxy:", registryProxyAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
