/** Gives a color gradient based on the severity of the symptom. */
export const getColor = (severity: number) => {
  if (severity <= -10) {
    return 'blue';
  } else if (severity <= -5) {
    return 'darkturquoise';
  } else if (severity <= 0) {
    return 'green';
  } else if (severity <= 7) {
    return 'yellow';
  } else if (severity <= 13) {
    return 'orange';
  } else {
    return 'bad';
  }
};
