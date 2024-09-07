## Title: Primitive Production
MODULE ID: PRIMITIVE_PRODUCTION

### Description:

Adds a variety of 'primitive' ways to produce items
Antfarming, wormfarming and the normal kind of farming were added as well.

### TG Proc/File Changes:

| proc                                                                  | file                                |
| --------------------------------------------------------------------- | ----------------------------------- |
| `/atom/proc/tool_act(mob/living/user, obj/item/tool, list/modifiers)` | `code\game\atom\atom_tool_acts.dm`  |

### Defines:

- `code\__DEFINES\~doppler_defines\reagent_forging_tools.dm` glassblowing tools' define
- `code\__DEFINES\~doppler_defines\traits.dm` trait for glassblowing

### Master file additions

N/A

### Included files that are not contained in this module:

- `modular_doppler\modular_crafting\code\sheet_types.dm` crafting recipes

### Credits:

Jake Park
