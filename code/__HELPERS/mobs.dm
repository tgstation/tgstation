/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_eye_color()
	switch(pick(20;"brown",20;"hazel",20;"grey",15;"blue",15;"green",1;"amber",1;"albino"))
		if("brown")
			return "630"
		if("hazel")
			return "542"
		if("grey")
			return pick("666","777","888","999","aaa","bbb","ccc")
		if("blue")
			return "36c"
		if("green")
			return "060"
		if("amber")
			return "fc0"
		if("albino")
			return pick("c","d","e","f") + pick("0","1","2","3","4","5","6","7","8","9") + pick("0","1","2","3","4","5","6","7","8","9")
		else
			return "000"

/proc/random_underwear(gender)
	if(!GLOB.underwear_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.underwear_m)
		if(FEMALE)
			return pick(GLOB.underwear_f)
		else
			return pick(GLOB.underwear_list)

/proc/random_undershirt(gender)
	if(!GLOB.undershirt_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.undershirt_m)
		if(FEMALE)
			return pick(GLOB.undershirt_f)
		else
			return pick(GLOB.undershirt_list)

/proc/random_socks()
	if(!GLOB.socks_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list)
	return pick(GLOB.socks_list)

/proc/random_backpack()
	return pick(GLOB.backpacklist)

/proc/random_features()
	if(!GLOB.tails_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human)
	if(!GLOB.tails_list_lizard.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard)
	if(!GLOB.snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list)
	if(!GLOB.horns_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, GLOB.horns_list)
	if(!GLOB.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.horns_list)
	if(!GLOB.frills_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list)
	if(!GLOB.spines_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list)
	if(!GLOB.legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list)
	if(!GLOB.body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list)
	if(!GLOB.wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	if(!GLOB.moth_wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list)
	if(!GLOB.moth_antennae_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, GLOB.moth_antennae_list)
	if(!GLOB.moth_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, GLOB.moth_markings_list)
	//For now we will always return none for tail_human and ears.
	return(list("mcolor" = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"),"ethcolor" = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)], "tail_lizard" = pick(GLOB.tails_list_lizard), "tail_human" = "None", "wings" = "None", "snout" = pick(GLOB.snouts_list), "horns" = pick(GLOB.horns_list), "ears" = "None", "frills" = pick(GLOB.frills_list), "spines" = pick(GLOB.spines_list), "body_markings" = pick(GLOB.body_markings_list), "legs" = "Normal Legs", "caps" = pick(GLOB.caps_list), "moth_wings" = pick(GLOB.moth_wings_list), "moth_antennae" = pick(GLOB.moth_antennae_list), "moth_markings" = pick(GLOB.moth_markings_list), "tail_monkey" = "None"))

/proc/random_hairstyle(gender)
	switch(gender)
		if(MALE)
			return pick(GLOB.hairstyles_male_list)
		if(FEMALE)
			return pick(GLOB.hairstyles_female_list)
		else
			return pick(GLOB.hairstyles_list)

/proc/random_facial_hairstyle(gender)
	switch(gender)
		if(MALE)
			return pick(GLOB.facial_hairstyles_male_list)
		if(FEMALE)
			return pick(GLOB.facial_hairstyles_female_list)
		else
			return pick(GLOB.facial_hairstyles_list)

/proc/random_unique_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender==FEMALE)
			. = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			. = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

		if(!findname(.))
			break

/proc/random_unique_lizard_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(lizard_name(gender))

		if(!findname(.))
			break

/proc/random_unique_plasmaman_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(plasmaman_name())

		if(!findname(.))
			break

/proc/random_unique_ethereal_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(ethereal_name())

		if(!findname(.))
			break

/proc/random_unique_moth_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(pick(GLOB.moth_first)) + " " + capitalize(pick(GLOB.moth_last))

		if(!findname(.))
			break

/proc/random_skin_tone()
	return pick(GLOB.skin_tones)

GLOBAL_LIST_INIT(skin_tones, sortList(list(
	"albino",
	"caucasian1",
	"caucasian2",
	"caucasian3",
	"latino",
	"mediterranean",
	"asian1",
	"asian2",
	"arab",
	"indian",
	"african1",
	"african2"
	)))

GLOBAL_LIST_EMPTY(species_list)

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"


///Timed action involving two mobs, the user and the target. interaction_key is the assoc key under which the do_after is capped under, and the max interaction count is how many of this interaction you can do at once.
/proc/do_mob(mob/user, mob/target, time = 3 SECONDS, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1)
	if(!user || !target)
		return FALSE
	var/user_loc = user.loc

	var/drifting = FALSE
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = TRUE

	var/target_loc = target.loc

	if(!interaction_key && target)
		interaction_key = target //Use the direct ref to the target
	if(interaction_key) //Do we have a interaction_key now?
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		if(current_interaction_count >= max_interact_count) //We are at our peak
			return
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, time, target)
	if(target.pixel_x != 0) //shifts the progress bar if target has an offset sprite
		progbar.bar.pixel_x -= target.pixel_x

	var/endtime = world.time+time
	var/starttime = world.time
	. = TRUE

	while (world.time < endtime)
		stoplag(1)

		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = FALSE
			user_loc = user.loc

		if(
			QDELETED(user) || QDELETED(target) \
			|| (!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && !drifting && user.loc != user_loc) \
			|| (!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && target.loc != target_loc) \
			|| (!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding) \
			|| (!(timed_action_flags & IGNORE_INCAPACITATED) && HAS_TRAIT(user, TRAIT_INCAPACITATED)) \
			|| (extra_checks && !extra_checks.Invoke()) \
			)
			. = FALSE
			break

	if(!QDELETED(progbar))
		progbar.end_progress()

	if(interaction_key)
		LAZYREMOVE(user.do_afters, interaction_key)


//some additional checks as a callback for for do_afters that want to break on losing health or on the mob taking action
/mob/proc/break_do_after_checks(list/checked_health, check_clicks)
	if(check_clicks && next_move > world.time)
		return FALSE
	return TRUE

//pass a list in the format list("health" = mob's health var) to check health during this
/mob/living/break_do_after_checks(list/checked_health, check_clicks)
	if(islist(checked_health))
		if(health < checked_health["health"])
			return FALSE
		checked_health["health"] = health
	return ..()


/**
 * Timed action involving one mob user. Target is optional.
 *
 * Checks that `user` does not move, change hands, get stunned, etc. for the
 * given `delay`. Returns `TRUE` on success or `FALSE` on failure.
 * Interaction_key is the assoc key under which the do_after is capped, with max_interact_count being the cap. Interaction key will default to target if not set.
 */
/proc/do_after(mob/user, delay, atom/target, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1)
	if(!user)
		return FALSE
	var/atom/target_loc = null
	if(target && !isturf(target))
		target_loc = target.loc

	if(!interaction_key && target)
		interaction_key = target //Use the direct ref to the target
	if(interaction_key) //Do we have a interaction_key now?
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		if(current_interaction_count >= max_interact_count) //We are at our peak
			return
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)

	var/atom/user_loc = user.loc

	var/drifting = FALSE
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = TRUE

	var/holding = user.get_active_held_item()

	delay *= user.cached_multiplicative_actions_slowdown

	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, delay, target || user)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)

		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = FALSE
			user_loc = user.loc

		if(
			QDELETED(user) \
			|| (!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && !drifting && user.loc != user_loc) \
			|| (!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding) \
			|| (!(timed_action_flags & IGNORE_INCAPACITATED) && HAS_TRAIT(user, TRAIT_INCAPACITATED)) \
			|| (extra_checks && !extra_checks.Invoke()) \
		)
			. = FALSE
			break

		if(
			!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) \
			&& !drifting \
			&& !QDELETED(target_loc) \
			&& (QDELETED(target) || target_loc != target.loc) \
			&& ((user_loc != target_loc || target_loc != user)) \
			)
			. = FALSE
			break

	if(!QDELETED(progbar))
		progbar.end_progress()

	if(interaction_key)
		LAZYREMOVE(user.do_afters, interaction_key)


