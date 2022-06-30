///Time before being allowed to select a new cult leader again
#define CULT_POLL_WAIT 240 SECONDS

/// Returns either the error landmark or the location of the room. Needless to say, if this is used, it means things have gone awry.
#define GET_ERROR_ROOM ((locate(/obj/effect/landmark/error) in GLOB.landmarks_list) || locate(4,4,1))

///Returns the name of the area the atom is in
/proc/get_area_name(atom/checked_atom, format_text = FALSE)
	var/area/checked_area = isarea(checked_atom) ? checked_atom : get_area(checked_atom)
	if(!checked_area)
		return null
	return format_text ? format_text(checked_area.name) : checked_area.name

//We used to use linear regression to approximate the answer, but Mloc realized this was actually faster.
//And lo and behold, it is, and it's more accurate to boot.
///Calculate the hypotenuse cheaply (this should be in maths.dm)
/proc/cheap_hypotenuse(Ax, Ay, Bx, By)
	return sqrt(abs(Ax - Bx) ** 2 + abs(Ay - By) ** 2) //A squared + B squared = C squared

/** recursive_organ_check
 * inputs: first_object (object to start with)
 * outputs:
 * description: A pseudo-recursive loop based off of the recursive mob check, this check looks for any organs held
 *  within 'first_object', toggling their frozen flag. This check excludes items held within other safe organ
 *  storage units, so that only the lowest level of container dictates whether we do or don't decompose
 */
/proc/recursive_organ_check(atom/first_object)

	var/list/processing_list = list(first_object)
	var/list/processed_list = list()
	var/index = 1
	var/obj/item/organ/found_organ

	while(index <= length(processing_list))

		var/atom/object_to_check = processing_list[index]

		if(istype(object_to_check, /obj/item/organ))
			found_organ = object_to_check
			found_organ.organ_flags ^= ORGAN_FROZEN

		else if(istype(object_to_check, /mob/living/carbon))
			var/mob/living/carbon/mob_to_check = object_to_check
			for(var/organ in mob_to_check.internal_organs)
				found_organ = organ
				found_organ.organ_flags ^= ORGAN_FROZEN

		for(var/atom/contained_to_check in object_to_check) //objects held within other objects are added to the processing list, unless that object is something that can hold organs safely
			if(!processed_list[contained_to_check] && !istype(contained_to_check, /obj/structure/closet/crate/freezer) && !istype(contained_to_check, /obj/structure/closet/secure_closet/freezer))
				processing_list+= contained_to_check

		index++
		processed_list[object_to_check] = object_to_check

	return

///Tries to move an atom to an adjacent turf, return TRUE if successful
/proc/try_move_adjacent(atom/movable/atom_to_move, trydir)
	var/turf/atom_turf = get_turf(atom_to_move)
	if(trydir)
		if(atom_to_move.Move(get_step(atom_turf, trydir)))
			return TRUE
	for(var/direction in (GLOB.cardinals-trydir))
		if(atom_to_move.Move(get_step(atom_turf, direction)))
			return TRUE
	return FALSE

///Return the mob type that is being controlled by a ckey
/proc/get_mob_by_key(key)
	var/ckey = ckey(key)
	for(var/player in GLOB.player_list)
		var/mob/player_mob = player
		if(player_mob.ckey == ckey)
			return player_mob
	return null

///Returns true if the mob that a player is controlling is alive
/proc/considered_alive(datum/mind/player_mind, enforce_human = TRUE)
	if(player_mind?.current)
		if(enforce_human)
			var/mob/living/carbon/human/player_mob
			if(ishuman(player_mind.current))
				player_mob = player_mind.current
			return player_mind.current.stat != DEAD && !issilicon(player_mind.current) && !isbrain(player_mind.current) && (!player_mob || player_mob.dna.species.id != SPECIES_ZOMBIE)
		else if(isliving(player_mind.current))
			return player_mind.current.stat != DEAD
	return FALSE

/**
 * Exiled check
 *
 * Checks if the current body of the mind has an exile implant and is currently in
 * an away mission. Returns FALSE if any of those conditions aren't met.
 */
