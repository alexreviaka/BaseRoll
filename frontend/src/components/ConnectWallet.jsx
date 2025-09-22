import React from 'react';
import { useWallet } from '../hooks/useWallet';

export default function ConnectWallet() {
  const { account, connect, disconnect } = useWallet();

  if (account) {
    return <button onClick={disconnect}>Disconnect</button>;
  }
  return <button onClick={connect}>Connect Wallet</button>;
}