///Timed action involving at least one mob user and a list of targets. interaction_key is the assoc key under which the do_after is capped under, and the max interaction count is how many of this interaction you can do at once.
/proc/do_after_mob(mob/user, list/targets, time = 3 SECONDS, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1)
	if(!user)
		return FALSE
	if(!islist(targets))
		targets = list(targets)
	if(!length(targets))
		return FALSE
	var/user_loc = user.loc

	time *= user.cached_multiplicative_actions_slowdown

	var/drifting = FALSE
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = TRUE

	var/list/originalloc = list()

	for(var/atom/target in targets)
		originalloc[target] = target.loc

	if(interaction_key)
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		if(current_interaction_count >= max_interact_count) //We are at our peak
			to_chat(user, "<span class='warning'>You can't do this at the moment!</span>")
			return
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)


	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, targets[1])

	var/endtime = world.time + time
	var/starttime = world.time
	. = TRUE
	while(world.time < endtime)
		stoplag(1)

		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)
		if(QDELETED(user) || !length(targets))
			. = FALSE
			break

		if(drifting && !user.inertia_dir)
			drifting = FALSE
			user_loc = user.loc

		if(
			(!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && !drifting && user_loc != user.loc) \
			|| (!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding) \
			|| (!(timed_action_flags & IGNORE_INCAPACITATED) && HAS_TRAIT(user, TRAIT_INCAPACITATED)) \
			|| (extra_checks && !extra_checks.Invoke()) \
			)
			. = FALSE
			break

		for(var/t in targets)
			var/atom/target = t
			if(
				(QDELETED(target)) \
				|| (!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && originalloc[target] != target.loc) \
				)
				. = FALSE
				break

		if(!.) // In case the for-loop found a reason to break out of the while.
			break

	if(!QDELETED(progbar))
		progbar.end_progress()

	if(interaction_key)
		LAZYREMOVE(user.do_afters, interaction_key)

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE, list/extra_args)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/new_args = list(T)
	if(extra_args)
		new_args += extra_args
	var/atom/X
	for(var/j in 1 to amount)
		X = new spawn_type(arglist(new_args))
		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1
	return X //return the last mob spawned

