const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

async function main() {
  const networkName = process.env.HARDHAT_NETWORK || "baseSepolia";
  console.log(`Verifying contracts on ${networkName}...`);

  const deploymentsPath = path.join(__dirname, "..", "deployments.json");
  const deployments = JSON.parse(fs.readFileSync(deploymentsPath, "utf8"));
  const contracts = deployments[networkName].contracts;

  const verifyCommands = [
    {
      name: "Payroll Implementation",
      command: `npx hardhat verify --network ${networkName} ${contracts.PayrollImplementation}`
    },
    {
      name: "PayrollFactory Implementation", 
      command: `npx hardhat verify --network ${networkName} ${contracts.PayrollFactoryImplementation}`
    },
    {
      name: "EmployeeRegistry Implementation",
      command: `npx hardhat verify --network ${networkName} ${contracts.EmployeeRegistryImplementation}`
    }
  ];

  for (const { name, command } of verifyCommands) {
    console.log(`\nVerifying ${name}...`);
    try {
      const output = execSync(command, { encoding: "utf8", stdio: "pipe" });
      console.log(output);
      console.log(`✅ ${name} verified`);
    } catch (error) {
      if (error.stdout && error.stdout.includes("Already Verified")) {
        console.log(`✅ ${name} already verified`);
      } else {
        console.log(`❌ ${name} failed:`, error.message);
      }
    }
  }

  console.log("\n=== Verification Complete ===");
  console.log("Note: Proxy contracts inherit verification from implementation");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
