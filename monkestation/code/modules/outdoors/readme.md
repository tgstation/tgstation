## Title: <!--Title of your addition-->

<!-- uppercase, underscore_connected name of your module, that you use to mark files-->
MODULE ID: OUTDOOR_EFFECTS 

### Description:

This PR adds outdoor effects to MS in the form of Weather, using particle effects, and sunlight, which adds to the lighting system.

Each turf is given an Outdoor_effects object, that holds up to two overlays - one for weather and one for sunlight.

Sunlight is governed by three "states" on a turf, based on a roof_type 
SKY_BLOCKED
SKY_VISIBLE
SKY_VISIBLE_BORDER


Weather is affected by whether or not the roof above is weatherproof - for now this is limited to space/open_space


<!-- Here, try to describe what your PR does, what features it provides and any other directly useful information -->

### TG Proc/File Changes:

<!-- If you had to edit, or append to any core procs in the process of making this PR, list them here. APPEND: Also, please include any files that you've changed. .DM files that is. -->
	- _maps/_basemap.dm
	- code/_globalvars/traits.dm
	- code/_onclick/hud/rendering/plane_master.dm
	- code/_onclick/hud/rendering/plane_master_controller.dm
	- code/controllers/configuration/config_entry.dm
	- code/datums/looping_sounds/_looping_sound.dm
	- code/datums/map_config.dm
	- code/game/atoms_movable.dm
	- code/game/turfs/change_turf.dm
	- code/game/turfs/turf.dm
	- code/modules/admin/admin_verbs.dm
	- code/modules/admin/holder2.dm
	- code/modules/admin/view_variables/get_variables.dm
	- code/modules/client/client_procs.dm
	- code/modules/lighting/lighting_corner.dm
	- code/modules/lighting/lighting_turf.dm


### Defines:

<!-- If you needed to add any defines, mention the files you added those defines in -->
	- code/__DEFINES/is_helpers.dm
	- code/__DEFINES/layers.dm
	- code/__DEFINES/lighting.dm
	- code/__DEFINES/maps.dm
	- code/__DEFINES/maths.dm
	- code/__DEFINES/sound.dm
	- code/__DEFINES/subsystems.dm
	- code/__DEFINES/traits.dm
	- code/__DEFINES/vv.dm
	- code/__HELPERS/_lists.dm
	- code/__HELPERS/time.dm

### Master file additions

- N/A
<!-- Any master file changes you've made to existing master files or if you've added a new master file. Please mark either as #NEW or #CHANGE -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here -->

### Credits:

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code -->
<!-- Orignal Coders -->
Made by Gomble/AndrewL97 for Mojave Sun - Attribution required if ported, unless otherwise discussed (and confirmed in writing via comment, etc.) by Gomble/AndrewL97
Contact me on Discord
<!-- Orignal Coders -->
Ported by Dwasint
