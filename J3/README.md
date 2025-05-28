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

- Visit this [localhost URL](http://localhost:9090/query?g0.expr=rate%28total_requests%5B1m%5D%29&g0.show_tree=0&g0.tab=graph&g0.range_input=1h&g0.res_type=auto&g0.res_density=medium&g0.display_mode=stacked&g0.show_exemplars=0&g1.expr=rate%28successful_requests%5B1m%5D%29&g1.show_tree=0&g1.tab=graph&g1.range_input=1h&g1.res_type=auto&g1.res_density=medium&g1.display_mode=stacked&g1.show_exemplars=0&g2.expr=rate%28build_errors%5B1m%5D%29&g2.show_tree=0&g2.tab=graph&g2.range_input=1h&g2.res_type=auto&g2.res_density=medium&g2.display_mode=stacked&g2.show_exemplars=0&g3.expr=rate%28sign_errors%5B1m%5D%29&g3.show_tree=0&g3.tab=graph&g3.range_input=1h&g3.res_type=auto&g3.res_density=medium&g3.display_mode=stacked&g3.show_exemplars=0&g4.expr=rate%28create_sponsored_errors%5B1m%5D%29&g4.show_tree=0&g4.tab=graph&g4.range_input=1h&g4.res_type=auto&g4.res_density=medium&g4.display_mode=stacked&g4.show_exemplars=0&g5.expr=%28rate%28successful_requests%5B1m%5D%29+%2F+rate%28total_requests%5B1m%5D%29%29+_+100&g5.show_tree=0&g5.tab=graph&g5.range_input=1h&g5.res_type=auto&g5.res_density=medium&g5.display_mode=stacked&g5.show_exemplars=0&g6.expr=%28rate%28build_errors%5B1m%5D%29+%2B+rate%28create_sponsored_errors%5B1m%5D%29+%2B+rate%28sign_errors%5B1m%5D%29+%2B+rate%28execute_sponsored_errors%5B1m%5D%29%29+%2F+rate%28total_requests%5B1m%5D%29+_+100&g6.show_tree=0&g6.tab=graph&g6.range_input=1h&g6.res_type=auto&g6.res_density=medium&g6.display_mode=stacked&g6.show_exemplars=0&g7.expr=rate%28total_requests%5B1m%5D%29&g7.show_tree=0&g7.tab=graph&g7.range_input=1h&g7.res_type=auto&g7.res_density=medium&g7.display_mode=stacked&g7.show_exemplars=0) to check a dashboard exposing multiple interesting metrics
