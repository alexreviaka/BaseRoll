import React from 'react';

export default function PaymentStatus({ status }) {
  const colors = {
    pending: 'bg-yellow-100 text-yellow-800',
    completed: 'bg-green-100 text-green-800',
    failed: 'bg-red-100 text-red-800'
  };

  return (
    <span className={`px-2 py-1 rounded ${colors[status]}`}>
      {status}
    </span>
  );
}
