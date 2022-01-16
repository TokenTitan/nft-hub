const { setEnv } = require("../lib/config");

module.exports = async ({ getNamedAccounts, ethers, upgrades }) => {
  const { deployProxy } = upgrades;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying tazos from account", deployer);

  const Tazos = await ethers.getContractFactory("Tazos");
  const tazos = await deployProxy(Tazos, [""], { from: deployer });

  await tazos.deployed();

  await setEnv("TAZOS_ADDRESS", tazos.address);
  console.log("Tazos deployed to:", tazos.address);
};
module.exports.tags = ["Tazos"];
