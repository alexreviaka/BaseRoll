import PayrollABI from './Payroll.json';
import FactoryABI from './PayrollFactory.json';
import RegistryABI from './EmployeeRegistry.json';

export const ABIS = {
  Payroll: PayrollABI,
  PayrollFactory: FactoryABI,
  EmployeeRegistry: RegistryABI
};

export function getABI(contractName) {
  return ABIS[contractName];
}
