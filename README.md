# monkestation codebase

[![Build Status](https://github.com/monkestation/monkestation2.0/workflows/CI%20Suite/badge.svg)](https://github.com/monkestation/monkestation2.0/actions?query=workflow%3A%22CI+Suite%22)
[![Percentage of issues still open](https://isitmaintained.com/badge/open/monkestation/monkestation2.0.svg)](https://isitmaintained.com/project/monkestation/monkestation2.0 "Percentage of issues still open")
[![Average time to resolve an issue](https://isitmaintained.com/badge/resolution/monkestation/monkestation2.0.svg)](https://isitmaintained.com/project/monkestation/monkestation2.0 "Average time to resolve an issue")
![Coverage](https://img.shields.io/badge/coverage---3%25-red.svg)

[![forthebadge](monkestation/badges/fueled-by-potassium.svg)](https://forthebadge.com) [![resentment](https://forthebadge.com/images/badges/built-with-resentment.svg)](https://www.monkeyuser.com/assets/images/2019/131-bug-free.png) [![resentment](https://forthebadge.com/images/badges/contains-technical-debt.svg)](https://user-images.githubusercontent.com/8171642/50290880-ffef5500-043a-11e9-8270-a2e5b697c86c.png) [![forinfinityandbyond](https://user-images.githubusercontent.com/5211576/29499758-4efff304-85e6-11e7-8267-62919c3688a9.gif)](https://www.reddit.com/r/SS13/comments/5oplxp/what_is_the_main_problem_with_byond_as_an_engine/dclbu1a)

| Website                 | Link                                           |
|-------------------------|------------------------------------------------|
| Website                 | [https://monkestation.com/](https://monkestation.com/) |
| Code                    | [https://github.com/Monkestation/Monkestation2.0](https://github.com/Monkestation/Monkestation2.0) |
| Wiki                    | [https://wiki.monkestation.com/](https://wiki.monkestation.com/) |
| Codedocs                | [https://codedocs.tgstation13.org/](https://codedocs.tgstation13.org/) |
| monkestation Discord    | [https://discord.com/invite/monkestation](https://discord.com/invite/monkestation) |

This is the codebase for the monkestation-flavored fork of Space Station 13.

Space Station 13 is a paranoia-laden, round-based roleplaying game set against the backdrop of a nonsensical, metal death trap masquerading as a space station, with charming spritework designed to represent the sci-fi setting and its dangerous undertones. Have fun, and survive!

## DOWNLOADING

[Downloading](.github/guides/DOWNLOADING.md)

[Running on the server](.github/guides/RUNNING_A_SERVER.md)

[Maps and Away Missions](.github/guides/MAPS_AND_AWAY_MISSIONS.md)

## :exclamation: How to compile :exclamation:

On **2021-01-04** we changed the way to compile the codebase.

**The quick way**. Find `bin/server.cmd` in this folder and double-click it to automatically build and host the server on port 1337.

**The long way**. Find `bin/build.cmd` in this folder, and double-click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile. If it closes, it means it has finished its job. You can then [setup the server](.github/guides/RUNNING_A_SERVER.md) normally by opening `tgstation.dmb` in DreamDaemon.

**Building tgstation in DreamMaker directly is now deprecated and might produce errors**, such as `'tgui.bundle.js': cannot find file`.

**[How to compile in VSCode and other build options](tools/build/README.md).**

## Contributors

[Guides for Contributors](.github/CONTRIBUTING.md)

[/tg/station HACKMD account](https://hackmd.io/@tgstation) - Design documentation here

[Interested in some starting lore?](https://github.com/tgstation/common_core)

## LICENSE

[![license-badge](https://www.gnu.org/graphics/agplv3-155x51.png)](https://www.gnu.org/licenses/agpl-3.0.html)

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014-12-31 at 16:38 PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

---

[![license-badge](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.html)

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014-12-31 at 16:38 PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See [LICENSE](LICENSE) and [GPLv3.txt](GPLv3.txt) for more details.

---

[![forthebadge](https://forthebadge.com/images/badges/license-mit.svg)](https://forthebadge.com)

The TGS DMAPI is licensed as a subproject under the MIT license.

See the footer of [code/__DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

---

[![forthebadge](https://forthebadge.com/images/badges/cc-by-sa.svg)](https://forthebadge.com)

All assets, including icons and sound, are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
