# tgui-next

## Pre-requisites

- [Node 12.x](https://nodejs.org)
- [Yarn](https://yarnpkg.com)
- [MSys2](https://www.msys2.org/) (optional)

## Workflow

For MSys2 users:

- `./build.sh --dev` - launch a dev server
- `./build.sh --mode=production` - produce production bundles

For everyone else:

Run `yarn install`, then:

- `yarn run watch` - launch a dev server
- `yarn run build` - produce production bundles
