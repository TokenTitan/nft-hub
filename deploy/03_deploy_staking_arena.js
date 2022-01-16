const { TAZOS_ADDRESS } = require('../config.json');

module.exports = async ({ getNamedAccounts, ethers, upgrades }) => {
  const { deployProxy } = upgrades;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying Staking Arena from account", deployer);

  const StakingArena = await ethers.getContractFactory("StakingArena");
  const stakingArena = await deployProxy(StakingArena, [TAZOS_ADDRESS], { from: deployer });

  await stakingArena.deployed();
  console.log("Staging Arena deployed to:", stakingArena.address);
};
module.exports.tags = ["StakingArena"];
