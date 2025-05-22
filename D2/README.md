## Sui & Move Bootcamp <> Sui TS SDK | Read Queries I

This exercise contains a simple Node project using Typescript, that reads the contents of an NFT on the Sui blockchain.

We are going to be reading the contents of the [Hero NFT](../E1/hero/sources/hero.move) of the upcoming E1 exercise:

```
public struct Hero has key, store {
    id: UID,
    health: u64,
    stamina: u64,
}
```

### Useful Links

- [Sui And Community SDKs](https://docs.sui.io/references/sui-sdks)
- [Sui Typescript SDK](https://sdk.mystenlabs.com/typescript)

### Quickstart

- Create a .env file in the `get-hero/` directory, following the structure of the [.env.example](./get-hero/.env.example):

```
SUI_NETWORK=https://rpc.testnet.sui.io:443
PACKAGE_ID=0x26cc4e8173393efa8411b376c17420dc59e48ee6649a634cfaee98477efe5435
```

- Run the following commands:

```
cd get-hero
npm i
npm run test
```

### Instructions

- Notice that both of the tests in the [getHero.test.ts](./get-hero/src/tests/getHero.test.ts) file are failing:
  - `Hero Exists`: Validates that the Hero object is found on chain by its Object ID
  - `Hero Content`: Validates the content of the Hero object has the expected structure
  - `Hero Has Attached Swords`: Validates that the Hero object has a Sword attached to it

#### 1. Fetch the object data from the chain

- Modify the function [getHero.ts](./get-hero/src/helpers/getHero.ts), so that the object is fetched
- You should use the [suiClient.getObject](https://github.com/MystenLabs/ts-sdks/blob/main/packages/typescript/src/client/client.ts#L353-L365) method
- The `Hero Exists` test should pass

#### 2. Parse its "Hero" fields

- Modify the function [getHero.ts](./get-hero/src/helpers/getHero.ts), so that it fetches the fields of the NFT along with the object ID and the type
- Modify the function [parseHeroContent.ts](./get-hero/src/helpers/parseHeroContent.ts), so that the nested objects get mapped to the defined TS interface
- The `Hero Content` test should pass

#### 3. Fetch its "Sword" Dynamic Object Fields

- Modify the function [getHeroSwordIds.ts](./get-hero/src/helpers/getHeroSwordIds.ts), so that the dynamic object fields of this NFT are fetched
- Filter them by the Sword type `${ENV.PACKAGE_ID}::blacksmith::Sword`
- The `Hero Has Attached Swords` test should pass
