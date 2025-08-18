import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Users, CreditCard, Shield } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="space-y-16">
      <section className="text-center py-20">
        <h1 className="text-5xl font-bold text-gray-900 mb-6">
          Decentralized Payroll on Base
        </h1>
        <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
          Automate your company's salary payments using blockchain technology.
          Fast, secure, and transparent.
        </p>
        <Link
          to="/dashboard"
          className="inline-flex items-center space-x-2 bg-blue-600 text-white px-8 py-3 rounded-lg hover:bg-blue-700 text-lg"
        >
          <span>Get Started</span>
          <ArrowRight className="w-5 h-5" />
        </Link>
      </section>

      <section className="grid md:grid-cols-3 gap-8">
        <FeatureCard
          icon={<Users className="w-12 h-12 text-blue-600" />}
          title="Employee Management"
          description="Add and manage employees with their wallet addresses and salary information."
        />
        <FeatureCard
          icon={<CreditCard className="w-12 h-12 text-blue-600" />}
          title="Automated Payments"
          description="Schedule recurring payments that execute automatically via smart contracts."
        />
        <FeatureCard
          icon={<Shield className="w-12 h-12 text-blue-600" />}
          title="Secure & Transparent"
          description="All transactions recorded on Base blockchain for complete transparency."
        />
      </section>
    </div>
  );
}

function FeatureCard({ icon, title, description }) {
  return (
    <div className="bg-white p-8 rounded-lg shadow-sm border">
      <div className="mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  );
}
