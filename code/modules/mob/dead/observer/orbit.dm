GLOBAL_DATUM_INIT(orbit_menu, /datum/orbit_menu, new)

/datum/orbit_menu

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
		if("orbit")
			var/ref = params["ref"]
			var/auto_observe = params["auto_observe"]
			var/atom/poi = SSpoints_of_interest.get_poi_atom_by_ref(ref)

			if((ismob(poi) && !SSpoints_of_interest.is_valid_poi(poi, CALLBACK(src, .proc/validate_mob_poi))) \
				|| !SSpoints_of_interest.is_valid_poi(poi)
			)
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
	var/list/new_mob_pois = SSpoints_of_interest.get_mob_pois(CALLBACK(src, .proc/validate_mob_poi), append_dead_role = FALSE)
	var/list/new_other_pois = SSpoints_of_interest.get_other_pois()

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	for(var/name in new_mob_pois)
		var/list/serialized = list()

		var/mob/mob_poi = new_mob_pois[name]

		var/poi_ref = REF(mob_poi)
		serialized["ref"] = poi_ref
		serialized["name"] = name

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

	for(var/name in new_other_pois)
		var/atom/atom_poi = new_other_pois[name]

		misc += list(list(
			"ref" = REF(atom_poi),
			"name" = name,
		))

	return list(
		"alive" = alive,
		"antagonists" = antagonists,
		"dead" = dead,
		"ghosts" = ghosts,
		"misc" = misc,
		"npcs" = npcs,
	)

/// Shows the UI to the specified user.
/datum/orbit_menu/proc/show(mob/user)
	ui_interact(user)

/**
 * Helper POI validation function passed as a callback to various SSpoints_of_interest procs.
 *
 * Provides extended validation above and beyond standard, limiting mob POIs without minds or ckeys
 * unless they're mobs, camera mobs or megafauna.
 *
 * If they satisfy that requirement, falls back to default validation for the POI.
 */
/datum/orbit_menu/proc/validate_mob_poi(datum/point_of_interest/mob_poi/potential_poi)
	var/mob/potential_mob_poi = potential_poi.target
	// Skip mindless and ckeyless mobs except bots, cameramobs and megafauna.
	if(!potential_mob_poi.mind && !potential_mob_poi.ckey)
		if(!isbot(potential_mob_poi) && !iscameramob(potential_mob_poi) && !ismegafauna(potential_mob_poi))
			return FALSE

	return potential_poi.validate()
