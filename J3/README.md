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
  PACKAGE_ID=0x51e26da03cb45b1d4c415cc3685027381486ea80403b3a660dca9009fb4f04fb
  HEROES_REGISTRY_ID=0x5aa5258d294d9806b32a24e8595116aa1f9b5b7d161b86191cf7a793db968417
  ADMIN_ADDRESS=
  ADMIN_SECRET_KEY=
  ENOKI_SECRET_KEY=
  ```

- Populate the `ADMIN_ADDRESS` and `ADMIN_SECRET_KEY` of the `.env` based on the address that you used for publishing the contracts in the previous step.
- For the `ENOKI_SECRET_KEY` you need to visit [Enoki Portal](https://portal.enoki.mystenlabs.com/) and create a `Private API Key` on `testnet`, enabling the `Sponsored Transactions` feature

- Run the following commands to start the API locally:

  ```
  cd api/
  npm i
  npm run dev
  ```

#### 3. Setup the Prometheus Metrics Server

- Change your current directory into the root [J3](../J3/) of the current exercies
- Run `docker-compose up`
- If you visit `http://localhost:9090/` in a web browser, you will see a simple dashboard provided by Prometheus

#### 4. Simulate a scenario and observe the metrics

- Run the [mint.sh](./mint.sh) script to simulate 50 almost concurrent users requesting their NFT:

  ```
  chmod +x ./bash.sh
  ./bash.sh
  ```

- These are some interesting metrics you can calculate in http://localhost:9090/:

  | Query                                                                                                                      | Description                                                       |
  | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
  | total_requests                                                                                                             | Total number of requests received by the API                      |
  | successful_requests                                                                                                        | Total number of successful NFT mints                              |
  | build_errors                                                                                                               | Number of times transaction building failed                       |
  | create_sponsored_errors                                                                                                    | Number of times Enoki sponsorship API failed                      |
  | sign_errors                                                                                                                | Number of signing failures for sponsored transactions             |
  | execute_sponsored_errors                                                                                                   | Number of failures during sponsored transaction execution         |
  | rate(total_requests[1m])                                                                                                   | Rate of incoming requests per second (rolling 1-minute window)    |
  | rate(successful_requests[1m])                                                                                              | Rate of successful mints per second (rolling 1-minute window)     |
  | rate(build_errors[1m]) or rate(create_sponsored_errors[1m]) or rate(sign_errors[1m]) or rate(execute_sponsored_errors[1m]) | Combined view of error rates by type, useful for real-time graphs |
  | (successful*requests / total_requests) * 100                                                                               | Overall success rate as a percentage                              |
  | (rate(successful*requests[1m]) / rate(total_requests[1m])) * 100                                                           | Real-time success rate trend over the past minute                 |
