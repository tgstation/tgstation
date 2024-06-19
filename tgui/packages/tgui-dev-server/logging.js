/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const inception = Date.now();

// Runtime detection
const isNode = process && process.release && process.release.name === 'node';
let isChrome = false;
try {
  isChrome = window.navigator.userAgent.toLowerCase().includes('chrome');
} catch {}

// Timestamping function
const getTimestamp = () => {
  const timestamp = String(Date.now() - inception)
    .padStart(4, '0')
    .padStart(7, ' ');
  const seconds = timestamp.substr(0, timestamp.length - 3);
  const millis = timestamp.substr(-3);
  return `${seconds}.${millis}`;
};

const getPrefix = (() => {
  if (isNode) {
    // Escape sequences
    const ESC = {
      dimmed: '\x1b[38;5;240m',
      bright: '\x1b[37;1m',
      reset: '\x1b[0m',
    };
    return (ns) => [
      `${ESC.dimmed}${getTimestamp()} ${ESC.bright}${ns}${ESC.reset}`,
    ];
  }
  if (isChrome) {
    // Styles
    const styles = {
      dimmed: 'color: #888',
      bright: 'font-weight: bold',
    };
    return (ns) => [
      `%c${getTimestamp()}%c ${ns}`,
      styles.dimmed,
      styles.bright,
    ];
  }
  // prettier-ignore
  return ns => [
    `${getTimestamp()} ${ns}`,
  ];
})();

/**
 * Creates a logger object.
 */
export const createLogger = (ns) => ({
  log: (...args) => console.log(...getPrefix(ns), ...args),
  trace: (...args) => console.trace(...getPrefix(ns), ...args),
  debug: (...args) => console.debug(...getPrefix(ns), ...args),
  info: (...args) => console.info(...getPrefix(ns), ...args),
  warn: (...args) => console.warn(...getPrefix(ns), ...args),
  error: (...args) => console.error(...getPrefix(ns), ...args),
});

/**
 * Explicitly log with chosen namespace.
 */
export const directLog = (ns, ...args) =>
  console.log(...getPrefix(ns), ...args);
