#define INIT_ORDER_MODPACKS 84

// Subsystem of modpacks
SUBSYSTEM_DEF(modpacks)
	name = "Modpacks"
	init_order = INIT_ORDER_MODPACKS
	flags = SS_NO_FIRE
	var/list/loaded_modpacks = list()

/datum/controller/subsystem/modpacks/Initialize()
	var/list/all_modpacks = list()
	for(var/modpack in subtypesof(/datum/modpack/))
		all_modpacks.Add(new modpack)

	// Pre-init and register all compiled modpacks.
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.pre_initialize()
		if(QDELETED(package))
			CRASH("Modpack of type [package.type] is null or queued for deletion.")
		if(fail_msg)
			CRASH("Modpack [package.name] failed to pre-initialize: [fail_msg].")
		if(loaded_modpacks[package.name])
			CRASH("Attempted to register duplicate modpack name [package.name].")
		loaded_modpacks.Add(package)

	// Handle init and post-init (two stages in case a modpack needs to implement behavior based on the presence of other packs).
	for(var/datum/modpack/package as anything in all_modpacks)
		var/fail_msg = package.initialize()
		if(fail_msg)
			CRASH("Modpack [(istype(package) && package.name) || "Unknown"] failed to initialize: [fail_msg]")

	return SS_INIT_SUCCESS

/client/verb/modpacks_list()
	set name = "Modpacks List"
	set category = "OOC"
	
	if(!GLOB.modpacks_tgui)
		GLOB.modpacks_tgui = new /datum/modpack()

	GLOB.modpacks_tgui.ui_interact(mob)

//Show modpacks button on lobby screen
//ORIGINAL FILE: code/_onclick/hud/new_player.dm
/atom/movable/screen/lobby/button/bottom/poll
	icon = 'modular_meta/__modpack/mods_button.dmi'
	name = "View Loaded Modpacks"
	icon_state = "mods"
	base_icon_state = "mods"
	screen_loc = "TOP:-122,CENTER:-26"

/atom/movable/screen/lobby/button/bottom/poll/Click(location, control, params)
	. = ..()
	usr.client?.modpacks_list()
