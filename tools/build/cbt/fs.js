/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const fs = require('fs');

/**
 * Returns file stats for the provided path, or null if file is
 * not accessible.
 */
const stat = path => {
  try {
    return fs.statSync(path);
  }
  catch {
    return null;
  }
};

module.exports = {
  stat,
};