/proc/spawn_and_random_walk(spawn_type, target, amount, walk_chance=100, max_walk=3, always_max_walk=FALSE, admin_spawn=FALSE)
	var/turf/T = get_turf(target)
	var/step_count = 0
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/spawned_mobs = new(amount)

	for(var/j in 1 to amount)
		var/atom/movable/X

		if (istype(spawn_type, /list))
			var/mob_type = pick(spawn_type)
			X = new mob_type(T)
		else
			X = new spawn_type(T)

		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1

		spawned_mobs[j] = X

		if(always_max_walk || prob(walk_chance))
			if(always_max_walk)
				step_count = max_walk
			else
				step_count = rand(1, max_walk)

			for(var/i in 1 to step_count)
				step(X, pick(NORTH, SOUTH, EAST, WEST))

	return spawned_mobs

// Displays a message in deadchat, sent by source. source is not linkified, message is, to avoid stuff like character names to be linkified.
// Automatically gives the class deadsay to the whole message (message + source)
/proc/deadchat_broadcast(message, source=null, mob/follow_target=null, turf/turf_target=null, speaker_key=null, message_type=DEADCHAT_REGULAR, admin_only=FALSE)
	message = "<span class='deadsay'>[source]<span class='linkify'>[message]</span></span>"

	for(var/mob/M in GLOB.player_list)
		var/chat_toggles = TOGGLES_DEFAULT_CHAT
		var/toggles = TOGGLES_DEFAULT
		var/list/ignoring
		if(M.client.prefs)
			var/datum/preferences/prefs = M.client.prefs
			chat_toggles = prefs.chat_toggles
			toggles = prefs.toggles
			ignoring = prefs.ignoring
		if(admin_only)
			if (!M.client.holder)
				return
			else
				message += "<span class='deadsay'> (This is viewable to admins only).</span>"
		var/override = FALSE
		if(M.client.holder && (chat_toggles & CHAT_DEAD))
			override = TRUE
		if(HAS_TRAIT(M, TRAIT_SIXTHSENSE) && message_type == DEADCHAT_REGULAR)
			override = TRUE
		if(SSticker.current_state == GAME_STATE_FINISHED)
			override = TRUE
		if(isnewplayer(M) && !override)
			continue
		if(M.stat != DEAD && !override)
			continue
		if(speaker_key && (speaker_key in ignoring))
			continue

		switch(message_type)
			if(DEADCHAT_DEATHRATTLE)
				if(toggles & DISABLE_DEATHRATTLE)
					continue
			if(DEADCHAT_ARRIVALRATTLE)
				if(toggles & DISABLE_ARRIVALRATTLE)
					continue
			if(DEADCHAT_LAWCHANGE)
				if(!(chat_toggles & CHAT_GHOSTLAWS))
					continue
			if(DEADCHAT_LOGIN_LOGOUT)
				if(!(chat_toggles & CHAT_LOGIN_LOGOUT))
					continue

		if(isobserver(M))
			var/rendered_message = message

			if(follow_target)
				var/F
				if(turf_target)
					F = FOLLOW_OR_TURF_LINK(M, follow_target, turf_target)
				else
					F = FOLLOW_LINK(M, follow_target)
				rendered_message = "[F] [message]"
			else if(turf_target)
				var/turf_link = TURF_LINK(M, turf_target)
				rendered_message = "[turf_link] [message]"

			to_chat(M, rendered_message)
		else
			to_chat(M, message)

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(mob_spawn_meancritters.len <= 0 || mob_spawn_nicecritters.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/simple_animal/C = new chosen(spawn_location)
	return C

/proc/passtable_on(target, source)
	var/mob/living/L = target
	if (!HAS_TRAIT(L, TRAIT_PASSTABLE) && L.pass_flags & PASSTABLE)
		ADD_TRAIT(L, TRAIT_PASSTABLE, INNATE_TRAIT)
	ADD_TRAIT(L, TRAIT_PASSTABLE, source)
	L.pass_flags |= PASSTABLE

/proc/passtable_off(target, source)
	var/mob/living/L = target
	REMOVE_TRAIT(L, TRAIT_PASSTABLE, source)
	if(!HAS_TRAIT(L, TRAIT_PASSTABLE))
		L.pass_flags &= ~PASSTABLE

/proc/dance_rotate(atom/movable/AM, datum/callback/callperrotate, set_original_dir=FALSE)
	set waitfor = FALSE
	var/originaldir = AM.dir
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		if(!AM)
			return
		AM.setDir(i)
		callperrotate?.Invoke()
		sleep(1)
	if(set_original_dir)
		AM.setDir(originaldir)

///////////////////////
///Silicon Mob Procs///
///////////////////////

//Returns a list of unslaved cyborgs
/proc/active_free_borgs()
	. = list()
	for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
		if(R.connected_ai || R.shell)
			continue
		if(R.stat == DEAD)
			continue
		if(R.emagged || R.scrambledcodes)
			continue
		. += R

//Returns a list of AI's
/proc/active_ais(check_mind=FALSE, z = null)
	. = list()
	for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled)
			continue
		if(check_mind)
			if(!A.mind)
				continue
		if(z && !(z == A.z) && (!is_station_level(z) || !is_station_level(A.z))) //if a Z level was specified, AND the AI is not on the same level, AND either is off the station...
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs(z)
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais(FALSE, z)
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots.len > A.connected_robots.len))
			selected = A

	return selected

