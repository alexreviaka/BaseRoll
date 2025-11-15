import { companiesApi, employeesApi, paymentsApi } from '../api/client';

export const ApiService = {
  companies: {
    getAll: () => companiesApi.list(),
    getById: (id) => companiesApi.get(id),
    create: (data) => companiesApi.create(data)
  },
  employees: {
    getByCompany: (companyId) => employeesApi.listByCompany(companyId),
    create: (data) => employeesApi.create(data)
  },
  payments: {
    process: (data) => paymentsApi.process(data),
    getHistory: (companyId) => paymentsApi.listByCompany(companyId)
  }
};
