/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { Task } = require('./task');
const { stat } = require('./fs');
const { exec } = require('./process');

module.exports = {
  Task,
  stat,
  exec,
};
