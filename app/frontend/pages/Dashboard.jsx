import { useEffect, useState } from "react";
import api, {
  currentSessionId,
  sessionHeaders,
  storeSessionId,
  storeSessionToken,
} from "../lib/api";

export default function Dashboard({ onLogout }) {
  const [user, setUser] = useState(null);

  // Example: check session on mount
  useEffect(() => {
    api
      .get("/sessions", { headers: sessionHeaders() })
      .then((data) => setUser(data))
      .catch(() => {
        storeSessionToken(null);
        storeSessionId(null);
        onLogout?.();
      });
  }, []);

  const handleLogout = async () => {
    try {
      const sessionId = currentSessionId();
      const endpoint = sessionId ? `/sessions/${sessionId}` : "/sessions/1";

      await api.delete(endpoint, { headers: sessionHeaders() });
      storeSessionToken(null);
      storeSessionId(null);
      onLogout?.();
      window.location.href = "/login";
    } catch (err) {
      console.error("Logout failed", err);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto py-10">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <button
            onClick={handleLogout}
            className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
          >
            Logout
          </button>
        </div>

        <div className="bg-white shadow rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">
            Welcome {user?.email || "Guest"} 🎉
          </h2>
          <p className="text-gray-600">
            This is your dummy dashboard. Replace this with charts, tasks, or
            any data from your Rails API.
          </p>
        </div>
      </div>
    </div>
  );
}
