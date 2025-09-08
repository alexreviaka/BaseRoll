import React, { useState } from 'react';

export default function EmployeeForm({ onSubmit, initialData = null }) {
  const [formData, setFormData] = useState(initialData || {
    name: '',
    email: '',
    wallet_address: '',
    position: '',
    salary: '',
    payment_token: 'ETH'
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-2">Name</label>
        <input
          type="text"
          value={formData.name}
          onChange={(e) => setFormData({...formData, name: e.target.value})}
          className="w-full px-4 py-2 border rounded-lg"
          required
        />
      </div>
      <div>
        <label className="block text-sm font-medium mb-2">Email</label>
        <input
          type="email"
          value={formData.email}
          onChange={(e) => setFormData({...formData, email: e.target.value})}
          className="w-full px-4 py-2 border rounded-lg"
          required
        />
      </div>
      <div>
        <label className="block text-sm font-medium mb-2">Wallet Address</label>
        <input
          type="text"
          value={formData.wallet_address}
          onChange={(e) => setFormData({...formData, wallet_address: e.target.value})}
          className="w-full px-4 py-2 border rounded-lg"
          required
        />
      </div>
      <div>
        <label className="block text-sm font-medium mb-2">Position</label>
        <input
          type="text"
          value={formData.position}
          onChange={(e) => setFormData({...formData, position: e.target.value})}
          className="w-full px-4 py-2 border rounded-lg"
          required
        />
      </div>
      <div>
        <label className="block text-sm font-medium mb-2">Salary (USD)</label>
        <input
          type="number"
          value={formData.salary}
          onChange={(e) => setFormData({...formData, salary: e.target.value})}
          className="w-full px-4 py-2 border rounded-lg"
          required
        />
      </div>
      <button type="submit" className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700">
        {initialData ? 'Update Employee' : 'Add Employee'}
      </button>
    </form>
  );
}
