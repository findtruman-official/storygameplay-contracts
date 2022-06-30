import { utils } from "ethers";
import { ethers, upgrades } from "hardhat";

async function main() {
  const [account] = await ethers.getSigners();
  console.log(`use account: ${account.address}`);
  const FindTrumanToken = await ethers.getContractFactory("FindTrumanToken");
  const ftt = await upgrades.deployProxy(FindTrumanToken, [], {
    kind: "uups",
  });

  await ftt.deployed();
  console.log(`FTT deployed at: ${ftt.address}`);

  // console.log(`use account: ${account.address}`);
  const FindTrumanAchievement = await ethers.getContractFactory(
    "FindTrumanAchievement"
  );
  const fta = await upgrades.deployProxy(FindTrumanAchievement, [], {
    kind: "uups",
  });

  await fta.deployed();
  console.log(`FTA deployed at: ${fta.address}`);

  const FindTrumanCocreation = await ethers.getContractFactory(
    "FindTrumanCocreation"
  );
  const instance = await upgrades.deployProxy(
    FindTrumanCocreation,
    [fta.address, ftt.address],
    {
      kind: "uups",
    }
  );

  await instance.deployed();
  console.log(`FTC deployed at: ${instance.address}`);

  const MINTER_ROLE = utils.keccak256(utils.toUtf8Bytes("MINTER_ROLE"));

  for (const ins of [fta, ftt]) {
    console.log(
      `[${ins.address}] grant MINTER_ROLE to ${instance.address} ...`
    );
    const tx = await ins.grantRole(MINTER_ROLE, instance.address);
    await tx.wait();
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
