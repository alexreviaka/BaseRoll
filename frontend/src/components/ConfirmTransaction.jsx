import React from 'react';

export default function ConfirmTransaction({ transaction, onConfirm, onCancel }) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div className="bg-white p-6 rounded-lg max-w-md">
        <h3 className="text-xl font-bold mb-4">Confirm Transaction</h3>
        <div className="space-y-2 mb-6">
          <p><strong>To:</strong> {transaction.to}</p>
          <p><strong>Amount:</strong> ${transaction.amount}</p>
          <p><strong>Gas:</strong> ~${transaction.estimatedGas}</p>
        </div>
        <div className="flex space-x-4">
          <button
            onClick={onConfirm}
            className="flex-1 bg-blue-600 text-white py-2 rounded"
          >
            Confirm
          </button>
          <button
            onClick={onCancel}
            className="flex-1 bg-gray-300 py-2 rounded"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
}
