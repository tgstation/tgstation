export function getNumberColor(number: number): 'red' | 'black' {
  const inRedOddRange =
    (number >= 1 && number <= 10) || (number >= 19 && number <= 28);

  if (number % 2 === 1) {
    return inRedOddRange ? 'red' : 'black';
  }
  return inRedOddRange ? 'black' : 'red';
}
