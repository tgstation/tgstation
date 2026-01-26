import { describe, expect, it } from 'bun:test';
import { act, render, screen } from '@testing-library/react';
import { gameDataAtom, store } from '../events/store';

import { Radio } from './Radio';

// Just an example unit test!

store.set(gameDataAtom, {
  freqlock: 0,
  frequency: 1553,
  minFrequency: 1200,
  maxFrequency: 1600,
  listening: 1,
  broadcasting: 0,
  command: 0,
  useCommand: 1,
  subspace: 0,
  subspaceSwitchable: 1,
  channels: {},
  radio_noises: 0,
});

describe('Radio tests', () => {
  it('loads without failing', () => {
    act(() => render(<Radio />));

    // Radio doesn't have a default title
    expect(screen.getByText('Test UI')).toBeDefined();
  });

  it('displays frequency correctly', () => {
    act(() => render(<Radio />));

    expect(screen.getByText('155.3')).toBeDefined();
  });
});
