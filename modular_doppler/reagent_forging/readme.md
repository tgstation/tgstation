## Title: Reagent Forging

MODULE ID: REAGENT_FORGING

### Description:

Reagent forging is a form of forging where users are able to create various items that have the ability to become imbued with reagents. Items that have been imbued have the ability to permanently inject imbued reagents into the targets.

### TG Proc Changes:

| proc                                                                  | file                                |
| --------------------------------------------------------------------- | ----------------------------------- |
| `/atom/proc/tool_act(mob/living/user, obj/item/tool, list/modifiers)` | `code\game\atom\atom_tool_acts.dm`  |

### Defines:

- `code\__DEFINES\~doppler_defines\reagent_forging_tools.dm` reagent forging tools' define

### Master file additions

N/A

### Included files that are not contained in this module:

- `code\__DEFINES\~doppler_defines\obj_flags_doppler.dm` anvil_repair define
- `code\_globalvars\~doppler_globalvars\bitfields.dm` anvil_repair bitfield
- `modular_doppler\modular_crafting\code\sheet_types.dm` contains some of the recipes

### Credits:

Jake Park
