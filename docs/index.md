# Solidity API

## NotImplemented

```solidity
error NotImplemented()
```

## MalformedCommitmentToMessageLimitMap

```solidity
error MalformedCommitmentToMessageLimitMap()
```

## isValidCommitmentToMessageLimitMap

```solidity
function isValidCommitmentToMessageLimitMap(uint256[] commitments, uint256[] limits) internal pure returns (bool)
```

## WakuRln

### contractIndex

```solidity
uint16 contractIndex
```

### constructor

```solidity
constructor(uint256 _maxMessageLimit, uint16 _contractIndex) public
```

### onlyValidCommitmentToMessageLimitMap

```solidity
modifier onlyValidCommitmentToMessageLimitMap(uint256[] commitments, uint256[] limits)
```

### \_register

```solidity
function _register(uint256 idCommitment, uint256 userMessageLimit) internal
```

Registers a member

#### Parameters

| Name             | Type    | Description                        |
| ---------------- | ------- | ---------------------------------- |
| idCommitment     | uint256 | The idCommitment of the member     |
| userMessageLimit | uint256 | The userMessageLimit of the member |

### register

```solidity
function register(uint256[] commitments, uint256[] limits) external
```

### register

```solidity
function register(uint256 idCommitment, uint256 userMessageLimit) external payable
```

Allows a user to register as a member

#### Parameters

| Name             | Type    | Description                     |
| ---------------- | ------- | ------------------------------- |
| idCommitment     | uint256 | The idCommitment of the member  |
| userMessageLimit | uint256 | The message limit of the member |

### slash

```solidity
function slash(uint256 idCommitment, address payable receiver, uint256[8] proof) external pure
```

_Allows a user to slash a member_

#### Parameters

| Name         | Type            | Description                    |
| ------------ | --------------- | ------------------------------ |
| idCommitment | uint256         | The idCommitment of the member |
| receiver     | address payable |                                |
| proof        | uint256[8]      |                                |

### \_validateRegistration

```solidity
function _validateRegistration(uint256 idCommitment, uint256 userMessageLimit) internal view
```

_Inheriting contracts MUST override this function_

### \_validateSlash

```solidity
function _validateSlash(uint256 idCommitment, address payable receiver, uint256[8] proof) internal pure
```

### withdraw

```solidity
function withdraw() external pure
```

Allows a user to withdraw funds allocated to them upon slashing a member

## StorageAlreadyExists

```solidity
error StorageAlreadyExists(address storageAddress)
```

## NoStorageContractAvailable

```solidity
error NoStorageContractAvailable()
```

## IncompatibleStorage

```solidity
error IncompatibleStorage()
```

## IncompatibleStorageIndex

```solidity
error IncompatibleStorageIndex()
```

## InvalidMaxMessageLimit

```solidity
error InvalidMaxMessageLimit()
```

## WakuRlnRegistry

### nextStorageIndex

```solidity
uint16 nextStorageIndex
```

### storages

```solidity
mapping(uint16 => address) storages
```

### usingStorageIndex

```solidity
uint16 usingStorageIndex
```

### NewStorageContract

```solidity
event NewStorageContract(uint16 index, address storageAddress)
```

### onlyUsableStorage

```solidity
modifier onlyUsableStorage()
```

### initialize

```solidity
function initialize() external
```

### \_authorizeUpgrade

```solidity
function _authorizeUpgrade(address newImplementation) internal
```

\_Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
{upgradeTo} and {upgradeToAndCall}.

Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.

````solidity
function _authorizeUpgrade(address) internal override onlyOwner {}
```_

### _insertIntoStorageMap

```solidity
function _insertIntoStorageMap(address storageAddress) internal
````

### registerStorage

```solidity
function registerStorage(address storageAddress) external
```

### newStorage

```solidity
function newStorage(uint256 maxMessageLimit) external
```

### register

```solidity
function register(uint256[] commitments, uint256[] limits) external
```

### register

```solidity
function register(uint16 storageIndex, uint256[] commitments, uint256[] limits) external
```

### register

```solidity
function register(uint16 storageIndex, uint256 idCommitment, uint256 userMessageLimit) external
```

### forceProgress

```solidity
function forceProgress() external
```
