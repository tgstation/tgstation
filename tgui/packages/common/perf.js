/**
 * Ghetto performance measurement tools.
 *
 * Uses NODE_ENV to remove itself from production builds.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const FPS = 60;
const FRAME_DURATION = 1000 / FPS;

// True if Performance API is supported
const supportsPerf = !!window.performance?.now;
// High precision markers
let hpMarkersByName = {};
// Low precision markers
let lpMarkersByName = {};

/**
 * Marks a certain spot in the code for later measurements.
 */
const mark = (name, timestamp) => {
  if (process.env.NODE_ENV !== 'production') {
    if (supportsPerf && !timestamp) {
      hpMarkersByName[name] = performance.now();
    }
    lpMarkersByName[name] = timestamp || Date.now();
  }
};

/**
 * Calculates and returns the difference between two markers as a string.
 *
 * Use logger.log() to print the measurement.
 */
const measure = (markerNameA, markerNameB) => {
  if (process.env.NODE_ENV !== 'production') {
    let markerA = hpMarkersByName[markerNameA];
    let markerB = hpMarkersByName[markerNameB];
    if (!markerA || !markerB) {
      markerA = lpMarkersByName[markerNameA];
      markerB = lpMarkersByName[markerNameB];
    }
    const duration = Math.abs(markerB - markerA);
    return formatDuration(duration);
  }
};

const formatDuration = duration => {
  const durationInFrames = duration / FRAME_DURATION;
  return duration.toFixed(duration < 10 ? 1 : 0) + 'ms '
    + '(' + durationInFrames.toFixed(2) + ' frames)';
};

export const perf = {
  mark,
  measure,
};
