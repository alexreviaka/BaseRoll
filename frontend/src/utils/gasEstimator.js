import { ethers } from 'ethers';

export async function estimateGasCost(transaction, provider) {
  try {
    const gasLimit = await provider.estimateGas(transaction);
    const gasPrice = await provider.getFeeData();
    const gasCost = gasLimit * gasPrice.gasPrice;
    return ethers.formatEther(gasCost);
  } catch (error) {
    console.error('Gas estimation failed:', error);
    return '0.001'; // fallback estimate
  }
}