/proc/select_active_free_borg(mob/user)
	var/list/borgs = active_free_borgs()
	if(borgs.len)
		if(user)
			. = input(user,"Unshackled cyborg signals detected:", "Cyborg Selection", borgs[1]) in sortList(borgs)
		else
			. = pick(borgs)
	return .

/proc/select_active_ai(mob/user, z = null)
	var/list/ais = active_ais(FALSE, z)
	if(ais.len)
		if(user)
			. = input(user,"AI signals detected:", "AI Selection", ais[1]) in sortList(ais)
		else
			. = pick(ais)
	return .

/**
 * Used to get the amount of change between two body temperatures
 *
 * When passed the difference between two temperatures returns the amount of change to temperature to apply.
 * The change rate should be kept at a low value tween 0.16 and 0.02 for optimal results.
 * vars:
 * * temp_diff (required) The differance between two temperatures
 * * change_rate (optional)(Default: 0.06) The rate of range multiplyer
 */
/proc/get_temp_change_amount(temp_diff, change_rate = 0.06)
	if(temp_diff < 0)
		return -(BODYTEMP_AUTORECOVERY_DIVISOR / 2) * log(1 - (temp_diff * change_rate))
	return (BODYTEMP_AUTORECOVERY_DIVISOR / 2) * log(1 + (temp_diff * change_rate))

#define ISADVANCEDTOOLUSER(mob) (HAS_TRAIT(mob, TRAIT_ADVANCEDTOOLUSER) && !HAS_TRAIT(mob, TRAIT_MONKEYLIKE))

/// Gets the client of the mob, allowing for mocking of the client.
/// You only need to use this if you know you're going to be mocking clients somewhere else.
#define GET_CLIENT(mob) (##mob.client || ##mob.mock_client)
