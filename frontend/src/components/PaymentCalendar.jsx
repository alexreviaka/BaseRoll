import React from 'react';
import { Calendar } from 'lucide-react';

export default function PaymentCalendar({ schedules }) {
  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <div className="flex items-center space-x-2 mb-4">
        <Calendar className="w-6 h-6 text-blue-600" />
        <h3 className="text-xl font-semibold">Payment Schedule</h3>
      </div>
      <div className="space-y-2">
        {schedules.map((schedule, i) => (
          <div key={i} className="flex justify-between items-center p-3 bg-gray-50 rounded">
            <span>{schedule.employee_name}</span>
            <span className="text-sm text-gray-600">{schedule.next_payment_date}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
