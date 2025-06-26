# /tg/station build script

This build script is the recommended way to compile the game, including not only the DM code but also the JavaScript and any other dependencies.

- VSCode:
  a) Press `Ctrl+Shift+B` to build.
  b) Press `F5` to build and run with debugger attached.
- Windows:
  a) Double-click `BUILD.bat` in the repository root to build (will wait for a key press before it closes).
  b) Double-click `tools/build/build.bat` to build (will exit as soon as it finishes building).
- Linux:
  a) Run `tools/build/build` from the repository root.

The script will skip build steps whose inputs have not changed since the last run.

## Getting list of available targets

You can get a list of all targets that you can build by running the following command:

```
tools/build/build --help
```

## Dependencies

- On Windows, `build.bat` will automatically install a private (vendored) copy of Node.
- On Linux, install Node using your package manager or from <https://nodejs.org/en/download/>.
- On Linux, unless using tgs4 or later you will need to compile rust-g on the server and obtain a .so file, for instructions see https://github.com/tgstation/rust-g

## Why?

We used to include compiled versions of the tgui JavaScript code in the Git repository so that the project could be compiled using BYOND only. These pre-compiled files tended to have merge conflicts for no good reason. Using a build script lets us avoid this problem, while keeping builds convenient for people who are not modifying tgui.

This build script is based on [Juke Build](https://github.com/stylemistake/juke-build) - follow the link to read the documentation for the project and understand how it works and how to contribute.

## Named byond versions

If you have byond installations in non-standard locations or want to use few versions at once for testing you can fill in `dm_versions.json` file in this directory.
Entries with "default" set to true will be used BEFORE byond installations in standard locations. Otherwise you need to pass `--dm-version={name}` to the build script to choose version you want to use.
Example dm_versions.json file:

```
[
  {
    "name": "515.1594",
    "path": "C:\\Repo\\ByondVersions\\515.1594_byond\\byond\\bin\\dm.exe",
    "default": false
  },
  {
    "name": "funny_version",
    "path": "D:\\Repo\\ByondVersions\\514.1589_byond\\byond\\bin\\dm.exe",
    "default": true
  }
]
```
