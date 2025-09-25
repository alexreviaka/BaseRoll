export function formatAddress(addr) {
  return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
}

export function formatCurrency(amount) {
  return `$${amount.toLocaleString()}`;
}
