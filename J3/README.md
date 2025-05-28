## Sui & Move Bootcamp <> Using Prometheus and Grafana for Monitoring (+ a real-world airdrop scenario as a bonus gift)

For this exercise we will show how we can build a setup for a real-world airdrop scenario, and monitor it efficiently.

## Overview

Let's say that we want to have an airdrop of an NFT Collection of `Hero` NFTs, with the following specs:

- The NFTs should not be pre-minted
- The users do not pay for the gas
- Only an admin address can mint NFTs
- Multiple concurrent requests should be served
- Monitor the system with Prometheus & Grafana

## Architecture Overview

- UI: Sends a POST request to the /mint endpoint of the REST API, including the recipient's address in the HTTP body of the request
- REST API: Builds, signs, sponsors with Enoki, and executes a PTB for minting the NFT for this recipient

### Project Structure

```bash
J3/
├── move/ # The smart contracts for the Hero NFT
│── api/ # The NodeJS-ExpressJS REST API
│── client.sh # A simple bash script that calls the endpoint in a while loop to see the results
├── README.md # Project documentation
```

### Quickstart

- Create a `.env` file in the [api](./api/) directory, following the structure of the [.env.example](./api/.env.example):

  ```
  PORT=3000
  SUI_NETWORK=https://rpc.testnet.sui.io:443
  SUI_NETWORK_NAME=testnet
  PACKAGE_ID=0x51e26da03cb45b1d4c415cc3685027381486ea80403b3a660dca9009fb4f04fb
  HEROES_REGISTRY_ID=0x5aa5258d294d9806b32a24e8595116aa1f9b5b7d161b86191cf7a793db968417
  ADMIN_SECRET_KEY=
  ENOKI_SECRET_KEY=
  ```

- Run the following commands to start the API locally:

  ```
  cd api/
  npm i
  npm run dev
  ```

- Run the [mint.sh](./mint.sh) script to mint a hero and transfer it to the address `0x123`:

  ```
  chmod +x ./bash.sh
  ./bash.sh
  ```
