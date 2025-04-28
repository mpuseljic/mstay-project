require("@nomiclabs/hardhat-ethers");

task("deploy", "Deploys the mStay contract", async (taskArgs, hre) => {
  const mStay = await hre.ethers.getContractFactory("mStay");
  const contract = await mStay.deploy();
  await contract.deployed();
  console.log("mStay deployed to:", contract.address);
});

module.exports = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      chainId: 1337,
    },
  },
  defaultNetwork: "localhost",
};
