import { getGasColor, getGasFromId, getGasFromPath, getGasLabel } from './constants';

describe('gas helper functions', () => {
  it('should get the proper gas label', () => {
    const gasId = 'antinoblium';
    const gasLabel = getGasLabel(gasId);
    expect(gasLabel).toBe('Anti-Noblium');
  });

  it('should get the proper gas label with a fallback', () => {
    const gasId = 'nonexistent';
    const gasLabel = getGasLabel(gasId, 'fallback');

    expect(gasLabel).toBe('fallback');
  });

  it('should return none if no gas and no fallback is found', () => {
    const gasId = 'nonexistent';
    const gasLabel = getGasLabel(gasId);

    expect(gasLabel).toBe('None');
  });

  it('should get the proper gas color', () => {
    const gasId = 'antinoblium';
    const gasColor = getGasColor(gasId);

    expect(gasColor).toBe('maroon');
  });

  it('should return a string if no gas is found', () => {
    const gasId = 'nonexistent';
    const gasColor = getGasColor(gasId);

    expect(gasColor).toBe('black');
  });

  it('should return the gas object if found', () => {
    const gasId = 'antinoblium';
    const gas = getGasFromId(gasId);

    expect(gas).toEqual({
      id: 'antinoblium',
      path: '/datum/gas/antinoblium',
      name: 'Antinoblium',
      label: 'Anti-Noblium',
      color: 'maroon',
    });
  });

  it('should return undefined if no gas is found', () => {
    const gasId = 'nonexistent';
    const gas = getGasFromId(gasId);

    expect(gas).toBeUndefined();
  });

  it('should return the gas using a path', () => {
    const gasPath = '/datum/gas/antinoblium';
    const gas = getGasFromPath(gasPath);

    expect(gas).toEqual({
      id: 'antinoblium',
      path: '/datum/gas/antinoblium',
      name: 'Antinoblium',
      label: 'Anti-Noblium',
      color: 'maroon',
    });
  });
});
