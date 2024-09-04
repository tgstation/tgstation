## Title: Hearthkin

MODULE ID: HEARTHKIN

### Description:

Contains the main sub-modules for the Hearthkin, a tribe of genetically modified humanoids that inhabits the Ice Moon. They have their own primitive means of cooking, farming, production and much more.

The species ID `primitive_felinid` was added in the configuration file `config\doppler\config_doppler.txt` as a round start species

### TG Proc Changes:

| proc                                                                  | file                                |
| --------------------------------------------------------------------- | ----------------------------------- |
| `/atom/proc/tool_act(mob/living/user, obj/item/tool, list/modifiers)` | `code\game\atom\atom_tool_acts.dm`  |

### Defines:

- `code\__DEFINES\~doppler_defines\DNA.dm` species id
- `code\__DEFINES\~doppler_defines\is_helpers.dm` is_type identificator for species
- `code\__DEFINES\~doppler_defines\reagent_forging_tools.dm` glassblowing tools' define
- `code\__DEFINES\~doppler_defines\traits.dm` trait for glassblowing

### Master file additions

N/A

### Included files that are not contained in this module:

- `modular_doppler\modular_crafting\code\sheet_types.dm` crafting recipes
- `modular_doppler\stone\code\stone.dm` crafting recipes

### Credits:
