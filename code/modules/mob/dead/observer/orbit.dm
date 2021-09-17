GLOBAL_DATUM_INIT(orbit_menu, /datum/orbit_menu, new)

/datum/orbit_menu
	/// Serialised list of all valid POIs. Master list that holds all POIs from all other lists.
	var/list/pois = list()
	/// Serialised list of all alive POIs.
	var/list/alive = list()
	/// Serialised list of all antagonist POIs.
	var/list/antagonists = list()
	/// Serialised list of all dead mob POIs.
	var/list/dead = list()
	/// Serialised list of all observers POIS.
	var/list/ghosts = list()
	/// Serialised list of all non-mob POIs.
	var/list/misc = list()
	/// Serialised list of all POIS without a mind.
	var/list/npcs = list()

	/// When TRUE, will update next process. Set to TRUE when SSpois informs the orbit menu that POIs have changed.
	var/do_update_next_process = TRUE

/datum/orbit_menu/New()
	RegisterSignal(SSpois, list(COMSIG_MOB_POIS_CHANGED, COMSIG_OTHER_POIS_CHANGED), .proc/on_poi_change)
	START_PROCESSING(SSprocessing, src)

/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Orbit")
		ui.open()

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	switch(action)
		if ("orbit")
			var/ref = params["ref"]
			var/auto_observe = params["autoObs"]
			var/atom/movable/poi = pois[ref]
			if (!poi)
				to_chat(usr, span_notice("That point of interest is no longer valid."))
				return TRUE

			var/mob/dead/observer/user = usr
			user.ManualFollow(poi)
			user.reset_perspective(null)
			if (auto_observe)
				user.do_observe(poi)
			return TRUE
		if ("refresh")
			update_static_data(usr, ui)
			return TRUE

/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs

	return data

/datum/orbit_menu/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/orbit)

/// Updates the list of POIs.
/datum/orbit_menu/proc/update_poi_list()
	var/list/new_pois = SSpois.get_pois(skip_mindless = TRUE, specify_dead_role = FALSE)

	pois.Cut()
	alive.Cut()
	antagonists.Cut()
	dead.Cut()
	ghosts.Cut()
	misc.Cut()
	npcs.Cut()

	for(var/name in new_pois)
		var/list/serialized = list()
		serialized["name"] = name

		var/poi = new_pois[name]

		var/poi_ref = REF(poi)
		serialized["ref"] = poi_ref

		pois[poi_ref] = poi

		if(ismob(poi))
			var/mob/mob_poi = poi

			if(isobserver(mob_poi))
				var/number_of_orbiters = length(mob_poi.get_all_orbiters())
				if (number_of_orbiters)
					serialized["orbiters"] = number_of_orbiters
				ghosts += list(serialized)
				continue

			if(mob_poi.stat == DEAD)
				dead += list(serialized)
				continue

			if(isnull(mob_poi.mind))
				npcs += list(serialized)
				continue

			var/number_of_orbiters = length(mob_poi.get_all_orbiters())
			if(number_of_orbiters)
				serialized["orbiters"] = number_of_orbiters

			var/datum/mind/mind = mob_poi.mind
			var/was_antagonist = FALSE

			for(var/datum/antagonist/antag_datum as anything in mind.antag_datums)
				if (antag_datum.show_to_ghosts)
					was_antagonist = TRUE
					serialized["antag"] = antag_datum.name
					antagonists += list(serialized)
					break

			if(!was_antagonist)
				alive += list(serialized)
		else
			misc += list(serialized)

	do_update_next_process = TRUE

/// Shows the UI to the specified user.
/datum/orbit_menu/proc/show(mob/user)
	ui_interact(user)

/**
 * Signal handler for major POI changes.
 *
 * Major POI changes are POIs added or removed from SSpoi's lists.
 *
 * We need to update the poi lists promptly, as they are used to validate user input in ui_act.
 */
/datum/orbit_menu/proc/on_poi_change()
	SIGNAL_HANDLER

	update_poi_list()

/**
 * Manages periodic updates.
 *
 * Used to sweep up minor POI updates like dead < - > alive /mob/living state changes.
 *
 * Pushes all the updates to all active UI windows.
 */
/datum/orbit_menu/process(delta_time)
	update_poi_list()

	for(var/datum/tgui/window as anything in SStgui.open_uis_by_src[REF(src)])
		window.send_full_update()
