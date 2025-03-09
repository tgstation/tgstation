/datum/quirk/ship_captain
	name = "Spacefarer"
	desc = "You have access to a hyperspace-capable vessel. Use a friend's crew identifier key to spawn on their shuttle, or set off solo on your own!"
	gain_text = span_info("You're ready to take on the rigors of space travel.")
	lose_text = span_warning("A station's looking real tempting right now...")
	medical_record_text = "Subject has registered micro-g hypovolemia screening due to prolonged space travel."
	icon = FA_ICON_SHIP
	value = 8
	var/datum/turf_reservation/owned_ship_reservation
	var/datum/map_template/shuttle/personal_buyable/our_shuttle_template
	var/area/quirk_shuttle_area

/datum/quirk/ship_captain/post_add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/crewing_key = quirk_holder.client?.prefs.read_preference(/datum/preference/text/ship_captain_crewkey)
	var/list/reserved_z = SSmapping.levels_by_trait(ZTRAIT_RESERVED)

	if (is_centcom_level(human_holder.z)) // don't spawn our shuttle if we're in the fucking thunderdome or deathmatch
		return
	if (!is_station_level(human_holder.z) && !locate(human_holder.z) in reserved_z) // sometimes players join in on a transit shuttle, which happens in a reserved z-level, so
		return
	if (HAS_TRAIT(human_holder, TRAIT_BITRUNNER_AVATAR)) // don't spawn this on bitrunner avatars obviously
		return

	if (crewing_key && crewing_key != "Solo")
		var/turf/crew_arrival_turf = get_turf(GLOB.ship_code_to_spawn_marker[crewing_key])
		// If someone else has a ship that already has the same key, then we don't spawn a new one
		// Congrats, you are now enlisted
		if(crew_arrival_turf)
			var/area/joined_ship = crew_arrival_turf.loc
			to_chat(human_holder, span_notice("You board the [joined_ship.name], and prepare for another shift of work."))
			human_holder.forceMove(crew_arrival_turf)
			return

	var/template_path_key = quirk_holder.client?.prefs.read_preference(/datum/preference/choiced/ship_captain_hull)
	var/template_path
	if (template_path_key)
		if (template_path_key == "Random")
			template_path = GLOB.purchasable_ship_hulls[pick(assoc_to_keys(GLOB.purchasable_ship_hulls))]
		else
			template_path = GLOB.purchasable_ship_hulls[template_path_key]

	if (!template_path)
		CRASH("failed to select ship template!")

	our_shuttle_template = new template_path()

	if (!our_shuttle_template)
		CRASH("failed to make ship template for captain quirk at prefs read stage")

	owned_ship_reservation = SSmapping.request_turf_block_reservation(
		our_shuttle_template.width,
		our_shuttle_template.height,
		1,
	)
	if (!owned_ship_reservation)
		CRASH("failed to reserve an area for ship captain quirk shuttle template loading")

	var/turf/bottom_left = owned_ship_reservation.bottom_left_turfs[1]
	our_shuttle_template.load(bottom_left, centered = FALSE)

	// Finds the first shuttle turfs out of all of the reservation reserved turfs
	var/affected_turfs = owned_ship_reservation.reserved_turfs
	var/turf/first_shuttle_turf_found
	for(var/turf/shuttle_turf in affected_turfs)
		if (is_safe_turf(shuttle_turf))
			first_shuttle_turf_found = shuttle_turf
			break

	var/area/shuttle/new_shuttle_area = get_area(first_shuttle_turf_found)
	var/new_shuttle_id
	var/obj/effect/landmark/ship_captain_spawner/our_spawner

	// Links the ship to it's spawner
	for(var/obj/docking_port/mobile/pcport in new_shuttle_area)
		new_shuttle_id += pcport.shuttle_id
		GLOB.ship_code_to_spawn_marker += crewing_key
		our_spawner = GLOB.ship_id_to_spawn_marker[new_shuttle_id]
		if(crewing_key && crewing_key != "Solo")
			GLOB.ship_code_to_spawn_marker[crewing_key] = our_spawner
		break

	// do any area customizations where appropriate
	var/ship_name = quirk_holder.client?.prefs.read_preference(/datum/preference/text/ship_captain_name)
	if(ship_name != "Default")
		rename_area(new_shuttle_area, ship_name)

	// save our area - we'll need this for ship captain pairing
	quirk_shuttle_area = new_shuttle_area

	// otherwise, move us there
	var/turf/forcemove_turf = get_turf(our_spawner)
	if(forcemove_turf)
		human_holder.forceMove(forcemove_turf)
	else if(length(new_shuttle_area.contents))
		for(var/turf/backup_spawn_turf in new_shuttle_area.contents)
			if(is_safe_turf(backup_spawn_turf))
				human_holder.forceMove(backup_spawn_turf)
	else
		message_admins("[quirk_holder] couldn't find literally anywhere to spawn it's ship owner, that's fucked up.")

	// let command know shut up i know it's hacky
	for(var/obj/machinery/computer/communications/comms_console in GLOB.shuttle_caller_list)
		if(!(comms_console.machine_stat & (BROKEN|NOPOWER)) && is_station_level(comms_console.z))
			if (ship_name != "Default")
				new /obj/item/radio/one_shot_broadcaster(comms_console.loc, "NLP-NAV-TC", "informs", FREQ_COMMAND, "New vessel hailed and acknowledged in local vicinity. Transponder tag: [ship_name]. Hull class: [template_path_key]. Registered captain: [human_holder.name].")
			else
				new /obj/item/radio/one_shot_broadcaster(comms_console.loc, "NLP-NAV-TC", "informs", FREQ_COMMAND, "New vessel hailed and acknowledged in local vicinity. No unique transponder tag. Hull class: [template_path_key].")
			break

