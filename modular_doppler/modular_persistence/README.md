## Modular Persistence

Module ID: MODULAR_PERSISTENCE

### Description:

An extremely easy to extend per-character persistence file. Supports all the basic types, plus lists.

Simply add the vars you want to have saved to `/datum/modular_persistence`, and make sure those var values are updated before round end so that they're saved.

Loaded and saved on only station-side players for now. Will be expanded to support more in the future.

### TG Proc/File Changes:

- `code\modules\mob\dead\new_player\new_player.dm`: `/mob/dead/new_player/proc/AttemptLateSpawn`
- `code\controllers\subsystem\persistence.dm`: `/datum/controller/subsystem/persistence/proc/collect_data`

### Defines:

- `modular_nova\modules\modular_persistence\code\modular_persistence.dm`: `GLOB.modular_persistence_ignored_vars`

### Credits:
- RimiNosha - Code
