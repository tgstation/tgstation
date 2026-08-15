import { describe, expect, it } from 'bun:test';
import { act, render, screen } from '@testing-library/react';
import { gameDataAtom, store } from '../events/store';

import { Crystallizer } from './Crystallizer';

store.set(gameDataAtom, {
  on: 0,
  requirements: '',
  internal_temperature: 293.15,
  progress_bar: 0,
  gas_input: 0,
  selected: '',
  selected_recipes: [],
  internal_gas_data: [
    { id: 'hydrogen', name: 'Hydrogen', amount: 1000 },
    { id: 'o2', name: 'Oxygen', amount: 500 },
  ],
});

describe('Crystallizer', () => {
  it('uses dark text for hydrogen without changing other gas labels', () => {
    act(() => render(<Crystallizer />));

    const hydrogenAmount = screen.getByText(/^1000(?:\.00)? moles$/);
    const oxygenAmount = screen.getByText(/^500(?:\.00)? moles$/);

    expect(hydrogenAmount.classList.contains('color-black')).toBe(true);
    expect(oxygenAmount.classList.contains('color-black')).toBe(false);
  });
});
