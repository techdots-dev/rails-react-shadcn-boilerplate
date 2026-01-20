import Rollbar from "rollbar";
import { baseURL } from "./api";

async function fetchRollbarConfig() {
  const response = await fetch(`${baseURL}/rollbar`, {
    credentials: "include",
    headers: { Accept: "application/json" },
  });

  if (!response.ok) {
    return null;
  }

  return response.json();
}

export async function initializeRollbar() {
  const config = await fetchRollbarConfig();

  if (!config?.access_token) {
    return null;
  }

  return new Rollbar({
    accessToken: config.access_token,
    captureUncaught: true,
    captureUnhandledRejections: true,
    environment: config.environment,
    payload: {
      client: {
        javascript: {
          source_map_enabled: true,
          code_version: config.code_version,
        },
      },
    },
  });
}
