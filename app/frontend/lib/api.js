export const SESSION_ID_KEY = "sessionId";
export const SESSION_TOKEN_KEY = "sessionToken";
export const baseURL = import.meta.env.VITE_API_BASE_URL || window.location.origin;

export function storeSessionToken(token) {
  if (token) {
    localStorage.setItem(SESSION_TOKEN_KEY, token);
  } else {
    localStorage.removeItem(SESSION_TOKEN_KEY);
  }
}

export function storeSessionId(id) {
  if (id) {
    localStorage.setItem(SESSION_ID_KEY, String(id));
  } else {
    localStorage.removeItem(SESSION_ID_KEY);
  }
}

export function currentSessionId() {
  return localStorage.getItem(SESSION_ID_KEY);
}

export function sessionHeaders() {
  const token = localStorage.getItem(SESSION_TOKEN_KEY);
  return token ? { Authorization: `Token token=${token}` } : {};
}

async function request(path, options = {}) {
  const response = await fetch(`${baseURL}${path}`, {
    credentials: "include",
    headers: {
      ...sessionHeaders(),
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
  post: (path, body, options = {}) => request(path, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    body: JSON.stringify(body),
    ...options,
  }),
  delete: (path, options = {}) => request(path, { method: "DELETE", ...options }),
};
