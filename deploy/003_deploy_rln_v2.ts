import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;

  const [deployer] = await getUnnamedAccounts();

  const implRes = await deploy("WakuRlnRegistry_Implementation", {
    contract: "WakuRlnRegistry",
    from: deployer,
    log: true,
    skipIfAlreadyDeployed: false,
  });

  const existingProxy = await deployments.get("WakuRlnRegistry_Proxy");
  existingProxy.abi.push({
    inputs: [
      {
        internalType: "address",
        name: "newImplementation",
        type: "address",
      },
    ],
    name: "upgradeTo",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  });
  existingProxy.abi.push({
    inputs: [],
    name: "initialize",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  });
  const existingProxyContract = new hre.ethers.Contract(
    existingProxy.address,
    existingProxy.abi,
    hre.ethers.provider.getSigner(deployer)
  );

  const upgradeTx = await existingProxyContract.upgradeTo(implRes.address);
  await upgradeTx.wait();
  const implContract = new hre.ethers.Contract(
    implRes.address,
    implRes.abi,
    hre.ethers.provider.getSigner(deployer)
  );
  await implContract.initialize();
};

export default func;
func.tags = ["WakuRlnRegistry_v2"];
func.dependencies = ["WakuRlnRegistry"];
