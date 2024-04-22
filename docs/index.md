# Solidity API

## NotImplemented

```solidity
error NotImplemented()
```

## InvalidIdCommitmentIndex

```solidity
error InvalidIdCommitmentIndex(uint256 idCommitment, uint256 index)
```

## MembershipStillActive

```solidity
error MembershipStillActive(uint256 idCommitment)
```

## WakuRln

### contractIndex

```solidity
uint16 contractIndex
```

### MEMBERSHIP_TTL

```solidity
uint40 MEMBERSHIP_TTL
```

The default TTL period in seconds for a membership

### membershipExpiry

```solidity
mapping(uint256 => uint40) membershipExpiry
```

The expiry timestamp of a membership
maps from idCommitment to a timestamp

### constructor

```solidity
constructor(address _poseidonHasher, uint16 _contractIndex, uint40 _ttl) public
```

### \_setCommitment

```solidity
function _setCommitment(uint256 idCommitment, uint256 index) internal
```

### \_register

```solidity
function _register(uint256 idCommitment) internal
```

Registers a member

#### Parameters

| Name         | Type    | Description                    |
| ------------ | ------- | ------------------------------ |
| idCommitment | uint256 | The idCommitment of the member |

### register

```solidity
function register(uint256[] idCommitments) external
```

### registerAtIndex

```solidity
function registerAtIndex(uint256 idCommitment, uint256 index) external
```

Register a member at specific index

#### Parameters

| Name         | Type    | Description                               |
| ------------ | ------- | ----------------------------------------- |
| idCommitment | uint256 | The idCommitment of the member            |
| index        | uint256 | The index in which to register the member |

### renew

```solidity
function renew(uint256 idCommitment) external
```

Renew membership credentials

### register

```solidity
function register(uint256 idCommitment) external payable
```

Allows a user to register as a member

#### Parameters

| Name         | Type    | Description                    |
| ------------ | ------- | ------------------------------ |
| idCommitment | uint256 | The idCommitment of the member |

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
function _validateRegistration(uint256 idCommitment) internal view
```

_Inheriting contracts MUST override this function_

### \_validateIndexExpiration

```solidity
function _validateIndexExpiration(uint256 idCommitment, uint256 index) internal view
```

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

### poseidonHasher

```solidity
contract IPoseidonHasher poseidonHasher
```

### membershipTTL

```solidity
uint40 membershipTTL
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
function initialize(address _poseidonHasher, uint40 _membershipTTL) external
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
function newStorage() external
```

### register

```solidity
function register(uint256[] commitments) external
```

### register

```solidity
function register(uint16 storageIndex, uint256[] commitments) external
```

### register

```solidity
function register(uint16 storageIndex, uint256 commitment) external
```

### registerAtIndex

```solidity
function registerAtIndex(uint16 storageIndex, uint256 commitment, uint256 index) external
```

### forceProgress

```solidity
function forceProgress() external
```
