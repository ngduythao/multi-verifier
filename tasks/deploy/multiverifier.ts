import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { MultiVerifier, MultiVerifier__factory } from "src/types";

task("deploy:MultiVerifier").setAction(async function (_, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const contractFactory: MultiVerifier__factory = <MultiVerifier__factory>(
    await ethers.getContractFactory("MultiVerifier")
  );
  const contract: MultiVerifier = <MultiVerifier>await contractFactory.connect(signers[0]).deploy();
  await contract.deployed();
  console.log("Contract deployed to: ", contract.address);
});
