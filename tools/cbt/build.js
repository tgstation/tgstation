#!/usr/bin/env node
const { Task, Flags, Effects, Commands } = require('./cbt');
const { depends, provides, build } = Effects;
const { exec } = Commands;

const taskTgui = Task('tgui', [
  depends(Flags.GLOB, 'tgui/.yarn/releases/*'),
  depends(Flags.FILE, 'tgui/yarn.lock'),
  depends(Flags.FILE, 'tgui/package.json'),
  depends(Flags.GLOB, 'tgui/packages/**/*.js'),
  provides(Flags.GLOB, 'tgui/public/*.bundle.*'),
  provides(Flags.GLOB, 'tgui/public/*.chunk.*'),
  build(async () => {
    await exec('powershell.exe',
      '-NoLogo', '-ExecutionPolicy', 'Bypass',
      '-File', 'tgui/bin/tgui.ps1');
  }),
]);

const taskDm = Task('dm', [
  build(async () => {
    await exec('dm.exe', 'tgstation.dme');
  }),
]);

const runTasks = async () => {
  await taskTgui.run();
  await taskDm.run();
  process.exit();
};

runTasks();
