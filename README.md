## Skyraptor Station - A furry, roleplay-oriented TG-SS13 fork

[![Build Status](https://github.com/Bird-Lounge/Skyraptor-SS13/workflows/CI%20Suite/badge.svg)](https://github.com/Bird-Lounge/Skyraptor-SS13/actions?query=workflow%3A%22CI+Suite%22)
[![Percentage of issues still open](https://isitmaintained.com/badge/open/Bird-Lounge/Skyraptor-SS13.svg)](https://isitmaintained.com/project/Bird-Lounge/Skyraptor-SS13 "Percentage of issues still open")
[![Average time to resolve an issue](https://isitmaintained.com/badge/resolution/Bird-Lounge/Skyraptor-SS13.svg)](https://isitmaintained.com/project/Bird-Lounge/Skyraptor-SS13 "Average time to resolve an issue")
![Coverage](https://img.shields.io/badge/coverage---4%25-red.svg)

[![resentment](.github/images/badges/built-with-resentment.svg)](.github/images/comics/131-bug-free.png) [![technical debt](.github/images/badges/contains-technical-debt.svg)](.github/images/comics/106-tech-debt-modified.png) [![forinfinityandbyond](.github/images/badges/made-in-byond.gif)](https://www.reddit.com/r/SS13/comments/5oplxp/what_is_the_main_problem_with_byond_as_an_engine/dclbu1a)

* **Website:** N/A
* **Code:** https://github.com/Bird-Lounge/Skyraptor-SS13
* **Wiki:** N/A
* **Codedocs:** N/A
* **/tg/station Discord:** N/A
* **Coderbus Discord:** N/A

This is the codebase for a nightmare amalgamation built on top of the original /tg/station flavoured fork of SpaceStation 13.

Space Station 13 is a paranoia-laden round-based roleplaying game set against the backdrop of a nonsensical, metal death trap masquerading as a corporate space station, with charming spritework designed to represent the sci-fi setting and its dangerous undertones.  Skyraptor Station is built on the basic SS13 formula, but tweaked for a more character-focused, roleplay-centric experience where stories can develop from round-to-round, all whilst still recognizing the tongue-in-cheek insanity of SS13 and being willing to poke fun at the Gods and their Fourth Wall from time to time.

## DOWNLOADING
[Downloading](.github/guides/DOWNLOADING.md)

[Running on the server](.github/guides/RUNNING_A_SERVER.md)

[Maps and Away Missions](.github/guides/MAPS_AND_AWAY_MISSIONS.md)

## :exclamation: How to compile :exclamation:

On **2021-01-04** we have changed the way to compile the codebase.

**The quick way**. Find `bin/server.cmd` in this folder and double click it to automatically build and host the server on port 1337.

**The long way**. Find `bin/build.cmd` in this folder, and double click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile. If it closes, it means it has finished its job. You can then [setup the server](.github/guides/RUNNING_A_SERVER.md) normally by opening `tgstation.dmb` in DreamDaemon.

**Building tgstation in DreamMaker directly is now deprecated and might produce errors**, such as `'tgui.bundle.js': cannot find file`.

**[How to compile in VSCode and other build options](tools/build/README.md).**

## Contributors
[Guides for Contributors](.github/CONTRIBUTING.md)

[/tg/station HACKMD account](https://hackmd.io/@tgstation) - Design documentation here

[Interested in some starting lore?](https://github.com/tgstation/common_core)

## LICENSE
With thanks & apologies to:
 - [Skyrat Station](https://github.com/Skyrat-SS13/Skyrat-tg) for inspiration & inspiration for our tongue-in-cheek name, as well as a handful of sprites.
 - [Daedalus Dock](https://github.com/DaedalusDock/daedalusdock) for being goals & reference during implementation of systems like Goonstam.
 - [Goonstation](https://github.com/goonstation/goonstation) for its kick-ass stamina mechanics and a handful of assets.
 - [Shiptest](https://github.com/shiptest-ss13/Shiptest) for its beaker revamp, and proof SS13 mechanics can work very well for space exploration instead of stationside drama.

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE and GPLv3.txt for more details.

The TGS DMAPI is licensed as a subproject under the MIT license.

See the footer of [code/__DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
