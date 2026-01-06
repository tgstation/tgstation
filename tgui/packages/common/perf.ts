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

const supportsUserTiming =
  typeof globalThis.performance?.mark === 'function' &&
  typeof globalThis.performance?.measure === 'function' &&
  typeof globalThis.performance?.getEntriesByName === 'function' &&
  typeof globalThis.performance?.clearMarks === 'function' &&
  typeof globalThis.performance?.clearMeasures === 'function';

// Internal fallback markers (also used for log formatting).
const markersByName: Record<string, number> = {};

const now = (): number =>
  typeof globalThis.performance?.now === 'function' ? performance.now() : Date.now();

/**
 * Marks a certain spot in the code for later measurements.
 */
function mark(name: string, timestamp?: number): void {
  if (process.env.NODE_ENV !== 'production') {
    // Always keep our own marker so `perf.measure()` can return a formatted string.
    markersByName[name] = timestamp ?? now();

    // Also emit a real User Timing mark so it shows up in Chromium DevTools.
    if (supportsUserTiming) {
      try {
        // Keep only the most recent mark with this name.
        performance.clearMarks(name);
        performance.mark(name);
      } catch {
        // Ignore User Timing errors (e.g. invalid name constraints).
      }
    }
  }
}

/**
 * Calculates and returns the difference between two markers as a string.
 *
 * Use logger.log() to print the measurement.
 */
function measure(markerNameA: string, markerNameB: string): string | undefined {
  if (process.env.NODE_ENV === 'production') return;

  if (supportsUserTiming) {
    const measureName = `${markerNameA}→${markerNameB}`;
    try {
      performance.clearMeasures(measureName);
      performance.measure(measureName, markerNameA, markerNameB);

      const entries = performance.getEntriesByName(measureName, 'measure');
      const entry = entries[entries.length - 1];
      if (entry) {
        return formatDuration(entry.duration);
      }
    } catch {
      // Ignore if marks don't exist in User Timing; internal fallback still works.
    }
  }

  const markerA = markersByName[markerNameA];
  const markerB = markersByName[markerNameB];

  if (markerA === undefined || markerB === undefined) return;

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
