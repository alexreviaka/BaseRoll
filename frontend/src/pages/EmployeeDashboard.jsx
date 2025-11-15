import React, { useState, useEffect } from 'react';
import { paymentsApi } from '../api/client';

export default function EmployeeDashboard() {
  const [payments, setPayments] = useState([]);

  useEffect(() => {
    loadPayments();
  }, []);

  const loadPayments = async () => {
    const response = await paymentsApi.listByEmployee('employee_id');
    setPayments(response.data);
  };

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">My Payments</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">Payment History</h2>
        {payments.length === 0 ? (
          <p className="text-gray-600">No payments yet</p>
        ) : (
          <div className="space-y-2">
            {payments.map(payment => (
              <div key={payment.id} className="border-b pb-2">
                <p className="font-semibold">${payment.amount}</p>
                <p className="text-sm text-gray-600">{new Date(payment.timestamp).toLocaleDateString()}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
