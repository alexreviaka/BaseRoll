const { ethers, network } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const contractName = process.env.CONTRACT || "EmployeeRegistry";
  console.log(`Upgrading ${contractName} on`, network.name);
  
  const deploymentsPath = path.join(__dirname, "..", "deployments.json");
  if (!fs.existsSync(deploymentsPath)) {
    throw new Error("deployments.json not found. Deploy contracts first.");
  }
  
  const deployments = JSON.parse(fs.readFileSync(deploymentsPath, "utf8"));
  const networkDeployments = deployments[network.name];
  
  if (!networkDeployments) {
    throw new Error(`No deployments found for network: ${network.name}`);
  }

  let proxyAddress, implKey;
  if (contractName === "PayrollFactory") {
    proxyAddress = networkDeployments.contracts.PayrollFactoryProxy;
    implKey = "PayrollFactoryImplementationV2";
  } else {
    proxyAddress = networkDeployments.contracts.EmployeeRegistryProxy;
    implKey = "EmployeeRegistryImplementationV2";
  }
  
  console.log("Proxy address:", proxyAddress);

  const ContractFactory = await ethers.getContractFactory(contractName);
  console.log("Deploying new implementation...");
  const newImpl = await ContractFactory.deploy();
  await newImpl.waitForDeployment();
  const newImplAddress = await newImpl.getAddress();
  console.log("New implementation deployed to:", newImplAddress);

  console.log("\nTo upgrade the proxy, execute:");
  console.log(`upgradeTo("${newImplAddress}")`);
  console.log("\nOr use cast (foundry):");
  console.log(`cast send ${proxyAddress} "upgradeTo(address)" ${newImplAddress} --private-key $PRIVATE_KEY --rpc-url $RPC_URL`);

  networkDeployments.contracts[implKey] = newImplAddress;
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
