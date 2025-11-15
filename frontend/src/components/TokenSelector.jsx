import React from 'react';

const SUPPORTED_TOKENS = [
  { symbol: 'ETH', name: 'Ethereum', address: '0x0' },
  { symbol: 'USDC', name: 'USD Coin', address: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913' },
  { symbol: 'DAI', name: 'Dai Stablecoin', address: '0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb' }
];

export default function TokenSelector({ value, onChange }) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className="w-full px-4 py-2 border rounded-lg"
    >
      {SUPPORTED_TOKENS.map(token => (
        <option key={token.symbol} value={token.address}>
          {token.symbol} - {token.name}
        </option>
      ))}
    </select>
  );
}
