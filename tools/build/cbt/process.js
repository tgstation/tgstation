/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { spawn } = require('child_process');
const { resolve: resolvePath } = require('path');
const { stat } = require('./fs');

/**
 * @type {import('child_process').ChildProcessWithoutNullStreams}
 */
const children = new Set();

const killChildren = () => {
  for (const child of children) {
    child.kill('SIGTERM');
    children.delete(child);
    console.log('killed child process');
  }
};

const trap = (signals, handler) => {
  let readline;
  if (process.platform === 'win32') {
    readline = require('readline').createInterface({
      input: process.stdin,
      output: process.stdout,
    });
  }
  for (const signal of signals) {
    const handleSignal = () => handler(signal);
    if (signal === 'EXIT') {
      process.on('exit', handleSignal);
      continue;
    }
    if (readline) {
      readline.on('SIG' + signal, handleSignal);
    }
    process.on('SIG' + signal, handleSignal);
  }
};

trap(['EXIT', 'BREAK', 'HUP', 'INT', 'TERM'], signal => {
  if (signal !== 'EXIT') {
    console.log('Received', signal);
  }
  killChildren();
  if (signal !== 'EXIT') {
    process.exit(1);
  }
});

const exceptionHandler = err => {
  console.log(err);
  killChildren();
  process.exit(1);
};

process.on('unhandledRejection', exceptionHandler);
process.on('uncaughtException', exceptionHandler);

class ExitError extends Error {}

/**
 * @param {string} executable
 * @param {string[]} args
 * @param {import('child_process').SpawnOptionsWithoutStdio} options
 */
const exec = (executable, args, options) => {
  return new Promise((resolve, reject) => {
    // If executable exists relative to the current directory,
    // use that executable, otherwise spawn should fall back to
    // running it from PATH.
    if (stat(executable)) {
      executable = resolvePath(executable);
    }
    const child = spawn(executable, args, options);
    children.add(child);
    child.stdout.pipe(process.stdout, { end: false });
    child.stderr.pipe(process.stderr, { end: false });
    child.stdin.end();
    child.on('error', err => reject(err));
    child.on('exit', code => {
      children.delete(child);
      if (code !== 0) {
        const error = new ExitError('Process exited with code: ' + code);
        error.code = code;
        reject(error);
      }
      else {
        resolve(code);
      }
    });
  });
};

module.exports = {
  exec,
  ExitError,
};
