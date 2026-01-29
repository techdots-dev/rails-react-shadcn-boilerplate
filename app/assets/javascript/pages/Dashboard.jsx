import React from "react";
import api from "../lib/api";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";

export default function Dashboard({ onLogout, user }) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await api.delete("/sign_out");
      onLogout?.();
      navigate("/login", { replace: true })
    } catch (err) {
      console.error("Logout failed", err);
    }
  };

  const displayName = user?.email || t("dashboard.guest");

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto py-10">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">
            {t("dashboard.title")}
          </h1>
          <button
            onClick={handleLogout}
            className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
          >
            {t("dashboard.logout")}
          </button>
        </div>

        <div className="bg-white shadow rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">
            {t("dashboard.welcomeWithUser", { user: displayName })}
          </h2>
          <p className="text-gray-600">
            {t("dashboard.description")}
          </p>
        </div>
      </div>
    </div>
  );
}
