const { ethers, network } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("Upgrading contracts on", network.name);
  
  const deploymentsPath = path.join(__dirname, "..", "deployments.json");
  if (!fs.existsSync(deploymentsPath)) {
    throw new Error("deployments.json not found. Deploy contracts first.");
  }
  
  const deployments = JSON.parse(fs.readFileSync(deploymentsPath, "utf8"));
  const networkDeployments = deployments[network.name];
  
  if (!networkDeployments) {
    throw new Error(`No deployments found for network: ${network.name}`);
  }

  const proxyAddress = networkDeployments.contracts.EmployeeRegistryProxy;
  console.log("Proxy address:", proxyAddress);

  const EmployeeRegistryV2 = await ethers.getContractFactory("EmployeeRegistry");
  console.log("Deploying new implementation...");
  const newImpl = await EmployeeRegistryV2.deploy();
  await newImpl.waitForDeployment();
  const newImplAddress = await newImpl.getAddress();
  console.log("New implementation deployed to:", newImplAddress);

  const [deployer] = await ethers.getSigners();
  const proxyAdmin = await ethers.getContractAt("ERC1967Proxy", proxyAddress);
  
  const IMPLEMENTATION_SLOT = "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";
  
  console.log("\nTo upgrade the proxy, execute:");
  console.log(`upgradeTo("${newImplAddress}")`);
  console.log("\nOr use cast (foundry):");
  console.log(`cast send ${proxyAddress} "upgradeTo(address)" ${newImplAddress} --private-key $PRIVATE_KEY --rpc-url $RPC_URL`);

  networkDeployments.contracts.EmployeeRegistryImplementationV2 = newImplAddress;
  networkDeployments.lastUpgrade = new Date().toISOString();
  
  fs.writeFileSync(deploymentsPath, JSON.stringify(deployments, null, 2));
  console.log("\nNew implementation address saved to deployments.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
