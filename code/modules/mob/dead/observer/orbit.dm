GLOBAL_DATUM_INIT(orbit_menu, /datum/orbit_menu, new)

/datum/orbit_menu
	///mobs worth orbiting. Because spaghetti, all mobs have the point of interest, but only some are allowed to actually show up.
	///this obviously should be changed in the future, so we only add mobs as POI if they actually are interesting, and we don't use
	///a typecache.
	var/static/list/mob_allowed_typecache

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
			user.orbiting_ref = ref
			if (auto_observe)
				if (poi != user)
					user.do_observe(poi)
			return TRUE
		if ("refresh")
			ui.send_full_update()
			return TRUE

	return FALSE


/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()

	if(isobserver(user))
		data["orbiting"] = get_currently_orbiting(user)

	return data


/datum/orbit_menu/ui_static_data(mob/user)
	var/list/new_mob_pois = SSpoints_of_interest.get_mob_pois(CALLBACK(src, PROC_REF(validate_mob_poi)), append_dead_role = FALSE)
	var/list/new_other_pois = SSpoints_of_interest.get_other_pois()
	var/is_admin = user?.client?.holder

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/critical = list()
	var/list/deadchat_controlled = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	for(var/name in new_mob_pois)
		var/list/serialized = list()
		var/mob/mob_poi = new_mob_pois[name]
		var/number_of_orbiters = length(mob_poi.get_all_orbiters())

		serialized["ref"] = REF(mob_poi)
		serialized["full_name"] = name
		if(number_of_orbiters)
			serialized["orbiters"] = number_of_orbiters

		if(mob_poi.GetComponent(/datum/component/deadchat_control))
			deadchat_controlled += list(serialized)

		if(isobserver(mob_poi))
			ghosts += list(serialized)
			continue

		if(mob_poi.stat == DEAD)
			dead += list(serialized)
			continue

		if(isnull(mob_poi.mind))
			if(isliving(mob_poi))
				var/mob/living/npc = mob_poi
				serialized["health"] = FLOOR((npc.health / npc.maxHealth * 100), 1)

			npcs += list(serialized)
			continue

		serialized["client"] = !!mob_poi.client
		serialized["name"] = mob_poi.real_name

		if (is_admin)
			serialized["ckey"] = mob_poi.ckey

		if(isliving(mob_poi))
			serialized += get_living_data(mob_poi)

		var/list/antag_data = get_antag_data(mob_poi.mind, is_admin)
		if(length(antag_data))
			serialized += antag_data
			antagonists += list(serialized)
			continue

		alive += list(serialized)

	for(var/name in new_other_pois)
		var/atom/atom_poi = new_other_pois[name]

		// Deadchat Controlled objects are orbitable
		if(atom_poi.GetComponent(/datum/component/deadchat_control))
			var/number_of_orbiters = length(atom_poi.get_all_orbiters())
			deadchat_controlled += list(list(
				"ref" = REF(atom_poi),
				"full_name" = name,
				"orbiters" = number_of_orbiters,
			))
			continue

		var/list/other_data = get_misc_data(atom_poi)
		var/misc_data = list(other_data[1])

		misc += misc_data

		if(other_data[2]) // Critical = TRUE
			critical += misc_data

	return list(
		"alive" = alive,
		"antagonists" = antagonists,
		"critical" = critical,
		"deadchat_controlled" = deadchat_controlled,
		"dead" = dead,
		"ghosts" = ghosts,
		"misc" = misc,
		"npcs" = npcs,
	)


/// Shows the UI to the specified user.
/datum/orbit_menu/proc/show(mob/user)
	ui_interact(user)


/// Helper function to get threat type, group, overrides for job and icon
/datum/orbit_menu/proc/get_antag_data(datum/mind/poi_mind, is_admin) as /list
	var/list/serialized = list()

	for(var/datum/antagonist/antag as anything in poi_mind.antag_datums)
		if(!antag.show_to_ghosts && !is_admin)
			continue

		serialized["antag"] = antag.name
		serialized["antag_group"] = antag.antagpanel_category
		serialized["antag_icon"] = antag.antag_hud_name

		return serialized


