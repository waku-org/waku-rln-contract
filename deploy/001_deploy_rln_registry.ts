import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction, DeploymentSubmission } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getUnnamedAccounts } = hre;
  const { deploy } = deployments;

  const [deployer] = await getUnnamedAccounts();

  const implRes = await deploy("WakuRlnRegistry_Implementation", {
    contract: "WakuRlnRegistry",
    from: deployer,
    log: true,
  });

  let initializeAbi = ["function initialize()"];
  let iface = new hre.ethers.utils.Interface(initializeAbi);
  const data = iface.encodeFunctionData("initialize");

  await deploy("WakuRlnRegistry_Proxy", {
    contract: "ERC1967Proxy",
    from: deployer,
    log: true,
    args: [implRes.address, data],
  });
};

export default func;
func.tags = ["WakuRlnRegistry"];
func.dependencies = ["PoseidonHasher"];
