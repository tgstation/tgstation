import { describe, it } from 'vitest';

import { chain, range, wrap, zip } from './collections';

// Type assertions, these will lint if the types are wrong.
const _zip1: [string, number] = zip(['a'], [1])[0];

describe('range', () => {
  it('range(0, 5)', ({ expect }) => {
    expect(range(0, 5)).toEqual([0, 1, 2, 3, 4]);
  });
});

describe('zip', () => {
  it("zip(['a', 'b', 'c'], [1, 2, 3, 4])", ({ expect }) => {
    expect(zip(['a', 'b', 'c'], [1, 2, 3, 4])).toEqual([
      ['a', 1],
      ['b', 2],
      ['c', 3],
    ]);
  });
});

describe('wrap', () => {
  it('wrap(1)', ({ expect }) => {
    expect(wrap(1).unwrap()).toEqual(1);
  });
});

describe('chain', () => {
  it('chain([1, 2])', ({ expect }) => {
    expect(chain([1, 2]).unwrap()).toEqual([1, 2]);
  });
});

describe('wrap.if', () => {
  it('if(false, x => x + 1)', ({ expect }) => {
    expect(
      wrap(1)
        .if(false, (x) => x.map((x) => x + 1))
        .unwrap(),
    ).toEqual(1);
  });
  it('if(true, x => x + 1)', ({ expect }) => {
    expect(
      wrap(1)
        .if(true, (x) => x.map((x) => x + 1))
        .unwrap(),
    ).toEqual(2);
  });
  it('if(false, x => x + 1, x => x + 2)', ({ expect }) => {
    expect(
      wrap(1)
        .if(
          false,
          (x) => x.map((x) => x + 1),
          (x) => x.map((x) => x + 2),
        )
        .unwrap(),
    ).toEqual(3);
  });
  it('if(true, x => x + 1, x => x + 2)', ({ expect }) => {
    expect(
      wrap(1)
        .if(
          true,
          (x) => x.map((x) => x + 1),
          (x) => x.map((x) => x + 2),
        )
        .unwrap(),
    ).toEqual(2);
  });
});

describe('wrap.ifMap', () => {
  it('ifMap(false, x => x + 1)', ({ expect }) => {
    expect(
      wrap(1)
        .ifMap(false, (x) => x + 1)
        .unwrap(),
    ).toEqual(1);
  });
  it('ifMap(true, x => x + 1)', ({ expect }) => {
    expect(
      wrap(1)
        .ifMap(true, (x) => x + 1)
        .unwrap(),
    ).toEqual(2);
  });
  it('ifMap(false, x => x + 1, x => x + 2)', ({ expect }) => {
    expect(
      wrap(1)
        .ifMap(
          false,
          (x) => x + 1,
          (x) => x + 2,
        )
        .unwrap(),
    ).toEqual(3);
  });
  it('ifMap(true, x => x + 1, x => x + 2)', ({ expect }) => {
    expect(
      wrap(1)
        .ifMap(
          true,
          (x) => x + 1,
          (x) => x + 2,
        )
        .unwrap(),
    ).toEqual(2);
  });
});

describe('chain.if', () => {
  it('if(false, x => x.map(x => x + 1))', ({ expect }) => {
    expect(
      chain([1, 2, 3])
        .if(false, (x) => x.map((x) => x + 1))
        .unwrap(),
    ).toEqual([1, 2, 3]);
  });
  it('if(true, x => x.map(x => x + 1))', ({ expect }) => {
    expect(
      chain([1, 2, 3])
        .if(true, (x) => x.map((x) => x + 1))
        .unwrap(),
    ).toEqual([2, 3, 4]);
  });
  it('if(false, x => x.map(x => x + 1), x => x.map(x => x + 2))', ({
    expect,
  }) => {
    expect(
      chain([1, 2, 3])
        .if(
          false,
          (x) => x.map((x) => x + 1),
          (x) => x.map((x) => x + 2),
        )
        .unwrap(),
    ).toEqual([3, 4, 5]);
  });
  it('if(true, x => x.map(x => x + 1), x => x.map(x => x + 2))', ({
    expect,
  }) => {
    expect(
      chain([1, 2, 3])
        .if(
          true,
          (x) => x.map((x) => x + 1),
          (x) => x.map((x) => x + 2),
        )
        .unwrap(),
    ).toEqual([2, 3, 4]);
  });
});

describe('Enumerable<T>.mapArray', () => {
  it('mapArray(x => x.reverse())', ({ expect }) => {
    expect(
      chain([1, 2, 3, 4, 5])
        .mapArray((x) => x.reverse())
        .unwrap(),
    ).toEqual([5, 4, 3, 2, 1]);
  });
  it("mapArray(x => x.join(' '))", ({ expect }) => {
    expect(
      chain([1, 2, 3, 4, 5])
        .mapArray((x) => x.join(' '))
        .unwrap(),
    ).toEqual('1 2 3 4 5');
  });
});

describe('Enumerable<T>.paginate', () => {
  it('paginate(3)', ({ expect }) => {
    expect(
      chain([1, 2, 3, 4, 5, 6, 7, 8, 9])
        .paginate(3)
        .map((x) => x.unwrap())
        .unwrap(),
    ).toEqual([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ]);
  });
});
