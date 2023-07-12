import { shuffleByProp } from './array';

describe('shuffleByProp', () => {
  it('keeps elements with the same property value together', () => {
    let initial = [
      { name: 'test', difficulty: 1 },
      { name: 'test2', difficulty: 2 },
      { name: 'test3', difficulty: 1 },
      { name: 'test4', difficulty: 2 },
    ];

    let result = shuffleByProp(initial, 'difficulty');

    // Check if all elements with difficulty 1 are together
    let indices1 = result.reduce(
      (acc: number[], cur: any, i: number) =>
        cur.difficulty === 1 ? acc.concat(i) : acc,
      []
    );
    expect(indices1[0] + 1).toEqual(indices1[1]);

    // Check if all elements with difficulty 2 are together
    let indices2 = result.reduce(
      (acc: number[], cur: any, i: number) =>
        cur.difficulty === 2 ? acc.concat(i) : acc,
      []
    );
    expect(indices2[0] + 1).toEqual(indices2[1]);
  });

  it('returns an empty array if the property does not exist', () => {
    let initial = [
      { name: 'test', difficulty: 1 },
      { name: 'test2', difficulty: 2 },
      { name: 'test3', difficulty: 1 },
      { name: 'test4', difficulty: 2 },
    ];

    let result = shuffleByProp(initial, 'nonexistent');
    expect(result).toEqual([]);
  });

  it('returns an empty array if the input array is empty', () => {
    let initial: any[] = [];

    let result = shuffleByProp(initial, 'difficulty');
    expect(result).toEqual([]);
  });
});
