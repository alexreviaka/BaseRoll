import React, { useState } from 'react';
import { companiesApi } from '../api/client';
import { useWallet } from '../hooks/useWallet';

export default function RegisterCompany() {
  const { account } = useWallet();
  const [formData, setFormData] = useState({ name: '', email: '' });

  const handleSubmit = async (e) => {
    e.preventDefault();
    await companiesApi.create({
      ...formData,
      wallet_address: account
    });
  };

  return (
    <form onSubmit={handleSubmit} className="max-w-lg mx-auto p-6 bg-white rounded-lg shadow">
      <h2 className="text-2xl font-bold mb-4">Register Company</h2>
      <input
        placeholder="Company Name"
        value={formData.name}
        onChange={(e) => setFormData({...formData, name: e.target.value})}
        className="w-full mb-4 px-4 py-2 border rounded"
        required
      />
      <input
        type="email"
        placeholder="Email"
        value={formData.email}
        onChange={(e) => setFormData({...formData, email: e.target.value})}
        className="w-full mb-4 px-4 py-2 border rounded"
        required
      />
      <button type="submit" className="w-full bg-blue-600 text-white py-2 rounded">
        Register
      </button>
    </form>
  );
}
