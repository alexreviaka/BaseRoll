import React from 'react';
import { Trash2, Edit } from 'lucide-react';

export default function EmployeeList({ employees, onEdit, onDelete }) {
  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Position</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Salary</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {employees.map((employee) => (
            <tr key={employee.id} data-testid={`employee-row-${employee.id}`}>
              <td className="px-6 py-4 whitespace-nowrap">{employee.name}</td>
              <td className="px-6 py-4 whitespace-nowrap">{employee.email}</td>
              <td className="px-6 py-4 whitespace-nowrap">{employee.position}</td>
              <td className="px-6 py-4 whitespace-nowrap">${employee.salary}</td>
              <td className="px-6 py-4 whitespace-nowrap space-x-2">
                <button onClick={() => onEdit(employee)} className="text-blue-600 hover:text-blue-800">
                  <Edit className="w-5 h-5" />
                </button>
                <button onClick={() => onDelete(employee.id)} className="text-red-600 hover:text-red-800">
                  <Trash2 className="w-5 h-5" />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