/// Helper to get the current thing we're orbiting (if any)
/datum/orbit_menu/proc/get_currently_orbiting(mob/dead/observer/user)
	if(isnull(user.orbiting_ref))
		return

	var/atom/poi = SSpoints_of_interest.get_poi_atom_by_ref(user.orbiting_ref)
	if(isnull(poi))
		user.orbiting_ref = null
		return

	if((ismob(poi) && !SSpoints_of_interest.is_valid_poi(poi, CALLBACK(src, PROC_REF(validate_mob_poi)))) \
		|| !SSpoints_of_interest.is_valid_poi(poi)
	)
		user.orbiting_ref = null
		return

	var/list/serialized = list()

	if(!ismob(poi))
		var/list/misc_info = get_misc_data(poi)
		serialized += misc_info[1]
		return serialized

	var/mob/mob_poi = poi
	serialized["full_name"] = mob_poi.name
	serialized["ref"] = REF(poi)

	if(mob_poi.mind)
		serialized["client"] = !!mob_poi.client
		serialized["name"] = mob_poi.real_name

	if(isliving(mob_poi))
		serialized += get_living_data(mob_poi)

	return serialized


/// Helper function to get job / icon / health data for a living mob
/datum/orbit_menu/proc/get_living_data(mob/living/player) as /list
	var/list/serialized = list()

	serialized["health"] = FLOOR((player.health / player.maxHealth * 100), 1)
	if(issilicon(player))
		serialized["job"] = player.job
		serialized["icon"] = "borg"
		return serialized

	var/obj/item/card/id/id_card = player.get_idcard(hand_first = FALSE)
	serialized["job"] = id_card?.get_trim_assignment()
	serialized["icon"] = id_card?.get_trim_sechud_icon_state()

	var/datum/job/job = player.mind?.assigned_role
	if (isnull(job))
		return serialized

	serialized["mind_job"] = job.title
	var/datum/outfit/outfit = job.get_outfit()
	if (isnull(outfit))
		return serialized

	var/datum/id_trim/trim = outfit.id_trim
	if (!isnull(trim))
		serialized["mind_icon"] = trim::sechud_icon_state
	return serialized

/// Gets a list: Misc data and whether it's critical. Handles all snowflakey type cases
/datum/orbit_menu/proc/get_misc_data(atom/movable/atom_poi) as /list
	var/list/misc = list()
	var/critical = FALSE

	misc["ref"] = REF(atom_poi)
	misc["full_name"] = atom_poi.name

	// Display the supermatter crystal integrity
	if(istype(atom_poi, /obj/machinery/power/supermatter_crystal))
		var/obj/machinery/power/supermatter_crystal/crystal = atom_poi
		var/integrity = round(crystal.get_integrity_percent())
		misc["extra"] = "Integrity: [integrity]%"

		if(integrity < 10)
			critical = TRUE

		return list(misc, critical)

	// Display the nuke timer
	if(istype(atom_poi, /obj/machinery/nuclearbomb))
		var/obj/machinery/nuclearbomb/bomb = atom_poi

		if(bomb.timing)
			misc["extra"] = "Timer: [bomb.countdown?.displayed_text]s"
			critical = TRUE

		return list(misc, critical)

	// Display the holder if its a nuke disk
	if(istype(atom_poi, /obj/item/disk/nuclear))
		var/obj/item/disk/nuclear/disk = atom_poi
		var/mob/holder = disk.pulledby || get(disk, /mob)
		misc["extra"] = "Location: [holder?.real_name || "Unsecured"]"

		return list(misc, critical)

	// Display singuloths if they exist
	if(istype(atom_poi, /obj/singularity))
		var/obj/singularity/singulo = atom_poi
		misc["extra"] = "Energy: [round(singulo.energy)]"

		if(singulo.current_size > 2)
			critical = TRUE

		return list(misc, critical)

	return list(misc, critical)


/**
 * Helper POI validation function passed as a callback to various SSpoints_of_interest procs.
 *
 * Provides extended validation above and beyond standard, limiting mob POIs without minds or ckeys
 * unless they're mobs, eye mobs or megafauna. Also allows exceptions for mobs that are deadchat controlled.
 *
 * If they satisfy that requirement, falls back to default validation for the POI.
 */
/datum/orbit_menu/proc/validate_mob_poi(datum/point_of_interest/mob_poi/potential_poi)
	var/mob/potential_mob_poi = potential_poi.target
	if(!potential_mob_poi.mind && !potential_mob_poi.ckey)
		if(!mob_allowed_typecache)
			mob_allowed_typecache = typecacheof(list(
				/mob/eye,
				/mob/living/basic/regal_rat,
				/mob/living/simple_animal/bot,
				/mob/living/simple_animal/hostile/megafauna,
			))
		if(!is_type_in_typecache(potential_mob_poi, mob_allowed_typecache) && !potential_mob_poi.GetComponent(/datum/component/deadchat_control))
			return FALSE

	return potential_poi.validate()

