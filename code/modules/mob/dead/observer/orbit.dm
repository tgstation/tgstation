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

			if((ismob(poi) && !SSpoints_of_interest.is_valid_poi(poi, CALLBACK(src, PROC_REF(validate_mob_poi)))) \
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
	var/list/new_mob_pois = SSpoints_of_interest.get_mob_pois(CALLBACK(src, PROC_REF(validate_mob_poi)), append_dead_role = FALSE)
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
		serialized["full_name"] = name

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

		serialized["name"] = mob_poi.real_name

		if(isliving(mob_poi)) // handles edge cases like blob
			var/mob/living/player = mob_poi
			serialized["health"] = FLOOR((player.health / player.maxHealth * 100), 1)
			if(issilicon(player))
				serialized["job"] = player.job
			else
				var/obj/item/card/id/id_card = player.get_idcard(hand_first = FALSE)
				serialized["job"] = id_card?.get_trim_assignment()
				var/datum/id_trim/trim = id_card?.trim
				serialized["job_icon"] = trim?.orbit_icon

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
			"full_name" = name,
		))

		// Display the supermatter crystal integrity
		if(istype(atom_poi, /obj/machinery/power/supermatter_crystal))
			var/obj/machinery/power/supermatter_crystal/crystal = atom_poi
			misc[length(misc)]["extra"] = "Integrity: [crystal.get_integrity_percent()]%"
			continue
		// Display the nuke timer
		if(istype(atom_poi, /obj/machinery/nuclearbomb))
			var/obj/machinery/nuclearbomb/bomb = atom_poi
			if(bomb.timing)
				misc[length(misc)]["extra"] = "Timer: [bomb.countdown?.displayed_text]s"
			continue
		// Display the holder if its a nuke disk
		if(istype(atom_poi, /obj/item/disk/nuclear))
			var/obj/item/disk/nuclear/disk = atom_poi
			var/mob/holder = disk.pulledby || get(disk, /mob)
			misc[length(misc)]["extra"] = "Location: [holder?.real_name || "Unsecured"]"
			continue

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
