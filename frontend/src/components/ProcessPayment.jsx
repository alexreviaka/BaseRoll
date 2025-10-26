import React, { useState } from 'react';
import { paymentsApi } from '../api/client';

export default function ProcessPayment({ employee, onComplete }) {
  const [processing, setProcessing] = useState(false);

  const handleProcess = async () => {
    setProcessing(true);
    try {
      await paymentsApi.process({
        company_id: employee.company_id,
        employee_id: employee.id,
        payroll_contract_address: '0x...'
      });
      onComplete();
    } catch (error) {
      console.error('Payment failed:', error);
    } finally {
      setProcessing(false);
    }
  };

  return (
    <button
      onClick={handleProcess}
      disabled={processing}
      className="bg-green-600 text-white px-4 py-2 rounded"
    >
      {processing ? 'Processing...' : 'Process Payment'}
    </button>
  );
}
