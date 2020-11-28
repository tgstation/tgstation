https://github.com/Skyrat-SS13/Skyrat-tg/pull/151

## Title: Cloning

MODULE ID: CLONING

### Description:

Enables the crew to clone dead bodies via the cloning scanner.

### TG Proc Changes:

- code/_globalvars/lists/poll_ignore.dm > GLOBAL_LIST_INIT(poll_ignore_desc)
- code/datums/dna.dm > /datum/dna/Destroy()
- code/datums/shuttles.dm > /datum/map_template/shuttle/emergency/zeta
- code/modules/antagonists/revenant/revenant_abilities.dm > /obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/proc/malfunction()
- code/modules/clothing/head/misc_special.dm > /obj/item/clothing/head/foilhat/equipped()

### Defines:

- #define ACCESS_CLONING 68
- #define CLONER_FRESH_CLONE "fresh"
- #define CLONER_MATURE_CLONE "mature"
- #define CLONING_SUCCESS (1<<0)
- #define CLONING_DELETE_RECORD (1<<1)
- #define POLL_IGNORE_DEFECTIVECLONE "defective_clone"


<!-- If you needed to add any defines, mention the files you added those defines in -->

### Master file additions

- N/A
<!-- Any master file changes you've made to existing master files or if you've added a new master file. Please mark either as #NEW or #CHANGE -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here -->

### Credits:

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code -->
