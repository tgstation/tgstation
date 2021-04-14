# /tg/station build script

This build script is the recommended way to compile the game, including not only the DM code but also the JavaScript and any other dependencies.

- VSCode: use `Ctrl+Shift+B` to build or `F5` to build and run.

- Windows: double-click `Build.bat` in the repository root to build.

- Linux: run `tools/build/build` from the repository root.

The script will skip build steps whose inputs have not changed since the last run.

## Dependencies

- On Windows, `Build.bat` will automatically install a private copy of Node.

- On Linux, install Node using your package manager or from <https://nodejs.org/en/download/>.

## Why?

We used to include compiled versions of the tgui JavaScript code in the Git repository so that the project could be compiled using BYOND only. These pre-compiled files tended to have merge conflicts for no good reason. Using a build script lets us avoid this problem, while keeping builds convenient for people who are not modifying tgui.
