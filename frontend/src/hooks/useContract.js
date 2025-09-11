import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { useWallet } from './useWallet';

export function useContract(address, abi) {
  const { signer, provider } = useWallet();
  const [contract, setContract] = useState(null);

  useEffect(() => {
    if (address && abi && (signer || provider)) {
      const contractInstance = new ethers.Contract(
        address,
        abi,
        signer || provider
      );
      setContract(contractInstance);
    }
  }, [address, abi, signer, provider]);

  return contract;
}
