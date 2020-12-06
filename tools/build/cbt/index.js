/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { Task, runTasks } = require('./task');
const { stat } = require('./fs');
const { exec } = require('./process');
const { regQuery } = require('./winreg');

module.exports = {
  Task,
  runTasks,
  stat,
  exec,
  regQuery,
};
