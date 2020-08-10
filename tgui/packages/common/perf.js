/**
 * Ghetto performance measurement tools.
 *
 * Uses NODE_ENV to redact itself from production bundles.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

let markersByLabel = {};

/**
 * Marks a certain spot in the code for later measurements.
 */
const mark = (label, timestamp) => {
  if (process.env.NODE_ENV !== 'production') {
    markersByLabel[label] = timestamp || Date.now();
  }
};

/**
 * Calculates and returns the difference between two markers as a string.
 *
 * Use logger.log() to print the measurement.
 */
const measure = (markerA, markerB) => {
  if (process.env.NODE_ENV !== 'production') {
    return timeDiff(
      markersByLabel[markerA],
      markersByLabel[markerB]);
  }
};

const timeDiff = (startedAt, finishedAt) => {
  const diff = Math.abs(finishedAt - startedAt);
  const diffFrames = (diff / 16.6667).toFixed(2);
  return `${diff}ms (${diffFrames} frames)`;
};

export const perf = {
  mark,
  measure,
};
