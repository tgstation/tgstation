/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const { compareFiles, Flags } = require('./fs');

class Task {
  constructor(name) {
    this.name = name;
    this.deps = [];
    this.script = null;
  }

  depends(path) {
    // Hardcoded GLOB here for simplicity, auto-detection would be nice.
    const flags = Flags.SOURCE | Flags.GLOB;
    this.deps.push({ path, flags });
    return this;
  }

  provides(path) {
    const flags = Flags.TARGET | Flags.GLOB;
    this.deps.push({ path, flags });
    return this;
  }

  build(script) {
    this.script = script;
    return this;
  }

  async run() {
    // Consider dependencies first, and skip the task if it
    // doesn't need a rebuild.
    if (this.deps.length > 0) {
      const needsRebuild = compareFiles(this.deps);
      if (!needsRebuild) {
        console.warn(` => Skipping '${this.name}'`);
        return;
      }
    }
    if (!this.script) {
      return;
    }
    console.warn(` => Starting '${this.name}'`);
    const startedAt = Date.now();
    await this.script();
    const time = ((Date.now() - startedAt) / 1000) + 's';
    console.warn(` => Finished '${this.name}' in ${time}`);
  }
}

const runTasks = async tasks => {
  // Run all if at least one of the tasks was specified.
  const runAll = tasks.some(task => process.argv.includes(task));
  for (const task of tasks) {
    if (!runAll && process.argv.includes(task.name)) {
      await task.run();
    }
  }
  console.log(' => Done');
  process.exit();
};

module.exports = {
  Task,
  runTasks,
};
