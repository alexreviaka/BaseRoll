import React, { useState, useEffect } from 'react';
import { paymentsApi } from '../api/client';

export default function PaymentsPage() {
  const [payments, setPayments] = useState([]);

  useEffect(() => {
    loadPayments();
  }, []);

  const loadPayments = async () => {
    try {
      const response = await paymentsApi.listByCompany('company_id');
      setPayments(response.data);
    } catch (error) {
      console.error('Failed to load payments:', error);
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Payment History</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <p className="text-gray-600">No payments yet</p>
      </div>
    </div>
  );
}
