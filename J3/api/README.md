## Sui & Move Bootcamp <> API Quickstart

#### 1. Publish the smart contracts

- Ensure that you are on testnet and the current address has some gas by running:

```
sui client active-env
sui client gas
```

- Publish the contracts by running:

```
cd move/
sui client publish
```

- Get the `txDigest` of the published transaction, and find the Package ID, and the Heroes Registry ID in an explorer. You will need them for the .env of the API later on.

#### 2. Setup and start the local API instance

- Create a `.env` file in the [api](./api/) directory, following the structure of the [.env.example](./api/.env.example):

  ```
  PORT=3000
  SUI_NETWORK=https://rpc.testnet.sui.io:443
  SUI_NETWORK_NAME=testnet
  PACKAGE_ID=
  HEROES_REGISTRY_ID=
  ADMIN_ADDRESS=
  ADMIN_SECRET_KEY=
  ENOKI_SECRET_KEY=
  ```

- Populate the `ADMIN_ADDRESS` and `ADMIN_SECRET_KEY` of the `.env` based on the address that you used for publishing the contracts in the previous step.
- For the `ENOKI_SECRET_KEY` you need to visit [Enoki Portal](https://portal.enoki.mystenlabs.com/) and create a `Private API Key` on `testnet`, enabling the `Sponsored Transactions` feature. This is required to sponsor the mint transactions, so that the gas coins of the admin address [do not get equivocated](https://docs.sui.io/guides/developer/sui-101/avoid-equivocation).

- Run the following commands to start the API locally:

  ```
  cd api/
  npm i
  npm run dev
  ```