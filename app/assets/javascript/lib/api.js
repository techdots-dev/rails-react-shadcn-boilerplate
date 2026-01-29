function detectBaseURL() {
  const meta = document.querySelector('meta[name="api-base-url"]');
  return meta?.content || window.location.origin;
}

export const baseURL = detectBaseURL();

async function request(path, options = {}) {
  const response = await fetch(`${baseURL}${path}`, {
    credentials: "include",
    headers: {
      ...(options.headers || {}),
    },
    ...options,
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || response.statusText);
  }

  const contentType = response.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    return response.json();
  }

  return response.text();
}

export default {
  get: (path, options = {}) => request(path, { method: "GET", ...options }),
  post: (path, body, options = {}) =>
    request(path, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(options.headers || {}),
      },
      body: JSON.stringify(body),
      ...options,
    }),
  delete: (path, options = {}) =>
    request(path, { method: "DELETE", ...options }),
};
