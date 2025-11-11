import React, { useState } from 'react';

export default function NotificationSettings() {
  const [prefs, setPrefs] = useState({
    email: true,
    push: false,
    sms: false
  });

  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <h3 className="text-xl font-semibold mb-4">Notification Preferences</h3>
      {Object.keys(prefs).map(key => (
        <label key={key} className="flex items-center space-x-2 mb-2">
          <input
            type="checkbox"
            checked={prefs[key]}
            onChange={(e) => setPrefs({...prefs, [key]: e.target.checked})}
          />
          <span className="capitalize">{key}</span>
        </label>
      ))}
    </div>
  );
}
