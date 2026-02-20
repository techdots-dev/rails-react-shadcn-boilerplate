import React from "react";
import ReactDOM from "react-dom/client";
import { ErrorBoundary, Provider as RollbarProvider } from "@rollbar/react";
import App from "../App";
import "../App.css";
import "../lib/posthog";
import { initializeRollbar } from "../lib/rollbar";
import "../../javascript/App.css";
import "../../javascript/index.css";
document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.getElementById("root");

  if (rootElement) {
    const root = ReactDOM.createRoot(rootElement);

    const app = (
      <React.StrictMode>
        <App />
      </React.StrictMode>
    );

    const renderApp = (rollbarInstance) => {
      const appWithRollbar = rollbarInstance ? (
        <RollbarProvider instance={rollbarInstance}>
          <ErrorBoundary>{app}</ErrorBoundary>
        </RollbarProvider>
      ) : (
        app
      );

      root.render(appWithRollbar);
    };

    initializeRollbar()
      .then(renderApp)
      .catch((error) => {
        console.warn("Rollbar failed to initialize", error);
        renderApp(null);
      });
  } else {
    console.error("Could not find #root element to mount React app");
  }
});
