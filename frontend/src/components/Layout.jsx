import React from 'react';
import { Outlet, Link } from 'react-router-dom';
import { Wallet } from 'lucide-react';

export default function Layout() {
  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <div className="flex items-center space-x-8">
              <Link to="/" className="flex items-center space-x-2">
                <Wallet className="w-8 h-8 text-blue-600" />
                <span className="text-xl font-bold text-gray-900">BaseRoll</span>
              </Link>
              
              <div className="hidden md:flex space-x-6">
                <Link to="/dashboard" className="text-gray-700 hover:text-blue-600">
                  Dashboard
                </Link>
                <Link to="/employees" className="text-gray-700 hover:text-blue-600">
                  Employees
                </Link>
                <Link to="/payments" className="text-gray-700 hover:text-blue-600">
                  Payments
                </Link>
              </div>
            </div>
            
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
              Connect Wallet
            </button>
          </div>
        </div>
      </nav>
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
      
      <footer className="bg-white border-t mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-gray-600">
            © 2025 BaseRoll. Built on Base blockchain.
          </p>
        </div>
      </footer>
    </div>
  );
}
