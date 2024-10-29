## MassMeta (/tg/station Downstream)

[![Build Status](https://github.com/Huz2e/massmeta/workflows/CI%20Suite/badge.svg)](https://github.com/Huz2e/massmeta/actions?query=workflow%3A%22CI+Suite%22)
[![Percentage of issues still open](https://isitmaintained.com/badge/open/Huz2e/massmeta.svg)](https://isitmaintained.com/project/Huz2e/massmeta "Percentage of issues still open")
[![Average time to resolve an issue](https://isitmaintained.com/badge/resolution/Huz2e/massmeta.svg)](https://isitmaintained.com/project/Huz2e/massmeta "Average time to resolve an issue")

[![resentment](.github/images/badges/built-with-resentment.svg)](.github/images/comics/131-bug-free.png) [![technical debt](.github/images/badges/contains-technical-debt.svg)](.github/images/comics/106-tech-debt-modified.png) [![forinfinityandbyond](.github/images/badges/made-in-byond.gif)](https://www.reddit.com/r/SS13/comments/5oplxp/what_is_the_main_problem_with_byond_as_an_engine/dclbu1a)

| Website                   | Link                                                                      |
|---------------------------|---------------------------------------------------------------------------|
| MassMeta Code             | [https://github.com/Huz2e/massmeta](https://github.com/Huz2e/massmeta)    |
| Guide to Modularization   | [./modular_meta/modularization_guide_ru.md](./massmeta/modularization_guide.md)  |
| MassMeta Discord          | [https://discord.gg/massmeta](https://discord.gg/Pp7SpQgvNt)              |
| MassMeta Wiki             | [https://massmeta.ru](https://massmeta.ru/index.php/Заглавная_страница) |
| /TG/ Website              | [https://www.tgstation13.org](https://www.tgstation13.org)                |
| /TG/ Codedocs             | [https://codedocs.tgstation13.org/](https://codedocs.tgstation13.org/)    |
| /TG/ Coderbus Discord     | [https://discord.gg/Vh8TJp9](https://discord.gg/Vh8TJp9)                  |

This is MassMeta downstream fork of /tg/station SpaceStation 13.

**This is Kvass-Based repository, mmmmmm Kvass.**

Space Station 13 is a paranoia-laden round-based roleplaying game set against the backdrop of a nonsensical, metal death trap masquerading as a space station, with charming spritework designed to represent the sci-fi setting and its dangerous undertones. Have fun, and survive!

## DOWNLOADING
[Downloading](.github/guides/DOWNLOADING.md)

[Running a server](.github/guides/RUNNING_A_SERVER.md)

[Maps and Away Missions](.github/guides/MAPS_AND_AWAY_MISSIONS.md)

## Compilation

**The quick way**. Find `bin/server.cmd` in this folder and double click it to automatically build and host the server on port 1337.

**The long way**. Find `bin/build.cmd` in this folder, and double click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile. If it closes, it means it has finished its job. You can then [setup the server](.github/guides/RUNNING_A_SERVER.md) normally by opening `tgstation.dmb` in DreamDaemon.

**Building tgstation in DreamMaker directly is deprecated and might produce errors**, such as `'tgui.bundle.js': cannot find file`.

**[How to compile in VSCode and other build options](tools/build/README.md).**

## Contributors
[Guides for Contributors](.github/CONTRIBUTING.md)

**Если вы хотите, чтобы ваша фича попала в репозиторий на показ игрокам, то велком в `#Code-chat` в [нашем Дискорде](https://discord.gg/Pp7SpQgvNt).**

[/tg/station HACKMD account (BLOCKED in RU)](https://hackmd.io/@tgstation) - Design documentation here

## LICENSE

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE and GPLv3.txt for more details.

The TGS DMAPI is licensed as a subproject under the MIT license.

See the footer of [code/__DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
