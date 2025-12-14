## MAPS

/tg/station currently has six station maps in rotation.

- [CatwalkStation](https://tgstation13.org/wiki/CatwalkStation)
- [DeltaStation](https://tgstation13.org/wiki/DeltaStation)
- [IceBoxStation](https://tgstation13.org/wiki/IceboxStation)
- [MetaStation](https://tgstation13.org/wiki/MetaStation)
- [NebulaStation](https://tgstation13.org/wiki/NebulaStation)
- [TramStation](https://tgstation13.org/wiki/Tramstation)
- [WawaStation](https://tgstation13.org/wiki/WawaStation)

Debug station maps.

- [RuntimeStation](https://tgstation13.org/wiki/RuntimeStation)
- [MultiZ](https://tgstation13.org/wiki/MultiZ)

All maps have their own code file that is in the base of the `_maps` directory, or elsewhere in the codebase. For example, all of the station maps in rotation each have a corresponding JSON file and are loaded using the server's [configuration](#configuration) passed onto the Mapping subsystem. Maps are loaded dynamically when the game starts. Follow this guideline when adding your own map, to your fork, for easy compatibility.

The map that will be loaded for the upcoming round is determined by reading `data/next_map.json`, which is a copy of the JSON files found in the `_maps` tree. If this file does not exist, the default map from `config/maps.txt` will be loaded. Failing that, MetaStation will be loaded. If you want to set a specific map to load next round you can use the Change Map verb in game before restarting the server or copy a JSON from `_maps` to `data/next_map.json` before starting the server. Also, for debugging purposes, ticking a corresponding map's code file in Dream Maker will force that map to load every round.

If you are hosting a server, and want randomly picked maps to be played each round, you can enable map rotation in `config/config.txt` and then set the maps to be picked in the `config/maps.txt` file.

## EDITING MAPS

### [Click here for a Quick-Start Guide To Mapping.](https://hackmd.io/@tgstation/SyVma0dS5)

<b>It is absolutely inadvisable to <i>ever</i> use the mapping utility offered by Dream Maker</b>. It is clunky and dated software that will steal your time, patience, and creative desires.

Instead, /tg/station map maintainers will always recommend using one of two modern and actively maintained programs.

- [StrongDMM](https://github.com/SpaiR/StrongDMM) (Windows/Linux/MacOS)
- [FastDMM2](https://github.com/monster860/FastDMM2) (Web-based Utility)

Both of the above programs have native TGM support, which is mandatory for all maps being submitted to this repository. Anytime you want to make changes to a map, it is imperative you use the [Map Merging tools](https://tgstation13.org/wiki/Map_Merger). When you clone your repository onto your machine for mapping, it's always a great idea to run `tools/hooks/Install.bat` at the very start of your mapping endeavors, as this will install Git hooks that help you automatically resolve any merge conflicts that come up while mapping.

## UPDATEPATHS

#### Using UpdatePaths is mandatory for all mass-path changes in this repository.

UpdatePaths is a scripting tool that will automatically update all instances of a path to a new path in map files (.DMM). This is extremely helpful if you want to be nice to people who have to resolve merge conflicts from the PRs, or downstreams who have several maps that need to be updated with your path change. It's also a great way to make sure you don't miss any instances of a path update in a DMM file, when your Search&Replace Tooling of choice might otherwise fail to recognize the specific syntax and layout of the [TGM Format](https://hackmd.io/@tgstation/ry4-gbKH5#TGM-Format).

As a fast example, let's say you refactor some code, and you've changed the path of `/obj/item/weapon/gun/energy/laser` to `/obj/item/weapon/gun/energy/laser/pistol`. First, you would have to make a new file in the `tools/UpdatePaths/Scripts` [directory](https://github.com/tgstation/tgstation/tree/master/tools/UpdatePaths/Scripts), and name it `PRNUMBER_laser_pistol_split.txt` (with PRNUMBER being the number that your PR is assigned to, for book-keeping purposes). Then, you would have to add the following code to the file:

```txt
/obj/item/weapon/gun/energy/laser : /obj/item/weapon/gun/energy/laser/pistol{@OLD}
```

Doing it this way allows for the same framework that the MapMerger is built on to run after the script has been ran to combine now-repetitive map keys. It also allows for you to retain any properties that the old path had, and apply them to the new path.

For a much more comprehensive guide on UpdatePaths, please see the documentation [here](https://github.com/tgstation/tgstation/blob/master/tools/UpdatePaths/readme.md).

## AWAY MISSIONS

/tg/station supports loading away missions however they are disabled by default.

Map files for away missions are located in the `_maps/RandomZLevels` directory. Each away mission includes it's own code definitions located in `/code/modules/awaymissions/mission_code`. These files must be included and compiled with the server beforehand otherwise the server will crash upon trying to load away missions that lack their code.

<ins>Away missions are _disabled_ by default.</ins> Go to the file denoted in the [Configuration](#configuration) section and "untick" (remove the #) in order to enable it for loading. If more than one away mission is uncommented, the away mission loader will randomly select one of the enabled ones to load. We also support functionality for config-only away missions, which can be set up using the `config/away_missions` folder.

## CONFIGURATION

A majority of maps (outlined below) must be placed in their corresponding configuration file to allow server operators to enable/disable the map for any reason they desire. Follow the chart to see where you should add your new map.

| Type of Map     | Associated File with Link                                                                                           |
| --------------- | ------------------------------------------------------------------------------------------------------------------- |
| Station Maps    | [`config/maps.txt`](https://github.com/tgstation/tgstation/blob/master/config/maps.txt)                             |
| Space Ruins     | [`config/spaceruinblacklist.txt`](https://github.com/tgstation/tgstation/blob/master/config/spaceruinblacklist.txt) |
| Lavaland Ruins  | [`config/lavaruinblacklist.txt`](https://github.com/tgstation/tgstation/blob/master/config/lavaruinblacklist.txt)   |
| Icemoon Ruins   | [`config/iceruinblacklist.txt`](https://github.com/tgstation/tgstation/blob/master/config/iceruinblacklist.txt)     |
| Escape Shuttles | [`config/unbuyableshuttles.txt`](https://github.com/tgstation/tgstation/blob/master/config/unbuyableshuttles.txt)   |
| Away Missions   | [`config/awaymissionconfig.txt`](https://github.com/tgstation/tgstation/blob/master/config/awaymissionconfig.txt)   |

Each .txt file will have instructions on how to appropriately add your map to the file. If you're unsure about certain values, ask for help during the PR process (or beforehand).

## MAP DEPOT

For sentimental purposes, /tg/station hosts a [Map Depot](https://github.com/tgstation/map_depot) for any unused maps since retired from active use in the codebase. A lot of maps present in said depot do get severely outdated within weeks of their initial uploading, so do keep in mind that a bit of setup is required since active maintenance is not enforced there the same way as this repository.
