## Snowman Merkle Airdrop

Snow in the middle of the year? You got it!!!

In anticipation of the upcoming snow season, help secure the **Snowman Merkle Airdrop contract**.

![snowman image](snowman.png)

[//]: # (contest-details-open)

### About

- `Snow.sol`:

    The `Snow` contract is an `ERC20` token that automatically makes one eligible to claim a `Snowman NFT`.

    The `Snow` token is staked in the `SnowmanAirdrop` contract, and the staker receives `Snowman` NFTs in the value of how many `Snow` tokens they own.

    The `Snow` token can either be earned for free onece a week, or bought at anytime, up until during the `::FARMING_DURATION` is over.

    The `Snow` token can be bought with either `WETH` or native `ETH`.

- `Snowman.sol`:

    The `Snowman` contract is an `ERC721` contract that utilizes `Base64` encoding to achieve total on-chain storage.

    Stakers of the Snow token receive this NFT.

- `SnowmanAirdrop.sol`:

    The `SnowmanAirdrop` contract utilizes `Merkle` trees implementation for a more efficient airdrop system.

    Recipients can either claim a `Snowman` NFT themselves, or have someone claim on their behalf using the recipient's `v`, `r`, `s` signatures.

    Recipients stake their `Snow` tokens and receive `Snowman` NFTS equal to their `Snow` balance in return

### Spanish About

- `Snow.sol`:

    El contrato `Snow` es un token `ERC20` que automáticamente hace que uno sea elegible para reclamar un `Snowman NFT`.

    El token `Snow` se deposita en el contrato `SnowmanAirdrop`, y el depositante recibe `Snowman` NFTs en función de la cantidad de tokens `Snow` que posee.

    El token `Snow` puede ganarse de forma gratuita una vez a la semana, o comprarse en cualquier momento, hasta que termine el `::FARMING_DURATION`.

    El token `Snow` puede comprarse con `WETH` o `ETH` nativo.

- `Snowman.sol`:

    El contrato `Snowman` es un contrato `ERC721` que utiliza codificación `Base64` para lograr almacenamiento completamente en cadena.

    Los depositantes del token `Snow` reciben este NFT.

- `SnowmanAirdrop.sol`:

    El contrato `SnowmanAirdrop` utiliza una implementación de árboles `Merkle` para un sistema de airdrop más eficiente.

    Los destinatarios pueden reclamar un `Snowman` NFT ellos mismos, o hacer que alguien lo reclame en su nombre utilizando las firmas `v`, `r`, `s` del destinatario.

    Los destinatarios depositan sus tokens `Snow` y reciben `Snowman` NFTs equivalentes a su saldo de `Snow` como retorno.

### Resources:

- Learn about Merkle trees [`here`](https://updraft.cyfrin.io/courses/advanced-foundry/merkle-airdrop/introduction) and [`here`](https://www.youtube.com/watch?v=s7C2KjZ9n2U)
- Learn about ECDSA signtaures [`here`](https://www.youtube.com/watch?v=e3ugVpBBlhc)
- Learn about Snowmen [`here`](https://en.wikipedia.org/wiki/Snowman)

Goodluck ⛄

[//]: # (contest-details-close)

[//]: # (getting-started-open)

### Set-up:

```bash
    git clone https://github.com/CodeHawks-Contests/2025-06-snowman-merkle-airdrop.git 
    cd 2025-06-snowman-merkle-airdrop
    forge install
    forge build
    forge test
```

The `Helper` script is used to deploy the `GenerateInput` and `SnowMerkle` scripts, and also set up the `TestSnowmanAirdrop` test suite. Refactor it for your tests as you see fit to get the necessary `input` and `output` `JSON` files.

[//]: # (getting-started-close)

[//]: # (scope-open)

### Scope:

```
src/
├── Snow.sol
├── Snowman.sol
└── SnowmanAirdrop.sol

script/
├── GenerateInput.s.sol
├── Helper.s.sol
├── SnowMerkle.s.sol
└── flakes/
    ├── input.json
    └── output.json
```

### Compatibility:

- Chain: Ethereum
- Token: Native `ETH` and `WETH`

[//]: # (scope-close)

[//]: # (known-issues-open)

### Known Issues

None!

[//]: # (known-issues-close)

