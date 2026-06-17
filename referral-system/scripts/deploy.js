import hre from "hardhat";
const { ethers } = hre;

async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("部署合约的账户:", deployer.address);
  console.log("账户余额:", (await deployer.getBalance()).toString());
  
  const GoldenNodeReferral = await ethers.getContractFactory("GoldenNodeReferral");
  
  const USDT_ADDRESS = "0x55d398326f99059fF775485246999027B3197955";
  const RECEIVE_ADDRESS = "0x51E8eDa782fF21Cc6d526ff59e51667859bCe2E7";
  
  const contract = await GoldenNodeReferral.deploy(USDT_ADDRESS, RECEIVE_ADDRESS);
  
  await contract.deployed();
  
  console.log("合约部署地址:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });