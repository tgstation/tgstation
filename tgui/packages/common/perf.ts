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
const hpMarkersByName: Record<string, number> = {};
// Low precision markers
const lpMarkersByName: Record<string, number> = {};

/**
 * Marks a certain spot in the code for later measurements.
 */
function mark(name: string, timestamp?: number): void {
  if (process.env.NODE_ENV !== 'production') {
    if (supportsPerf && !timestamp) {
      hpMarkersByName[name] = performance.now();
    }
    lpMarkersByName[name] = timestamp || Date.now();
  }
}

/**
 * Calculates and returns the difference between two markers as a string.
 *
 * Use logger.log() to print the measurement.
 */
function measure(markerNameA: string, markerNameB: string): string | undefined {
  if (process.env.NODE_ENV === 'production') return;

  let markerA = hpMarkersByName[markerNameA];
  let markerB = hpMarkersByName[markerNameB];

  if (!markerA || !markerB) {
    markerA = lpMarkersByName[markerNameA];
    markerB = lpMarkersByName[markerNameB];
  }

  const duration = Math.abs(markerB - markerA);

  return formatDuration(duration);
}

/**
 * Formats a duration in milliseconds and frames.
 */
function formatDuration(duration: number): string {
  const durationInFrames = duration / FRAME_DURATION;

  return (
    duration.toFixed(duration < 10 ? 1 : 0) +
    'ms ' +
    '(' +
    durationInFrames.toFixed(2) +
    ' frames)'
  );
}

export const perf = {
  mark,
  measure,
};
