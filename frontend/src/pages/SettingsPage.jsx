import React from 'react';
import NotificationSettings from '../components/NotificationSettings';

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Settings</h1>
      <NotificationSettings />
      <div className="bg-white p-6 rounded-lg shadow">
        <h3 className="text-xl font-semibold mb-4">Account Settings</h3>
        <p className="text-gray-600">Coming soon...</p>
      </div>
    </div>
  );
}
