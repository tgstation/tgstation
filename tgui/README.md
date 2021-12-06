# tgui

## Introduction

tgui is a robust user interface framework of /tg/station.

tgui is very different from most UIs you will encounter in BYOND programming. It is heavily reliant on Javascript and web technologies as opposed to DM. If you are familiar with NanoUI (a library which can be found on almost every other SS13 codebase), tgui should be fairly easy to pick up.

## Learn tgui

People come to tgui from different backgrounds and with different learning styles. Whether you prefer a more theoretical or a practical approach, we hope you’ll find this section helpful.

### Practical Tutorial

If you are completely new to frontend and prefer to **learn by doing**, start with our [practical tutorial](docs/tutorial-and-examples.md).

### Guides

This project uses **Inferno** - a very fast UI rendering engine with a similar API to React. Take your time to read these guides:

- [React guide](https://reactjs.org/docs/hello-world.html)
- [Inferno documentation](https://infernojs.org/docs/guides/components) - highlights differences with React.

If you were already familiar with an older, Ractive-based tgui, and want to translate concepts between old and new tgui, read this [interface conversion guide](docs/converting-old-tgui-interfaces.md).

## Pre-requisites

If you are using the tooling provided in this repo, everything is included! Feel free to skip this step.

However, if you want finer control over the installation or build process, you will need these:

- [Node v12.20+](https://nodejs.org/en/download/)
  - **DO NOT install Chocolatey if Node installer asks you to!**
- [Yarn v1.22.4+](https://yarnpkg.com/getting-started/install)
  - You only need to run `npm install -g yarn`.

## Usage

**Via provided cmd scripts (Windows)**:

- `bin/tgui-build` - Build tgui in production mode and run a full suite of code checks.
- `bin/tgui-dev` - Launch a development server.
  - `bin/tgui-dev --reload` - Reload byond cache once.
  - `bin/tgui-dev --debug` - Run server with debug logging enabled.
  - `bin/tgui-dev --no-hot` - Disable hot module replacement (helps when doing development on IE8).
- `bin/tgui-sonar` - Analyze code with SonarQube.
- `bin/tgui-bench` - Run benchmarks.

> To open a CMD or PowerShell window in any open folder, right click **while holding Shift** on any free space in the folder, then click on either `Open command window here` or `Open PowerShell window here`.

**Via Juke Build (cross-platform)**:

- `tools/build/build tgui` - Build tgui in production mode.
- `tools/build/build tgui-dev` - Build tgui in production mode.
  - `tools/build/build tgui-dev --reload` - Reload byond cache once.
  - `tools/build/build tgui-dev --debug` - Run server with debug logging enabled.
  - `tools/build/build tgui-dev --no-hot` - Disable hot module replacement (helps when doing development on IE8).
- `tools/build/build tgui-lint` - Show (and auto-fix) problems with the code.
- `tools/build/build tgui-sonar` - Analyze code with SonarQube.
- `tools/build/build tgui-test` - Run unit and integration tests.
- `tools/build/build tgui-analyze` - Run a bundle analyzer.
- `tools/build/build tgui-bench` - Run benchmarks.
- `tools/build/build tgui-clean` - Clean up tgui folder.

> With Juke Build, you can run multiple targets together, e.g.:
> ```
> tools/build/build tgui tgui-lint tgui-tsc tgui-test
> ```

**Via Yarn (cross-platform)**:

Run `yarn install` once to install tgui dependencies.

- `yarn tgui:build` - Build tgui in production mode.
  - `yarn tgui:build [options]` - Build tgui with custom webpack options.
- `yarn tgui:dev` - Launch a development server.
  - `yarn tgui:dev --reload` - Reload byond cache once.
  - `yarn tgui:dev --debug` - Run server with debug logging enabled.
  - `yarn tgui:dev --no-hot` - Disable hot module replacement (helps when doing development on IE8).
- `yarn tgui:lint` - Show (and auto-fix) problems with the code.
- `yarn tgui:sonar` - Analyze code with SonarQube.
- `yarn tgui:tsc` - Check code with TypeScript compiler.
- `yarn tgui:test` - Run unit and integration tests.
- `yarn tgui:analyze` - Run a bundle analyzer.
- `yarn tgui:bench` - Run benchmarks.

## Important memo

Remember to always run a full build of tgui before submitting a PR, because it comes with the full suite of CI checks, and runs much faster on your computer than on GitHub servers. It will save you some time and possibly a few broken commits! Address the issues that are reported by the tooling as much as possible, because maintainers will beat you with a ruler and force you to address them anyway (unless it's a false positive or something unfixable).

## Troubleshooting

**Development server is crashing**

Make sure path to your working directory does not contain spaces, special unicode characters, exclamation marks or any other special symbols. If so, move codebase to a location which does not contain these characters.

This is a known issue with Yarn (and some other tools, like Webpack), and fix is going to happen eventually.

**Development server doesn't find my BYOND cache!**

This happens if your Documents folder in Windows has a custom location, for example in `E:\Libraries\Documents`. Development server tries its best to find this non-standard location (searches for a Windows Registry key), but it can fail. You have to run the dev server with an additional environmental variable, with a full path to BYOND cache.

```
BYOND_CACHE="E:/Libraries/Documents/BYOND/cache"
```

**Webpack errors out with some cryptic messages!**

> Example: `No template for dependency: PureExpressionDependency`

Webpack stores its cache on disk since tgui 4.3, and it is very sensitive to build configuration. So if you update webpack, or share the same cache directory between development and production build, it will start hallucinating.

To fix this kind of problem, run `bin/tgui --clean` and try again.

## Developer Tools

When developing with `tgui-dev-server`, you will have access to certain development only features.

**Debug Logs**. When running server via `bin/tgui --dev --debug`, server will print debug logs and time spent on rendering. Use this information to optimize your code, and try to keep re-renders below 16ms.

**Kitchen Sink**. Press `F12` to open the KitchenSink interface. This interface is a playground to test various tgui components.

**Layout Debugger**. Press `F11` to toggle the *layout debugger*. It will show outlines of all tgui elements, which makes it easy to understand how everything comes together, and can reveal certain layout bugs which are not normally visible.

## Project Structure

- `/packages` - Each folder here represents a self-contained Node module.
- `/packages/common` - Helper functions that are used throughout all packages.
- `/packages/tgui/index.js` - Application entry point.
- `/packages/tgui/components` - Basic UI building blocks.
- `/packages/tgui/interfaces` - Actual in-game interfaces.
- `/packages/tgui/layouts` - Root level UI components, that affect the final look and feel of the browser window. These hold various window elements, like the titlebar and resize handlers, and control the UI theme.
- `/packages/tgui/routes.js` - This is where tgui decides which interface to pull and render.
- `/packages/tgui/styles/main.scss` - CSS entry point.
- `/packages/tgui/styles/functions.scss` - Useful SASS functions. Stuff like `lighten`, `darken`, `luminance` are defined here.
- `/packages/tgui/styles/atomic` - Atomic CSS classes. These are very simple, tiny, reusable CSS classes which you can use and combine to change appearance of your elements. Keep them small.
- `/packages/tgui/styles/components` - CSS classes which are used in UI components. These stylesheets closely follow the [BEM](https://en.bem.info/methodology/) methodology.
- `/packages/tgui/styles/interfaces` - Custom stylesheets for your interfaces. Add stylesheets here if you really need a fine control over your UI styles.
- `/packages/tgui/styles/layouts` - Layout-related styles.
- `/packages/tgui/styles/themes` - Contains themes that you can use in tgui. Each theme must be registered in `/packages/tgui/index.js` file.

## Component Reference

See: [Component Reference](docs/component-reference.md).

## License

Source code is covered by /tg/station's parent license - **AGPL-3.0** (see the main [README](../README.md)), unless otherwise indicated.

Some files are annotated with a copyright header, which explicitly states the copyright holder and license of the file. Most of the core tgui source code is available under the **MIT** license.

The Authors retain all copyright to their respective work here submitted.
