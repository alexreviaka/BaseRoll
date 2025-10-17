import React from 'react';
import { formatAddress, formatDate } from '../utils/formatters';

export default function TransactionHistory({ transactions }) {
  return (
    <div className="space-y-2">
      {transactions.map((tx) => (
        <div key={tx.id} className="border p-4 rounded-lg">
          <p className="font-semibold">{formatAddress(tx.to)}</p>
          <p className="text-sm text-gray-600">{formatDate(tx.timestamp)}</p>
          <p className="text-sm">${tx.amount}</p>
        </div>
      ))}
    </div>
  );
}
