import React, { useState, useEffect } from 'react';
import { useWallet } from '../hooks/useWallet';
import { companiesApi, employeesApi, paymentsApi } from '../api/client';
import { Users, DollarSign, TrendingUp, Calendar } from 'lucide-react';

export default function Dashboard() {
  const { account, isBase } = useWallet();
  const [stats, setStats] = useState({
    totalEmployees: 0,
    totalPayments: 0,
    monthlyPayroll: 0,
    nextPayment: null
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (account) {
      loadDashboardData();
    }
  }, [account]);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      // Load company data
      const companies = await companiesApi.list();
      const userCompany = companies.data.find(c => 
        c.wallet_address.toLowerCase() === account.toLowerCase()
      );

      if (userCompany) {
        const employees = await employeesApi.listByCompany(userCompany.id);
        const payments = await paymentsApi.listByCompany(userCompany.id);
        
        setStats({
          totalEmployees: employees.data.length,
          totalPayments: payments.data.length,
          monthlyPayroll: employees.data.reduce((sum, emp) => sum + emp.salary, 0),
          nextPayment: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        });
      }
    } catch (error) {
      console.error('Failed to load dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  if (!account) {
    return (
      <div className="text-center py-20">
        <h2 className="text-2xl font-bold mb-4">Connect Your Wallet</h2>
        <p className="text-gray-600">Please connect your wallet to view dashboard</p>
      </div>
    );
  }

  if (!isBase) {
    return (
      <div className="text-center py-20">
        <h2 className="text-2xl font-bold mb-4">Switch to Base Network</h2>
        <p className="text-gray-600">Please switch to Base network to continue</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      
      <div className="grid md:grid-cols-4 gap-6">
        <StatCard
          icon={<Users className="w-8 h-8" />}
          title="Total Employees"
          value={stats.totalEmployees}
          color="blue"
        />
        <StatCard
          icon={<DollarSign className="w-8 h-8" />}
          title="Total Payments"
          value={stats.totalPayments}
          color="green"
        />
        <StatCard
          icon={<TrendingUp className="w-8 h-8" />}
          title="Monthly Payroll"
          value={`$${stats.monthlyPayroll.toLocaleString()}`}
          color="purple"
        />
        <StatCard
          icon={<Calendar className="w-8 h-8" />}
          title="Next Payment"
          value={stats.nextPayment?.toLocaleDateString() || 'N/A'}
          color="orange"
        />
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-4">Recent Activity</h2>
        <p className="text-gray-600">No recent activity</p>
      </div>
    </div>
  );
}

function StatCard({ icon, title, value, color }) {
  const colors = {
    blue: 'text-blue-600 bg-blue-50',
    green: 'text-green-600 bg-green-50',
    purple: 'text-purple-600 bg-purple-50',
    orange: 'text-orange-600 bg-orange-50'
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow">
      <div className={`${colors[color]} w-12 h-12 rounded-lg flex items-center justify-center mb-4`}>
        {icon}
      </div>
      <p className="text-gray-600 text-sm mb-1">{title}</p>
      <p className="text-2xl font-bold">{value}</p>
    </div>
  );
}
