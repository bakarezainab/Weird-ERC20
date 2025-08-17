## Weird ERC20 Explanation

### For Weird Token A22

#### A22. constructor-mistyping
**Description**
When declaring function constructors, one should write code like constructor(). However, some mistyped this declaration, using function constructor(), thus the Solidity compiler would view it as an average public function that anyone could access, not a constructor called just once when deploying.

**Problematic Implementation**
```solidity
contract A{
    function constructor() public{

    }
}
```
**Recommended Implementation**
#### Change to constructor only without adding function
```solidity
contract A{
    constructor() public{

    }
}
```



**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

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

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