/datum/quirk/ship_captain/remove()
	. = ..()
	if (owned_ship_reservation)
		owned_ship_reservation.Release()
	if (quirk_shuttle_area)
		// clear out our entry from the ship captain pairing table
		var/crewing_key = quirk_holder.client?.prefs.read_preference(/datum/preference/text/ship_captain_crewkey)
		if (crewing_key && crewing_key != "Solo")
			GLOB.ship_captain_pairs.Remove(crewing_key)

		// if there's nothing with a mind aboard our ship, just jump it to nullspace
		var/delete = TRUE
		var/mob/living/culprit
		var/list/things_on_our_shuttle = mobs_in_area_type(quirk_shuttle_area)
		for (var/mob/living/thing as anything in things_on_our_shuttle)
			if (thing.mind)
				delete = FALSE
				culprit = thing

		if (delete)
			var/obj/docking_port/mobile/personally_bought/shuttle_port = locate() in quirk_shuttle_area.contents
			if (shuttle_port)
				quirk_shuttle_area = null // just get ahead of the curve to prevent hard dels
				shuttle_port.jumpToNullSpace() //goodbye shuttle (and everything on it, including areas)
		else
			if (culprit)
				message_admins("Spacefaring quirk deletion tried to clean up a shuttle, but couldn't because of [culprit][ADMIN_JMP(culprit)]. Tidy up manually w/ shuttle manipulator if an issue.")

/obj/effect/landmark/ship_captain_spawner
	name = "Ship Captain Ship Spawner"

/obj/effect/landmark/ship_captain_spawner/Initialize(mapload)
	. = ..()
	var/area/shuttle/spawn_area = get_area(src)
	if(!istype(spawn_area))
		return
	for(var/obj/docking_port/mobile/pcport in spawn_area)
		GLOB.ship_id_to_spawn_marker += pcport.shuttle_id
		GLOB.ship_id_to_spawn_marker[pcport.shuttle_id] = src
		return // There should only be one of you on a ship you know

// TODO: add more docking ports to the lavaland wastes
// TODO: put a megabeacon at roundstart/mapload on the lavalands top waste z level
// TODO: add some means of initial communication with the station to shuttles
