
https://github.com/Vect0r2/Signia-Station/pull/3

## \<Disabler Sniper>

Module ID: CUSTOM_WHITESHIPS

### Description:
Makes it possible to build custom ships

### TG Proc/File Changes:

I uhh removed some shit in base_turf helpers that didn't work
code/__HELPERS/string_lists.dm
<!-- If you edited any core procs, you should list them here. You should specify the files and procs you changed.
E.g:
- `code/modules/mob/living.dm`: `proc/overriden_proc`, `var/overriden_var`
-->

### Modular Overrides:

signia_modules\master_files\code\game\area\areas\shuttles.dm
signia_modules\master_files\code\controllers\configuation\entries\game_options.dm
<!-- If you added a new modular override (file or code-wise) for your module, you should list it here. Code files should specify what procs they changed, in case of multiple modules using the same file.
E.g:
- `modular_signia/master_files/sound/my_cool_sound.ogg`
- `modular_signia/master_files/code/my_modular_override.dm`: `proc/overriden_proc`, `var/overriden_var`
-->

### Defines:

- N/A
<!-- If you needed to add any defines, mention the files you added those defines in, along with the name of the defines. -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here. Good examples are icons or sounds that are used between multiple modules, or other such edge-cases. -->

### Credits:

PowerfulBacon-Code
Vect0r-porting