/proc/considered_exiled(datum/mind/player_mind)
	if(!ishuman(player_mind?.current))
		return FALSE
	for(var/obj/item/implant/implant_check in player_mind.current.implants)
		if(istype(implant_check, /obj/item/implant/exile && player_mind.current.onAwayMission()))
			return TRUE

///Checks if a player is considered AFK
/proc/considered_afk(datum/mind/player_mind)
	return !player_mind || !player_mind.current || !player_mind.current.client || player_mind.current.client.is_afk()

///Return an object with a new maptext (not currently in use)
/proc/screen_text(obj/object_to_change, maptext = "", screen_loc = "CENTER-7,CENTER-7", maptext_height = 480, maptext_width = 480)
	if(!isobj(object_to_change))
		object_to_change = new /atom/movable/screen/text()
	object_to_change.maptext = MAPTEXT(maptext)
	object_to_change.maptext_height = maptext_height
	object_to_change.maptext_width = maptext_width
	object_to_change.screen_loc = screen_loc
	return object_to_change

/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image_to_remove, client/remove_from)
	remove_from?.images -= image_to_remove

///Like remove_image_from_client, but will remove the image from a list of clients
/proc/remove_images_from_clients(image/image_to_remove, list/show_to)
	for(var/client/remove_from in show_to)
		remove_from.images -= image_to_remove

///Add an image to a list of clients and calls a proc to remove it after a duration
/proc/flick_overlay(image/image_to_show, list/show_to, duration)
	for(var/client/add_to in show_to)
		add_to.images += image_to_show
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_images_from_clients, image_to_show, show_to), duration, TIMER_CLIENT_TIME)

///wrapper for flick_overlay(), flicks to everyone who can see the target atom
/proc/flick_overlay_view(image/image_to_show, atom/target, duration)
	var/list/viewing = list()
	for(var/mob/viewer as anything in viewers(target))
		if(viewer.client)
			viewing += viewer.client
	flick_overlay(image_to_show, viewing, duration)

///Get active players who are playing in the round
/proc/get_active_player_count(alive_check = 0, afk_check = 0, human_check = 0)
	var/active_players = 0
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/player_mob = GLOB.player_list[i]
		if(!player_mob?.client)
			continue
		if(alive_check && player_mob.stat)
			continue
		else if(afk_check && player_mob.client.is_afk())
			continue
		else if(human_check && !ishuman(player_mob))
			continue
		else if(isnewplayer(player_mob)) // exclude people in the lobby
			continue
		else if(isobserver(player_mob)) // Ghosts are fine if they were playing once (didn't start as observers)
			var/mob/dead/observer/ghost_player = player_mob
			if(ghost_player.started_as_observer) // Exclude people who started as observers
				continue
		active_players++
	return active_players

///Show the poll window to the candidate mobs
/proc/show_candidate_poll_window(mob/candidate_mob, poll_time, question, list/candidates, ignore_category, time_passed, flashwindow = TRUE)
	set waitfor = 0

	SEND_SOUND(candidate_mob, 'sound/misc/notice2.ogg') //Alerting them to their consideration
	if(flashwindow)
		window_flash(candidate_mob.client)
	var/list/answers = ignore_category ? list("Yes", "No", "Never for this round") : list("Yes", "No")
	switch(tgui_alert(candidate_mob, question, "A limited-time offer!", answers, poll_time, autofocus = FALSE))
		if("Yes")
			to_chat(candidate_mob, span_notice("Choice registered: Yes."))
			if(time_passed + poll_time <= world.time)
				to_chat(candidate_mob, span_danger("Sorry, you answered too late to be considered!"))
				SEND_SOUND(candidate_mob, 'sound/machines/buzz-sigh.ogg')
				candidates -= candidate_mob
			else
				candidates += candidate_mob
		if("No")
			to_chat(candidate_mob, span_danger("Choice registered: No."))
			candidates -= candidate_mob
		if("Never for this round")
			var/list/ignore_list = GLOB.poll_ignore[ignore_category]
			if(!ignore_list)
				GLOB.poll_ignore[ignore_category] = list()
			GLOB.poll_ignore[ignore_category] += candidate_mob.ckey
			to_chat(candidate_mob, span_danger("Choice registered: Never for this round."))
			candidates -= candidate_mob
		else
			candidates -= candidate_mob

