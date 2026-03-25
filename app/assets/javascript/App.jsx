import React, { useEffect, useState } from "react";
import "./i18n";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
  useLocation,
} from "react-router-dom";
import api from "./lib/api";
import Login from "./pages/LoginPage";
import Signup from "./pages/SignupPage";
import ForgotPassword from "./pages/ForgotPasswordPage";
import Dashboard from "./pages/Dashboard";

function ProtectedRoute({ isAuthenticated, children }) {
  if (isAuthenticated === null) return null;
  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function DefaultSignedInRedirect({ currentUser }) {
  useEffect(() => {
    if (currentUser?.admin) {
      window.location.replace("/admin");
    }
  }, [currentUser]);

  if (currentUser?.admin) return null;

  return <Navigate to="/dashboard" replace />;
}

function GuestRoute({ isAuthenticated, currentUser, children }) {
  if (isAuthenticated === null) return null;
  return isAuthenticated ? (
    <DefaultSignedInRedirect currentUser={currentUser} />
  ) : (
    children
  );
}

const guestPaths = new Set([
  "/login",
  "/sign_in",
  "/signup",
  "/forgot-password",
]);

function AppRoutes() {
  const location = useLocation();
  const [isAuthenticated, setIsAuthenticated] = useState(null);
  const [currentUser, setCurrentUser] = useState(null);
  const checkedPathRef = React.useRef(null);
  const loadingRef = React.useRef(false);

  const handleLogin = (user) => {
    setCurrentUser(user);
    setIsAuthenticated(true);
  };

  const loadCurrentUser = async () => {
    if (loadingRef.current) return;
    try {
      loadingRef.current = true;
      const user = await api.get("/current_user");
      setCurrentUser(user);
      setIsAuthenticated(true);
    } catch (error) {
      setCurrentUser(null);
      setIsAuthenticated(false);
    } finally {
      loadingRef.current = false;
    }
  };

  useEffect(() => {
    const pathname = location.pathname;
    if (guestPaths.has(pathname)) {
      if (isAuthenticated === null) {
        setIsAuthenticated(false);
      }
      return;
    }

    if (isAuthenticated === false) return;
    if (isAuthenticated === true && currentUser) return;

    if (checkedPathRef.current === pathname) return;
    checkedPathRef.current = pathname;
    loadCurrentUser();
  }, [location.pathname, isAuthenticated, currentUser]);

  if (isAuthenticated === null) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p className="text-gray-600">Loading...</p>
      </div>
    );
  }

  return (
    <Routes>
      <Route
        path="/"
        element={
          isAuthenticated ? (
            <DefaultSignedInRedirect currentUser={currentUser} />
          ) : (
            <Navigate to="/login" replace />
          )
        }
      />
      <Route
        path="/login"
        element={
          <GuestRoute
            isAuthenticated={isAuthenticated}
            currentUser={currentUser}
          >
            <Login onLogin={handleLogin} />
          </GuestRoute>
        }
      />
      <Route
        path="/sign_in"
        element={
          <GuestRoute
            isAuthenticated={isAuthenticated}
            currentUser={currentUser}
          >
            <Login onLogin={handleLogin} />
          </GuestRoute>
        }
      />
      <Route
        path="/signup"
        element={
          <GuestRoute
            isAuthenticated={isAuthenticated}
            currentUser={currentUser}
          >
            <Signup />
          </GuestRoute>
        }
      />
      <Route
        path="/forgot-password"
        element={
          <GuestRoute
            isAuthenticated={isAuthenticated}
            currentUser={currentUser}
          >
            <ForgotPassword />
          </GuestRoute>
        }
      />
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute isAuthenticated={isAuthenticated}>
            {currentUser?.admin ? (
              <DefaultSignedInRedirect currentUser={currentUser} />
            ) : (
              <Dashboard
                user={currentUser}
                onLogout={() => {
                  setCurrentUser(null);
                  setIsAuthenticated(false);
                }}
              />
            )}
          </ProtectedRoute>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <Router>
      <AppRoutes />
    </Router>
  );
}
