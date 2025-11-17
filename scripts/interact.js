const { ethers, network } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("=== BaseRoll Contract Interaction ===");
  console.log("Network:", network.name);
  
  const deploymentsPath = path.join(__dirname, "..", "deployments.json");
  if (!fs.existsSync(deploymentsPath)) {
    throw new Error("deployments.json not found. Deploy contracts first.");
  }
  
  const deployments = JSON.parse(fs.readFileSync(deploymentsPath, "utf8"));
  const networkDeployments = deployments[network.name];
  
  if (!networkDeployments) {
    throw new Error(`No deployments found for network: ${network.name}`);
  }

  const [deployer, user1, user2] = await ethers.getSigners();
  console.log("Using account:", deployer.address);
  console.log("Balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  const factoryAddress = networkDeployments.contracts.PayrollFactory;
  const registryProxyAddress = networkDeployments.contracts.EmployeeRegistryProxy;

  console.log("Factory:", factoryAddress);
  console.log("Registry:", registryProxyAddress);

  const factory = await ethers.getContractAt("PayrollFactory", factoryAddress);
  const registry = await ethers.getContractAt("EmployeeRegistry", registryProxyAddress);

  console.log("\n=== Available Actions ===");
  console.log("1. Register Employee");
  console.log("2. Get Employee Info");
  console.log("3. Create Payroll Contract");
  console.log("4. Get All Employees");
  console.log("5. Check Registry Owner");
  
  const action = process.env.ACTION || "5";
  
  switch(action) {
    case "1":
      console.log("\n--- Registering Employee ---");
      const employeeAddress = user1?.address || deployer.address;
      const tx = await registry.registerEmployee(
        employeeAddress,
        "John Doe",
        "john@example.com",
        "Developer"
      );
      await tx.wait();
      console.log("Employee registered:", employeeAddress);
      console.log("Transaction:", tx.hash);
      break;

    case "2":
      console.log("\n--- Getting Employee Info ---");
      const checkAddress = user1?.address || deployer.address;
      try {
        const info = await registry.getEmployeeInfo(checkAddress);
        console.log("Employee Info:");
        console.log("  Name:", info.name);
        console.log("  Email:", info.email);
        console.log("  Position:", info.position);
        console.log("  Joined At:", new Date(Number(info.joinedAt) * 1000).toISOString());
        console.log("  Active:", info.isActive);
      } catch (e) {
        console.log("Employee not found or error:", e.message);
      }
      break;

    case "3":
      console.log("\n--- Creating Payroll Contract ---");
      const createTx = await factory.createPayroll();
      const receipt = await createTx.wait();
      
      const event = receipt.logs.find(log => {
        try {
          const parsed = factory.interface.parseLog(log);
          return parsed.name === "PayrollCreated";
        } catch {
          return false;
        }
      });
      
      if (event) {
        const parsed = factory.interface.parseLog(event);
        console.log("Payroll contract created at:", parsed.args.payroll);
      }
      console.log("Transaction:", createTx.hash);
      break;

    case "4":
      console.log("\n--- All Employees ---");
      const employees = await registry.getAllEmployees();
      console.log("Total employees:", employees.length);
      for (const emp of employees) {
        console.log("  -", emp);
      }
      break;

    case "5":
      console.log("\n--- Registry Owner ---");
      const owner = await registry.owner();
      console.log("Owner:", owner);
      console.log("Is deployer owner?", owner.toLowerCase() === deployer.address.toLowerCase());
      break;

    default:
      console.log("Invalid action");
  }

  console.log("\n=== Done ===");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
