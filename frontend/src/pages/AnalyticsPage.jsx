import React, { useState, useEffect } from 'react';
import { TrendingUp, Users, DollarSign } from 'lucide-react';

export default function AnalyticsPage() {
  const [analytics, setAnalytics] = useState({
    totalPaid: 0,
    avgSalary: 0,
    employeeGrowth: 0
  });

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Analytics</h1>
      
      <div className="grid md:grid-cols-3 gap-6">
        <AnalyticsCard
          icon={<DollarSign />}
          title="Total Paid"
          value={`$${analytics.totalPaid.toLocaleString()}`}
        />
        <AnalyticsCard
          icon={<Users />}
          title="Avg Salary"
          value={`$${analytics.avgSalary.toLocaleString()}`}
        />
        <AnalyticsCard
          icon={<TrendingUp />}
          title="Growth"
          value={`${analytics.employeeGrowth}%`}
        />
      </div>
    </div>
  );
}

function AnalyticsCard({ icon, title, value }) {
  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <div className="text-blue-600 mb-2">{icon}</div>
      <p className="text-gray-600 text-sm">{title}</p>
      <p className="text-2xl font-bold">{value}</p>
    </div>
  );
}
