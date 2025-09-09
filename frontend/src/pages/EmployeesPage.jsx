import React, { useState, useEffect } from 'react';
import { employeesApi } from '../api/client';
import EmployeeList from '../components/employees/EmployeeList';
import EmployeeForm from '../components/employees/EmployeeForm';
import { Plus } from 'lucide-react';

export default function EmployeesPage() {
  const [employees, setEmployees] = useState([]);
  const [showForm, setShowForm] = useState(false);

  useEffect(() => {
    loadEmployees();
  }, []);

  const loadEmployees = async () => {
    try {
      const response = await employeesApi.listByCompany('company_id');
      setEmployees(response.data);
    } catch (error) {
      console.error('Failed to load employees:', error);
    }
  };

  const handleAddEmployee = async (data) => {
    try {
      await employeesApi.create(data);
      setShowForm(false);
      loadEmployees();
    } catch (error) {
      console.error('Failed to add employee:', error);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Employees</h1>
        <button
          onClick={() => setShowForm(!showForm)}
          className="flex items-center space-x-2 bg-blue-600 text-white px-4 py-2 rounded-lg"
        >
          <Plus className="w-5 h-5" />
          <span>Add Employee</span>
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-4">New Employee</h2>
          <EmployeeForm onSubmit={handleAddEmployee} />
        </div>
      )}

      <EmployeeList
        employees={employees}
        onEdit={(emp) => console.log('Edit:', emp)}
        onDelete={(id) => console.log('Delete:', id)}
      />
    </div>
  );
}
