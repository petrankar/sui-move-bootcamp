## Sui & Move Bootcamp <> Using Prometheus and Grafana for Monitoring (+ a real-world airdrop scenario as a bonus gift)

For this exercise we will show how we can monitor an NFT-airdrop REST API with Prometheus and Grafana.

### Project Structure

```bash
J3/
├── move/ # The smart contracts for the Hero NFT
│── api/ # The NodeJS-ExpressJS REST API
│── client.sh # A simple bash script that calls the endpoint in a while loop to see the results
├── README.md # Project documentation
```

## Overview

Let's say that we want to have an airdrop of an NFT Collection of `Hero` NFTs, with the following specs:

- The NFTs should not be pre-minted
- The users do not pay for the gas
- Only an admin address can mint NFTs
- Multiple concurrent requests should be served

And that we want to monitor some simple metrics (total requests, successful request, failed requests) with Prometheus and Grafana.

## Architecture Overview

- UI: Sends a POST request to the /mint endpoint of the REST API, including the recipient's address in the HTTP body of the request
- REST API: Builds, signs, sponsors with Enoki, and executes a PTB for minting the NFT for this recipient

### Quickstart

#### 1. Publish the smart contracts and start the API

- The exact steps for that can be found in the [api/README.md](./api/README.md) file.
- After following them, try visiting http://localhost:8000, and you should get a "Hello, world!" response

#### 3. Setup the Prometheus Metrics Server

Now let's start the Prometheus server as well, so that we can start monitoring the API:

- Change your current directory into the root [J3](../J3/) of the current exercies
- Run `docker-compose up`
- If you visit `http://localhost:9090/` in a web browser, you will see a simple dashboard provided by Prometheus
- Please notice that the exposed metrics have been defined in the [metrics.ts](./api/src/metrics.ts) file of the API.

#### 4. Simulate a scenario and observe the metrics

- Run the [mint.sh](./mint.sh) script to simulate 50 almost concurrent users requesting their NFT:

  ```
  cd J3/
  chmod +x ./mint.sh
  ./mint.sh
  ```

- These are some interesting metrics you can calculate in http://localhost:9090/:

  | Query                                                                   | Description                             |
  | ----------------------------------------------------------------------- | --------------------------------------- |
  | rate(total_requests[1m])                                                | Total requests per minute               |
  | rate(successful_requests[1m])                                           | Successful requests per minute          |
  | rate(failed_requests[1m])                                               | Failed requests per minute              |
  | (rate(successful_requests[1m]) / rate(total_requests[1m])) \* 100       | Success rate trend over the past minute |
  | (rate(failed_requests[1m]) / rate(total_requests[1m])) \* 100           | Failure rate trend over the past minute |
  | mint_request_duration_seconds_sum / mint_request_duration_seconds_count | Average duration of successful requests |
