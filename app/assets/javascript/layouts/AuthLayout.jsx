// app/assets/javascript/layouts/AuthLayout.jsx
import React from "react";

export default function AuthLayout({ title, children }) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="w-full max-w-md bg-white rounded-2xl shadow p-8">
        {/* Logo */}
        <div className="flex justify-center mb-6">
          <img
            src="/logo.png"
            alt="App Logo"
            className="h-12 w-auto"
          />
        </div>

        {/* Title */}
        <h2 className="text-2xl font-bold text-center mb-6">{title}</h2>

        {/* Form content (passed in from each page) */}
        {children}
      </div>
    </div>
  );
}
