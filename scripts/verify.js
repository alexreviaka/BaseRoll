const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const networkName = hre.network.name;
  console.log(`Verifying contracts on ${networkName}...`);

  const deploymentsPath = path.join(__dirname, "..", "deployments.json");
  if (!fs.existsSync(deploymentsPath)) {
    throw new Error("deployments.json not found");
  }

  const deployments = JSON.parse(fs.readFileSync(deploymentsPath, "utf8"));
  const networkDeployments = deployments[networkName];

  if (!networkDeployments) {
    throw new Error(`No deployments found for network: ${networkName}`);
  }

  const contracts = networkDeployments.contracts;
  const deployer = networkDeployments.deployer;

  console.log("\n=== Verifying Implementations ===");

  console.log("\nUsing Sourcify for verification...");

  try {
    console.log("\n1. Verifying Payroll Implementation...");
    await hre.run("verify:sourcify", {
      address: contracts.PayrollImplementation
    });
    console.log("✅ Payroll Implementation verified");
  } catch (error) {
    console.log("⚠️  Sourcify:", error.message);
    try {
      await hre.run("verify:verify", {
        address: contracts.PayrollImplementation,
        constructorArguments: []
      });
      console.log("✅ Verified via Etherscan");
    } catch (e) {
      console.log("❌ Both methods failed");
    }
  }

  try {
    console.log("\n2. Verifying PayrollFactory Implementation...");
    await hre.run("verify:sourcify", {
      address: contracts.PayrollFactoryImplementation
    });
    console.log("✅ PayrollFactory Implementation verified");
  } catch (error) {
    console.log("⚠️  Sourcify:", error.message);
    try {
      await hre.run("verify:verify", {
        address: contracts.PayrollFactoryImplementation,
        constructorArguments: []
      });
      console.log("✅ Verified via Etherscan");
    } catch (e) {
      console.log("❌ Both methods failed");
    }
  }

  try {
    console.log("\n3. Verifying EmployeeRegistry Implementation...");
    await hre.run("verify:sourcify", {
      address: contracts.EmployeeRegistryImplementation
    });
    console.log("✅ EmployeeRegistry Implementation verified");
  } catch (error) {
    console.log("⚠️  Sourcify:", error.message);
    try {
      await hre.run("verify:verify", {
        address: contracts.EmployeeRegistryImplementation,
        constructorArguments: []
      });
      console.log("✅ Verified via Etherscan");
    } catch (e) {
      console.log("❌ Both methods failed");
    }
  }

  console.log("\n=== Verifying Proxies ===");
  
  try {
    console.log("\n4. Verifying PayrollFactory Proxy...");
    await hre.run("verify:sourcify", {
      address: contracts.PayrollFactoryProxy
    });
    console.log("✅ PayrollFactory Proxy verified");
  } catch (error) {
    console.log("⚠️  Sourcify:", error.message);
    try {
      const factoryInitData = new hre.ethers.Interface([
        "function initialize(address _implementation, address _owner)"
      ]).encodeFunctionData("initialize", [contracts.PayrollImplementation, deployer]);

      await hre.run("verify:verify", {
        address: contracts.PayrollFactoryProxy,
        constructorArguments: [contracts.PayrollFactoryImplementation, factoryInitData],
        contract: "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy"
      });
      console.log("✅ Verified via Etherscan");
    } catch (e) {
      console.log("❌ Both methods failed");
    }
  }

  try {
    console.log("\n5. Verifying EmployeeRegistry Proxy...");
    await hre.run("verify:sourcify", {
      address: contracts.EmployeeRegistryProxy
    });
    console.log("✅ EmployeeRegistry Proxy verified");
  } catch (error) {
    console.log("⚠️  Sourcify:", error.message);
    try {
      const registryInitData = new hre.ethers.Interface([
        "function initialize(address _owner)"
      ]).encodeFunctionData("initialize", [deployer]);

      await hre.run("verify:verify", {
        address: contracts.EmployeeRegistryProxy,
        constructorArguments: [contracts.EmployeeRegistryImplementation, registryInitData],
        contract: "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy"
      });
      console.log("✅ Verified via Etherscan");
    } catch (e) {
      console.log("❌ Both methods failed");
    }
  }

  console.log("\n=== Verification Complete ===");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
