import { useState } from 'react';
import { useContract } from './useContract';
import { ethers } from 'ethers';

export function useEmployeeOnboarding(payrollAddress) {
  const [loading, setLoading] = useState(false);
  const contract = useContract(payrollAddress, []); // Add ABI

  const addEmployeeToChain = async (employee) => {
    try {
      setLoading(true);
      const tx = await contract.addEmployee(
        employee.wallet_address,
        ethers.parseEther(employee.salary.toString()),
        employee.payment_token || ethers.ZeroAddress
      );
      await tx.wait();
      return tx.hash;
    } finally {
      setLoading(false);
    }
  };

  return { addEmployeeToChain, loading };
}
