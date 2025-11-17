const hre = require("hardhat");

async function main() {
  const address = process.env.CONTRACT_ADDRESS;
  await hre.run("verify:verify", { address });
  console.log("Verified!");
}

main().catch(console.error);
