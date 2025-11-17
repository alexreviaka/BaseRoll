const { ethers, network } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("Deploying BaseRoll contracts...");
  console.log("Network:", network.name);
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const Payroll = await ethers.getContractFactory("Payroll");
  console.log("Deploying Payroll implementation...");
  const payrollImpl = await Payroll.deploy();
  await payrollImpl.waitForDeployment();
  const payrollImplAddress = await payrollImpl.getAddress();
  console.log("Payroll implementation deployed to:", payrollImplAddress);
  
  const PayrollFactory = await ethers.getContractFactory("PayrollFactory");
  console.log("Deploying PayrollFactory implementation...");
  const factoryImpl = await PayrollFactory.deploy();
  await factoryImpl.waitForDeployment();
  const factoryImplAddress = await factoryImpl.getAddress();
  console.log("PayrollFactory implementation deployed to:", factoryImplAddress);

  const ERC1967Proxy = await ethers.getContractFactory("ERC1967Proxy");
  
  const factoryInitData = factoryImpl.interface.encodeFunctionData("initialize", [payrollImplAddress, deployer.address]);
  console.log("Deploying PayrollFactory proxy...");
  const factoryProxy = await ERC1967Proxy.deploy(factoryImplAddress, factoryInitData);
  await factoryProxy.waitForDeployment();
  const factoryProxyAddress = await factoryProxy.getAddress();
  console.log("PayrollFactory proxy deployed to:", factoryProxyAddress);
  
  const EmployeeRegistry = await ethers.getContractFactory("EmployeeRegistry");
  console.log("Deploying EmployeeRegistry implementation...");
  const registryImpl = await EmployeeRegistry.deploy();
  await registryImpl.waitForDeployment();
  const registryImplAddress = await registryImpl.getAddress();
  console.log("EmployeeRegistry implementation deployed to:", registryImplAddress);
  
  const registryInitData = registryImpl.interface.encodeFunctionData("initialize", [deployer.address]);
  console.log("Deploying EmployeeRegistry proxy...");
  const registryProxy = await ERC1967Proxy.deploy(registryImplAddress, registryInitData);
  await registryProxy.waitForDeployment();
  const registryProxyAddress = await registryProxy.getAddress();
  console.log("EmployeeRegistry proxy deployed to:", registryProxyAddress);

  console.log("\n=== Deployment Summary ===");
  console.log("Payroll Implementation:", payrollImplAddress);
  console.log("PayrollFactory Implementation:", factoryImplAddress);
  console.log("PayrollFactory Proxy:", factoryProxyAddress);
  console.log("EmployeeRegistry Implementation:", registryImplAddress);
  console.log("EmployeeRegistry Proxy:", registryProxyAddress);
  const deploymentsPath = path.join(__dirname, "..", "deployments.json");
  let deployments = {};
  if (fs.existsSync(deploymentsPath)) {
    deployments = JSON.parse(fs.readFileSync(deploymentsPath, "utf8"));
  }

  deployments[network.name] = {
    timestamp: new Date().toISOString(),
    deployer: deployer.address,
    contracts: {
      PayrollImplementation: payrollImplAddress,
      PayrollFactoryImplementation: factoryImplAddress,
      PayrollFactoryProxy: factoryProxyAddress,
      EmployeeRegistryImplementation: registryImplAddress,
      EmployeeRegistryProxy: registryProxyAddress
    }
  };

  fs.writeFileSync(deploymentsPath, JSON.stringify(deployments, null, 2));
  console.log("\nDeployment addresses saved to deployments.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
