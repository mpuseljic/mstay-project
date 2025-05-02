// scripts/deploy.js
async function main() {
  const mStay = await ethers.getContractFactory("mStay"); // Učita smart contract
  const contract = await mStay.deploy(); // Deploya ga na mrežu
  await contract.deployed(); // Čeka da se deploy završi
  console.log("mStay deployed to:", contract.address); // Ispiše adresu
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
