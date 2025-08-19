import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' }
});

export const companiesApi = {
  create: (data) => apiClient.post('/api/companies/', data),
  list: () => apiClient.get('/api/companies/'),
  get: (id) => apiClient.get(`/api/companies/${id}`)
};

export const employeesApi = {
  create: (data) => apiClient.post('/api/employees/', data),
  listByCompany: (companyId) => apiClient.get(`/api/employees/company/${companyId}`)
};

export default apiClient;
