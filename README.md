# Kleros Inheritance Contract

An inheritance contract in Solidity.

## Features

- Owner should be able to withdraw ETH.
- If owner does not withdraw ETH from contract, heir can take control of the contract and designate a new heir after 1 month (30 days).
- It should be possible for the owner to withdraw 0 ETH just to reset the one month counter.

## Improvements to be made

- Editing `heir` after contract is deployed.
- Allowing ERC20 token transfer possible.
- Making the wallet ERC721, etc compatible (`onERC721Received(...)`).
- Flexible timelock other than 1 month which would be editable by the owner.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Coverage

```shell
$ forge coverage
```

### Deploy

#### Locally

```shell
anvil
```

```shell
forge script script/KlerosInheritance.s.sol:KlerosInheritanceScript --fork-url http://localhost:8545 --broadcast
```

## Note

This is done as a take home task, and should not be used in production.