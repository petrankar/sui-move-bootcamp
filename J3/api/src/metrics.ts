import client from "prom-client";

// Create a new registry to register all metrics
export const register = new client.Registry();

// Enable collection of default system metrics
client.collectDefaultMetrics({ register });

// Define custom counters
export const totalRequests = new client.Counter({
  name: "total_requests",
  help: "Total number of mint requests",
});

export const successfulRequests = new client.Counter({
  name: "successful_requests",
  help: "Number of successful mints",
});

export const invalidBodyRequests = new client.Counter({
  name: "invalid_body_requests",
  help: "Requests with invalid or missing body",
});

export const buildErrors = new client.Counter({
  name: "build_errors",
  help: "Errors during transaction building",
});

export const createSponsoredErrors = new client.Counter({
  name: "create_sponsored_errors",
  help: "Errors during Enoki sponsorship creation",
});

export const signErrors = new client.Counter({
  name: "sign_errors",
  help: "Errors during signing sponsored transaction",
});

export const execSponsoredErrors = new client.Counter({
  name: "execute_sponsored_errors",
  help: "Errors during execution of sponsored transaction",
});

// Register all metrics
register.registerMetric(totalRequests);
register.registerMetric(successfulRequests);
register.registerMetric(invalidBodyRequests);
register.registerMetric(buildErrors);
register.registerMetric(createSponsoredErrors);
register.registerMetric(signErrors);
register.registerMetric(execSponsoredErrors);
