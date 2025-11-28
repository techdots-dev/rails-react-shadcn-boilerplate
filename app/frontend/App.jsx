import { useEffect, useState } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import api, { sessionHeaders, storeSessionId, storeSessionToken } from "./lib/api";
import Login from "./pages/LoginPage";
import Signup from "./pages/SignupPage";
import ForgotPassword from "./pages/ForgotPasswordPage";
import Dashboard from "./pages/Dashboard";

function ProtectedRoute({ isAuthenticated, children }) {
  if (isAuthenticated === null) return null;
  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function GuestRoute({ isAuthenticated, children }) {
  if (isAuthenticated === null) return null;
  return isAuthenticated ? <Navigate to="/dashboard" replace /> : children;
}

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(null);

  useEffect(() => {
    async function checkSession() {
      try {
        await api.get("/sessions", { headers: sessionHeaders() });
        setIsAuthenticated(true);
      } catch (error) {
        storeSessionToken(null);
        storeSessionId(null);
        setIsAuthenticated(false);
      }
    }

    checkSession();
  }, []);

  if (isAuthenticated === null) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p className="text-gray-600">Loading...</p>
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        <Route
          path="/"
          element={
            <Navigate
              to={isAuthenticated ? "/dashboard" : "/login"}
              replace
            />
          }
        />
        <Route
          path="/login"
          element={
            <GuestRoute isAuthenticated={isAuthenticated}>
              <Login onLogin={() => setIsAuthenticated(true)} />
            </GuestRoute>
          }
        />
        <Route
          path="/sign_in"
          element={
            <GuestRoute isAuthenticated={isAuthenticated}>
              <Login onLogin={() => setIsAuthenticated(true)} />
            </GuestRoute>
          }
        />
        <Route
          path="/signup"
          element={
            <GuestRoute isAuthenticated={isAuthenticated}>
              <Signup />
            </GuestRoute>
          }
        />
        <Route
          path="/forgot-password"
          element={
            <GuestRoute isAuthenticated={isAuthenticated}>
              <ForgotPassword />
            </GuestRoute>
          }
        />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute isAuthenticated={isAuthenticated}>
              <Dashboard onLogout={() => setIsAuthenticated(false)} />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}
