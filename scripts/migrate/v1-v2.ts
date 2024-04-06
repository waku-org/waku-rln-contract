import { BigNumber } from "ethers";
import hre from "hardhat";
import { Provider } from "@ethersproject/providers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";

async function getRlnV1Registry(provider: Provider) {
  const rlnV1Abi = [
    "function storages(uint16 index) public view returns (address)",
  ];

  const rlnV1Address = process.env.WAKU_RLNV1_REGISTRY_ADDRESS;
  if (!rlnV1Address) {
    throw new Error("WAKU_RLNV1_REGISTRY_ADDRESS env variable is not set");
  }
  const rlnV1Registry = new hre.ethers.Contract(
    rlnV1Address,
    rlnV1Abi,
    provider
  );
  return rlnV1Registry;
}

async function getRlnV1Storage(rlnV1Registry: Contract) {
  const storageIndex = process.env.WAKU_RLNV1_STORAGE_INDEX;
  if (!storageIndex) {
    throw new Error("WAKU_RLNV1_STORAGE_INDEX env variable is not set");
  }
  const storageAddress = await rlnV1Registry.storages(storageIndex);
  const rlnV1StorageAbi = [
    "event MemberRegistered(uint256 idCommitment, uint256 index)",
    "function deployedBlockNumber() public view returns (uint32)",
  ];
  const rlnV1Storage = new hre.ethers.Contract(
    storageAddress,
    rlnV1StorageAbi,
    rlnV1Registry.provider
  );
  return rlnV1Storage;
}

async function getRlnV2Registry(signer: SignerWithAddress) {
  const rlnV2Abi = [
    "function register(uint256[] calldata commitments, uint256[] calldata limits) public",
    "function usingStorageIndex() public view returns (uint16)",
    "function storages(uint16 index) public view returns (address)",
  ];
  const rlnV2Address = process.env.WAKU_RLNV2_REGISTRY_ADDRESS;

  if (!rlnV2Address) {
    throw new Error("WAKU_RLNV2_REGISTRY_ADDRESS env variable is not set");
  }
  const rlnV2Registry = new hre.ethers.Contract(rlnV2Address, rlnV2Abi, signer);
  return rlnV2Registry;
}

async function getRlnV2Storage(rlnV2Registry: Contract) {
  const storageIndex = await rlnV2Registry.usingStorageIndex();
  const storageAddress = await rlnV2Registry.storages(storageIndex);
  const rlnV2StorageAbi = [
    "event MemberRegistered(uint256 idCommitment, uint256 index)",
    "function deployedBlockNumber() public view returns (uint32)",
  ];
  const rlnV2Storage = new hre.ethers.Contract(
    storageAddress,
    rlnV2StorageAbi,
    rlnV2Registry.provider
  );
  return rlnV2Storage;
}

async function getRlnV1Commitments(rlnV1Storage: Contract) {
  // iteratively loop from deployedBlockNumber to current block
  // collect commitments from MemberRegistered events
  const deployedBlockNumber = await rlnV1Storage.deployedBlockNumber();
  const currentBlockNumber = await rlnV1Storage.provider.getBlockNumber();
  if (!currentBlockNumber) {
    throw new Error("Could not get current block number");
  }

  console.log(
    `Fetching commitments from block ${deployedBlockNumber} to ${currentBlockNumber}`
  );

  // chunk in batches of 10_000
  const batchSize = 10_000;
  // fetch commitments by listening to events on rln-v1
  const commitments: BigNumber[] = [];
  for (let i = deployedBlockNumber; i < currentBlockNumber; i += batchSize) {
    const normalizedBatch = Math.min(currentBlockNumber, i + batchSize);
    console.log(`Fetching commitments from block ${i} to ${normalizedBatch}`);
    const events = await rlnV1Storage.queryFilter(
      "MemberRegistered",
      i,
      normalizedBatch
    );
    for (const event of events) {
      commitments.push(event.args?.idCommitment);
    }
  }

  return commitments;
}

async function registerRlnV2Commitments(
  rlnV2Registry: Contract,
  commitments: BigNumber[]
) {
  // register commitments on rln-v2, with a default limit of 1, in batches of 20
  const limit = 1;
  const batch = 10;
  const total = commitments.length;
  for (let i = 0; i < total; i += batch) {
    const normalizedBatch = Math.min(total, i + batch);
    const commitmentsBatch = commitments.slice(i, normalizedBatch);
    const limits = Array(commitmentsBatch.length).fill(limit);
    console.log(
      `Registering commitments ${i} to ${normalizedBatch} of ${total}`
    );
    const tx = await rlnV2Registry.register(commitmentsBatch, limits);
    await tx.wait();
  }
}

// this script is used to migrate from rln-v1 to rln-v2
// rln-v1 commitments are poseidon([identitySecret]),
// rln-v2 commitments are poseidon([rlnV1Commitment, userMessageLimit])
// we set a default userMessageLimit to 1 for all migrating users,
// to preserve the same message rate as in rln-v1
async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const rlnV1Registry = await getRlnV1Registry(deployer.provider!);
  const rlnV2Registry = await getRlnV2Registry(deployer);
  const rlnV1Storage = await getRlnV1Storage(rlnV1Registry);
  const rlnV2Storage = await getRlnV2Storage(rlnV2Registry);

  console.log(
    `Migrating from ${rlnV1Registry.address} registry to ${rlnV2Registry.address} registry`
  );
  console.log(
    `Migrating from ${rlnV1Storage.address} storage to ${rlnV2Storage.address} storage`
  );

  const commitments = await getRlnV1Commitments(rlnV1Storage);

  // register commitments on rln-v2, with a default limit of 1, in batches of 20
  await registerRlnV2Commitments(rlnV2Registry, commitments);
  console.log(`Migrated ${commitments.length} commitments`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
