import { render, screen } from '@testing-library/react';
import Dashboard from '../pages/Dashboard';

test('renders dashboard title', () => {
  render(<Dashboard />);
  const title = screen.getByText(/Dashboard/i);
  expect(title).toBeInTheDocument();
});
