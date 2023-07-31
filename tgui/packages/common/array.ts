const propInObject = (
  prop: string | number | symbol,
  obj: Record<string, unknown>
): prop is keyof typeof obj => {
  return prop in obj;
};

// shuffle helper function
const shuffle = <T>(array: T[]): T[] => {
  let currentIndex = array.length;
  let randomIndex: number;

  while (0 !== currentIndex) {
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex--;

    [array[currentIndex], array[randomIndex]] = [
      array[randomIndex],
      array[currentIndex],
    ];
  }

  return array;
};

/**
 * ### shuffleByProp
 * Sorts elements by a property, then shuffles each group
 * Used to make pseudo-random lists, while keeping them grouped by a property
 */
export const shuffleByProp = <T extends Record<string, any>>(
  arr: T[],
  prop: string
): any[] => {
  let grouped: { [key: number]: any[] } = {};

  // Group elements by prop
  arr.forEach((element) => {
    if (!propInObject(prop, element)) {
      return [];
    }
    if (!grouped[element[prop]]) {
      grouped[element[prop]] = [];
    }

    grouped[element[prop]].push(element);
  });

  // Shuffle each group
  for (let key in grouped) {
    grouped[key] = shuffle(grouped[key]);
  }

  // Flatten the array back
  return ([] as any[]).concat(...Object.values(grouped));
};
