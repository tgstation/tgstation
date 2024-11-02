#define INIT_ORDER_MODPACKS 84

/datum/modpack/ui_state()
	return GLOB.always_state

/datum/modpack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Modpacks")
		ui.open()

/datum/modpack/ui_data(mob/user)
	var/list/modpacks = list()
	for(var/datum/modpack/package as anything in SSmodpacks.loaded_modpacks)
		modpacks += list(list(
			"name" = package.name,
			"desc" = package.desc,
			"author" = package.author,
			))

	return modpacks


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
/*
	if(!mob || !SSmodpacks.initialized)
		return
	
	// WHERE MYH FANCY TGUI, HUH!&!??
	// Need to make groops: Features, Perevody, Reverts
	if(length(SSmodpacks.loaded_modpacks))
		. = "<hr><br><center><b><font size = 3>Список модификаций</font></b></center><br><hr><br>"
		for(var/datum/modpack/M as anything in SSmodpacks.loaded_modpacks)
			if(M.name)
				. += "<div class = 'statusDisplay'>"
				. += "<center><b>[M.name]</b></center>"

				if(M.desc || M.author)
					. += "<br>"
					if(M.desc)
						. += "<br>Описание: [M.desc]"
					if(M.author)
						. += "<br><i>Автор: [M.author]</i>"
				. += "</div><br>"

		var/datum/browser/popup = new(mob, "modpacks_list", "Список Модификаций", 480, 580)
		popup.set_content(.)
		popup.open()
	else
		to_chat(src, "Этот сервер не использует какие-либо модификации.")
*/

//Show modpacks button on lobby screen
//ORIGINAL FILE: code/_onclick/hud/new_player.dm
/atom/movable/screen/lobby/button/bottom/poll
	icon = 'modular_meta/mods_button.dmi'
	name = "View Loaded Modpacks"
	icon_state = "mods"
	base_icon_state = "mods"
	screen_loc = "TOP:-122,CENTER:-26"

/atom/movable/screen/lobby/button/bottom/poll/Click(location, control, params)
	. = ..()
	usr.client?.modpacks_list()
