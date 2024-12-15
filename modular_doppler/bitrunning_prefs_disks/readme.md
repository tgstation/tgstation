<!-- This should be copy-pasted into the root of your module folder as readme.md -->

SOON<!--PR Number-->

## Bitrunning Avatar Preference Disks <!--Title of your addition.-->

Module ID: BITRUNNING_PREFS_DISKS <!-- Uppercase, UNDERSCORE_CONNECTED name of your module, that you use to mark files. This is so people can case-sensitive search for your edits, if any. -->

### Description:

Allows bitrunners to buy a personalized avatar disk, which lets them load in a given character preference, with all that entails.
This includes even quirks through evil hacks, and optionally loadouts.
Preference application and quirks are blocked if a domain blocks spells/abilities, loadouts are blocked if a domain blocks items.
The evil hacks this performs are using a barebones mock client to allow for quirk assignment without forwarding or affecting the real client.

<!-- Here, try to describe what your PR does, what features it provides and any other directly useful information. -->

### TG Proc/File Changes:

- `code/modules/bitrunning/server/obj_generation.dm`: `proc/stock_gear`
<!-- If you edited any core procs, you should list them here. You should specify the files and procs you changed.
E.g: 
- `code/modules/mob/living.dm`: `proc/overriden_proc`, `var/overriden_var`
-->

### Modular Overrides:

- N/A
<!-- If you added a new modular override (file or code-wise) for your module, you should list it here. Code files should specify what procs they changed, in case of multiple modules using the same file.
E.g: 
- `modular_doppler/master_files/sound/my_cool_sound.ogg`
- `modular_doppler/master_files/code/my_modular_override.dm`: `proc/overriden_proc`, `var/overriden_var`
-->

### Defines:

- N/A
<!-- If you needed to add any defines, mention the files you added those defines in, along with the name of the defines. -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here. Good examples are icons or sounds that are used between multiple modules, or other such edge-cases. -->

### Credits: 00-Steven

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code. -->