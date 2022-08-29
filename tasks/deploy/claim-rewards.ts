import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { ClaimRewards, ClaimRewards__factory } from "src/types";

task("contract:claims").setAction(async function (_, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const contractFactory: ClaimRewards__factory = <ClaimRewards__factory>await ethers.getContractFactory("ClaimRewards");
  const contract: ClaimRewards = <ClaimRewards>await contractFactory.connect(signers[0]).deploy();
  await contract.deployed();
  console.log("Contract deployed to: ", contract.address);
});