///Wrapper to send all ghosts the poll to ask them if they want to be considered for a mob.
/proc/poll_ghost_candidates(question, jobban_type, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	return poll_candidates(question, jobban_type, be_special_flag, poll_time, ignore_category, flashwindow, candidates)

///Calls the show_candidate_poll_window() to all eligible ghosts
/proc/poll_candidates(question, jobban_type, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE, list/group = null)
	var/time_passed = world.time
	if (!question)
		question = "Would you like to be a special role?"
	var/list/result = list()
	for(var/candidate in group)
		var/mob/candidate_mob = candidate
		if(!candidate_mob.key || !candidate_mob.client || (ignore_category && GLOB.poll_ignore[ignore_category] && (candidate_mob.ckey in GLOB.poll_ignore[ignore_category])))
			continue
		if(be_special_flag)
			if(!(candidate_mob.client.prefs) || !(be_special_flag in candidate_mob.client.prefs.be_special))
				continue

			var/required_time = GLOB.special_roles[be_special_flag] || 0
			if (candidate_mob.client && candidate_mob.client.get_remaining_days(required_time) > 0)
				continue
		if(jobban_type)
			if(is_banned_from(candidate_mob.ckey, list(jobban_type, ROLE_SYNDICATE)) || QDELETED(candidate_mob))
				continue

		show_candidate_poll_window(candidate_mob, poll_time, question, result, ignore_category, time_passed, flashwindow)
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off or get deleted during the wait period.
	for(var/mob/asking_mob in result)
		if(!asking_mob.key || !asking_mob.client)
			result -= asking_mob

	list_clear_nulls(result)

	return result

/**
 * Returns a list of ghosts that are eligible to take over and wish to be considered for a mob.
 *
 * Arguments:
 * * question - question to show players as part of poll
 * * jobban_type - Type of jobban to use to filter out potential candidates.
 * * be_special_flag - Unknown/needs further documentation.
 * * poll_time - Length of time in deciseconds that the poll input box exists before closing.
 * * target_mob - The mob that is being polled for.
 * * ignore_category - Unknown/needs further documentation.
 */
/proc/poll_candidates_for_mob(question, jobban_type, be_special_flag = 0, poll_time = 30 SECONDS, mob/target_mob, ignore_category = null)
	var/static/list/mob/currently_polling_mobs = list()

	if(currently_polling_mobs.Find(target_mob))
		return list()

	currently_polling_mobs += target_mob

	var/list/possible_candidates = poll_ghost_candidates(question, jobban_type, be_special_flag, poll_time, ignore_category)

	currently_polling_mobs -= target_mob
	if(!target_mob || QDELETED(target_mob) || !target_mob.loc)
		return list()

	return possible_candidates

/**
 * Returns a list of ghosts that are eligible to take over and wish to be considered for a mob.
 *
 * Arguments:
 * * question - question to show players as part of poll
 * * jobban_type - Type of jobban to use to filter out potential candidates.
 * * be_special_flag - Unknown/needs further documentation.
 * * poll_time - Length of time in deciseconds that the poll input box exists before closing.
 * * mobs - The list of mobs being polled for. This list is mutated and invalid mobs are removed from it before the proc returns.
 * * ignore_category - Unknown/needs further documentation.
 */
/proc/poll_candidates_for_mobs(question, jobban_type, be_special_flag = 0, poll_time = 30 SECONDS, list/mobs, ignore_category = null)
	var/list/candidate_list = poll_ghost_candidates(question, jobban_type, be_special_flag, poll_time, ignore_category)

	for(var/mob/potential_mob as anything in mobs)
		if(QDELETED(potential_mob) || !potential_mob.loc)
			mobs -= potential_mob

	if(!length(mobs))
		return list()

	return candidate_list

///Uses stripped down and bastardized code from respawn character
/proc/make_body(mob/dead/observer/ghost_player)
	if(!ghost_player || !ghost_player.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	ghost_player.client.prefs.safe_transfer_prefs_to(new_character)
	new_character.dna.update_dna_identity()
	new_character.key = ghost_player.key

	return new_character

///sends a whatever to all playing players; use instead of to_chat(world, where needed)
/proc/send_to_playing_players(thing)
	for(var/player_mob in GLOB.player_list)
		if(player_mob && !isnewplayer(player_mob))
			to_chat(player_mob, thing)

///Flash the window of a player
/proc/window_flash(client/flashed_client, ignorepref = FALSE)
	if(ismob(flashed_client))
		var/mob/player_mob = flashed_client
		if(player_mob.client)
			flashed_client = player_mob.client
	if(!flashed_client || (!flashed_client.prefs.read_preference(/datum/preference/toggle/window_flashing) && !ignorepref))
		return
	winset(flashed_client, "mainwindow", "flash=5")

///Recursively checks if an item is inside a given type, even through layers of storage. Returns the atom if it finds it.
/proc/recursive_loc_check(atom/movable/target, type)
	var/atom/atom_to_find = target
	if(istype(atom_to_find, type))
		return atom_to_find

	while(!istype(atom_to_find.loc, type))
		if(!atom_to_find.loc)
			return
		atom_to_find = atom_to_find.loc

	return atom_to_find.loc

///Send a message in common radio when a player arrives
/proc/announce_arrival(mob/living/carbon/human/character, rank)
	if(!SSticker.IsRoundInProgress() || QDELETED(character))
		return
	var/area/player_area = get_area(character)
	deadchat_broadcast("<span class='game'> has arrived at the station at <span class='name'>[player_area.name]</span>.</span>", "<span class='game'><span class='name'>[character.real_name]</span> ([rank])</span>", follow_target = character, message_type=DEADCHAT_ARRIVALRATTLE)
	if(!character.mind)
		return
	if(!GLOB.announcement_systems.len)
		return
	if(!(character.mind.assigned_role.job_flags & JOB_ANNOUNCE_ARRIVAL))
		return

	var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
	announcer.announce("ARRIVAL", character.real_name, rank, list()) //make the list empty to make it announce it in common

///Check if the turf pressure allows specialized equipment to work
/proc/lavaland_equipment_pressure_check(turf/turf_to_check)
	. = FALSE
	if(!istype(turf_to_check))
		return
	var/datum/gas_mixture/environment = turf_to_check.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE

///Find an obstruction free turf that's within the range of the center. Can also condition on if it is of a certain area type.
/proc/find_obstruction_free_location(range, atom/center, area/specific_area)
	var/list/possible_loc = list()

	for(var/turf/found_turf as anything in RANGE_TURFS(range, center))
		// We check if both the turf is a floor, and that it's actually in the area.
		// We also want a location that's clear of any obstructions.
		if (specific_area && !istype(get_area(found_turf), specific_area))
			continue

		if (!isgroundlessturf(found_turf) && !found_turf.is_blocked_turf())
			possible_loc.Add(found_turf)

	// Need at least one free location.
	if (possible_loc.len < 1)
		return FALSE

	return pick(possible_loc)

///Disable power in the station APCs
/proc/power_fail(duration_min, duration_max)
	for(var/obj/machinery/power/apc/current_apc as anything in GLOB.apcs_list)
		if(!current_apc.cell || !SSmapping.level_trait(current_apc.z, ZTRAIT_STATION))
			continue
		var/area/apc_area = current_apc.area
		if(GLOB.typecache_powerfailure_safe_areas[apc_area.type])
			continue

		current_apc.energy_fail(rand(duration_min,duration_max))

/**
 * Sends a round tip to a target. If selected_tip is null, a random tip will be sent instead (5% chance of it being silly).
 * Tips that starts with the @ character won't be html encoded. That's necessary for any tip containing markup tags,
 * just make sure they don't also have html characters like <, > and ' which will be garbled.
 */
/proc/send_tip_of_the_round(target, selected_tip)
	var/message
	if(selected_tip)
		message = selected_tip
	else
		var/list/randomtips = world.file2list("strings/tips.txt")
		var/list/memetips = world.file2list("strings/sillytips.txt")
		if(randomtips.len && prob(95))
			message = pick(randomtips)
		else if(memetips.len)
			message = pick(memetips)

	if(!message)
		return
	if(message[1] != "@")
		message = html_encode(message)
	else
		message = copytext(message, 2)
	to_chat(target, span_purple(examine_block("<span class='oocplain'><b>Tip of the round: </b>[message]</span>")))
