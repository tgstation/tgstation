//check_target_facings() return defines
/// Two mobs are facing the same direction
#define FACING_SAME_DIR 1
/// Two mobs are facing each others
#define FACING_EACHOTHER 2
/// Two mobs one is facing a person, but the other is perpendicular
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR 3 //Do I win the most informative but also most stupid define award?

/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_eye_color()
	switch(pick(20;"brown",20;"hazel",20;"grey",15;"blue",15;"green",1;"amber",1;"albino"))
		if("brown")
			return COLOR_BROWNER_BROWN
		if("hazel")
			return "#554422"
		if("grey")
			return pick("#666666","#777777","#888888","#999999","#aaaaaa","#bbbbbb","#cccccc")
		if("blue")
			return "#3366cc"
		if("green")
			return "#006600"
		if("amber")
			return "#ffcc00"
		if("albino")
			return "#" + pick("cc","dd","ee","ff") + pick("00","11","22","33","44","55","66","77","88","99") + pick("00","11","22","33","44","55","66","77","88","99")
		else
			return COLOR_BLACK

/proc/random_hair_color()
	var/static/list/natural_hair_colors = list(
		"#111111", "#362925", "#3B3831", "#41250C", "#412922",
		"#544C49", "#583322", "#593029", "#703b30", "#714721",
		"#744729", "#74482a", "#7b746e", "#855832", "#863019",
		"#8c4734", "#9F550E", "#A29A96", "#A4381C", "#B17B41",
		"#C0BAB7", "#EFE5E4", "#F7F3F1", "#FFF2D6", "#a15537",
		"#a17e61", "#b38b67", "#ba673c", "#c89f73", "#d9b380",
		"#dbc9b8", "#e1621d", "#e17d17", "#e1af93", "#f1cc8f",
		"#fbe7a1",
	)

	return pick(natural_hair_colors)

/proc/random_underwear(gender)
	if(length(SSaccessories.underwear_list) == 0)
		CRASH("No underwear to choose from!")
	switch(gender)
		if(MALE)
			return pick(SSaccessories.underwear_m)
		if(FEMALE)
			return pick(SSaccessories.underwear_f)
		else
			return pick(SSaccessories.underwear_list)

/proc/random_undershirt(gender)
	if(length(SSaccessories.undershirt_list) == 0)
		CRASH("No undershirts to choose from!")
	switch(gender)
		if(MALE)
			return pick(SSaccessories.undershirt_m)
		if(FEMALE)
			return pick(SSaccessories.undershirt_f)
		else
			return pick(SSaccessories.undershirt_list)

/proc/random_socks()
	if(length(SSaccessories.socks_list) == 0)
		CRASH("No socks to choose from!")
	return pick(SSaccessories.socks_list)

/proc/random_backpack()
	return pick(GLOB.backpacklist)

/proc/random_hairstyle(gender)
	switch(gender)
		if(MALE)
			return pick(SSaccessories.hairstyles_male_list)
		if(FEMALE)
			return pick(SSaccessories.hairstyles_female_list)
		else
			return pick(SSaccessories.hairstyles_list)

/proc/random_facial_hairstyle(gender)
	switch(gender)
		if(MALE)
			return pick(SSaccessories.facial_hairstyles_male_list)
		if(FEMALE)
			return pick(SSaccessories.facial_hairstyles_female_list)
		else
			return pick(SSaccessories.facial_hairstyles_list)

GLOBAL_LIST_INIT(skin_tones, sort_list(list(
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
	"mixed1",
	"mixed2",
	"mixed3",
	"mixed4",
	"african1",
	"african2"
	)))

GLOBAL_LIST_INIT(skin_tone_names, list(
	"african1" = "Medium brown",
	"african2" = "Dark brown",
	"albino" = "Albino",
	"arab" = "Light brown",
	"asian1" = "Ivory",
	"asian2" = "Beige",
	"caucasian1" = "Porcelain",
	"caucasian2" = "Light peach",
	"caucasian3" = "Peach",
	"indian" = "Brown",
	"latino" = "Light beige",
	"mediterranean" = "Olive",
	"mixed1" = "Chestnut",
	"mixed2" = "Walnut",
	"mixed3" = "Coffee",
	"mixed4" = "Macadamia",
))

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
 *
 * @param {mob} user - The mob performing the action.
 *
 * @param {number} delay - The time in deciseconds. Use the SECONDS define for readability. `1 SECONDS` is 10 deciseconds.
 *
 * @param {atom} target - The target of the action. This is where the progressbar will display.
 *
 * @param {flag} timed_action_flags - Flags to control the behavior of the timed action.
 *
 * @param {boolean} progress - Whether to display a progress bar / cogbar.
 *
 * @param {datum/callback} extra_checks - Additional checks to perform before the action is executed.
 *
 * @param {string} interaction_key - The assoc key under which the do_after is capped, with max_interact_count being the cap. Interaction key will default to target if not set.
 *
 * @param {number} max_interact_count - The maximum amount of interactions allowed.
 *
 * @param {boolean} hidden - By default, any action 1 second or longer shows a cog over the user while it is in progress. If hidden is set to TRUE, the cog will not be shown.
 */
/proc/do_after(mob/user, delay, atom/target, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1, hidden = FALSE)
	if(!user)
		return FALSE
	if(!isnum(delay))
		CRASH("do_after was passed a non-number delay: [delay || "null"].")

	if(!interaction_key && target)
		interaction_key = target //Use the direct ref to the target
	if(interaction_key) //Do we have a interaction_key now?
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		if(current_interaction_count >= max_interact_count) //We are at our peak
			return
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)

	var/atom/user_loc = user.loc
	var/atom/target_loc = target?.loc

	var/drifting = FALSE
	if(!isnull(user.drift_handler))
		drifting = TRUE

	var/holding = user.get_active_held_item()

	if(!(timed_action_flags & IGNORE_SLOWDOWNS))
		delay *= user.cached_multiplicative_actions_slowdown

	var/datum/progressbar/progbar
	var/datum/cogbar/cog

	if(progress)
		if(user.client)
			progbar = new(user, delay, target || user)

		if(!hidden && delay >= 1 SECONDS)
			cog = new(user)

	SEND_SIGNAL(user, COMSIG_DO_AFTER_BEGAN)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)

		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

		if(drifting && isnull(user.drift_handler))
			drifting = FALSE
			user_loc = user.loc

		if(QDELETED(user) \
			|| (!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && !drifting && user.loc != user_loc) \
			|| (!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding) \
			|| (!(timed_action_flags & IGNORE_INCAPACITATED) && HAS_TRAIT(user, TRAIT_INCAPACITATED)) \
			|| (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(target && (user != target) && \
			(QDELETED(target) \
			|| (!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && target.loc != target_loc)))
			. = FALSE
			break

	if(!QDELETED(progbar))
		progbar.end_progress()

	cog?.remove()

	if(interaction_key)
		var/reduced_interaction_count = (LAZYACCESS(user.do_afters, interaction_key) || 0) - 1
		if(reduced_interaction_count > 0) // Not done yet!
			LAZYSET(user.do_afters, interaction_key, reduced_interaction_count)
			return
		// all out, let's clear er out fully
		LAZYREMOVE(user.do_afters, interaction_key)
	SEND_SIGNAL(user, COMSIG_DO_AFTER_ENDED)

/// Returns the total amount of do_afters this mob is taking part in
/mob/proc/do_after_count()
	var/count = 0
	for(var/key in do_afters)
		count += do_afters[key]
	return count

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/// Returns if the given target is a human. Like, a REAL human.
/// Not a moth, not a felinid (which are human subtypes), but a human.
/proc/ishumanbasic(target)
	if (!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	return human_target.dna?.species?.type == /datum/species/human

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

/proc/spawn_and_random_walk(spawn_type, target, amount, walk_chance=100, max_walk=3, always_max_walk=FALSE, admin_spawn=FALSE, cardinals_only = TRUE)
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
				step(X, cardinals_only ? pick(GLOB.cardinals) : pick(GLOB.alldirs))

	return spawned_mobs

// Displays a message in deadchat, sent by source. source is not linkified, message is, to avoid stuff like character names to be linkified.
// Automatically gives the class deadsay to the whole message (message + source)
/proc/deadchat_broadcast(message, source=null, mob/follow_target=null, turf/turf_target=null, speaker_key=null, message_type=DEADCHAT_REGULAR, admin_only=FALSE)
	message = span_deadsay("[source][span_linkify(message)]")

	if(admin_only)
		message += span_deadsay(" (This is viewable to admins only).")

	for(var/mob/M in GLOB.player_list)
		var/chat_toggles = TOGGLES_DEFAULT_CHAT
		var/toggles = TOGGLES_DEFAULT
		var/list/ignoring
		if(M.client?.prefs)
			var/datum/preferences/prefs = M.client?.prefs
			chat_toggles = prefs.chat_toggles
			toggles = prefs.toggles
			ignoring = prefs.ignoring
		if(admin_only)
			if(!M.client?.holder)
				continue
		var/override = FALSE
		if(M.client?.holder && (chat_toggles & CHAT_DEAD))
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

			to_chat(M, rendered_message, avoid_highlighting = speaker_key == M.key)
		else
			to_chat(M, message, avoid_highlighting = speaker_key == M.key)

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
		for(var/mob/living/basic/basic_mob as anything in typesof(/mob/living/basic))
			switch(initial(basic_mob.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += basic_mob
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += basic_mob

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/spawned_mob = new chosen(spawn_location)
	return spawned_mob

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

/proc/passwindow_on(target, source)
	var/mob/living/target_mob = target
	if (!HAS_TRAIT(target_mob, TRAIT_PASSWINDOW) && target_mob.pass_flags & PASSWINDOW)
		ADD_TRAIT(target_mob, TRAIT_PASSWINDOW, INNATE_TRAIT)
	ADD_TRAIT(target_mob, TRAIT_PASSWINDOW, source)
	target_mob.pass_flags |= PASSWINDOW

/proc/passwindow_off(target, source)
	var/mob/living/target_mob = target
	REMOVE_TRAIT(target_mob, TRAIT_PASSWINDOW, source)
	if(!HAS_TRAIT(target_mob, TRAIT_PASSWINDOW))
		target_mob.pass_flags &= ~PASSWINDOW

/proc/dance_rotate(atom/movable/AM, datum/callback/callperrotate, set_original_dir=FALSE)
	set waitfor = FALSE
	var/originaldir = AM.dir
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		if(!AM)
			return
		AM.setDir(i)
		callperrotate?.Invoke()
		sleep(0.1 SECONDS)
	if(set_original_dir)
		AM.setDir(originaldir)

///////////////////////
///Silicon Mob Procs///
///////////////////////

//Returns a list of unslaved cyborgs
/proc/active_free_borgs()
	. = list()
	for(var/mob/living/silicon/robot/borg in GLOB.silicon_mobs)
		if(borg.connected_ai || borg.shell)
			continue
		if(borg.stat == DEAD)
			continue
		if(borg.emagged || borg.scrambledcodes)
			continue
		. += borg

//Returns a list of AI's
/proc/active_ais(check_mind = FALSE, z = null, skip_syndicate = FALSE, only_syndicate = FALSE)
	. = list()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.stat == DEAD)
			continue
		if(ai.control_disabled)
			continue
		var/syndie_ai = istype(ai, /mob/living/silicon/ai/weak_syndie)
		if(skip_syndicate && syndie_ai)
			continue
		if(only_syndicate && !syndie_ai)
			continue
		if(check_mind && !ai.mind)
			continue
		if(!isnull(z) && z != ai.z && (!is_station_level(z) || !is_station_level(ai.z))) //if a Z level was specified, AND the AI is not on the same level, AND either is off the station...
			continue
		. += ai

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
			. = input(user,"Unshackled cyborg signals detected:", "Cyborg Selection", borgs[1]) in sort_list(borgs)
		else
			. = pick(borgs)
	return .

/proc/select_active_ai(mob/user, z = null, skip_syndicate, only_syndicate)
	var/list/ais = active_ais(FALSE, z, skip_syndicate, only_syndicate)
	if(ais.len)
		if(user)
			. = input(user,"AI signals detected:", "AI Selection", ais[1]) in sort_list(ais)
		else
			. = pick(ais)
	return .

/**
 * Used to get the amount of change between two body temperatures
 *
 * When passed the difference between two temperatures returns the amount of change to temperature to apply.
 * The change rate should be kept at a low value tween 0.16 and 0.02 for optimal results.
 * vars:
 * * temp_diff (required) The difference between two temperatures
 * * change_rate (optional)(Default: 0.06) The rate of range multiplier
 */
/proc/get_temp_change_amount(temp_diff, change_rate = 0.06)
	if(temp_diff < 0)
		return -(BODYTEMP_AUTORECOVERY_DIVISOR / 2) * log(1 - (temp_diff * change_rate))
	return (BODYTEMP_AUTORECOVERY_DIVISOR / 2) * log(1 + (temp_diff * change_rate))

#define ISADVANCEDTOOLUSER(mob) (HAS_TRAIT(mob, TRAIT_ADVANCEDTOOLUSER) && !HAS_TRAIT(mob, TRAIT_DISCOORDINATED_TOOL_USER))

/// Gets the client of the mob, allowing for mocking of the client.
/// You only need to use this if you know you're going to be mocking clients somewhere else.
#define GET_CLIENT(mob) (##mob.client || ##mob.mock_client)

///Orders mobs by type then by name. Accepts optional arg to sort a custom list, otherwise copies GLOB.mob_list.
/proc/sort_mobs()
	var/list/moblist = list()
	var/list/sortmob = sort_names(GLOB.mob_list)
	for(var/mob/living/silicon/ai/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/eye/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/silicon/pai/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/silicon/robot/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/carbon/human/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/brain/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/carbon/alien/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/dead/observer/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/dead/new_player/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/basic/slime/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/simple_animal/mob_to_sort in sortmob)
		moblist += mob_to_sort
	for(var/mob/living/basic/mob_to_sort in sortmob)
		moblist += mob_to_sort
		// We've already added slimes.
		if(isslime(mob_to_sort))
			continue
	return moblist

///returns a mob type controlled by a specified ckey
/proc/get_mob_by_ckey(key)
	if(!key)
		return
	var/list/mobs = sort_mobs()
	for(var/mob/mob in mobs)
		if(mob.ckey == key)
			return mob

/// Returns a string for the specified body zone. If we have a bodypart in this zone, refers to its plaintext_zone instead.
/mob/living/proc/parse_zone_with_bodypart(zone)
	var/obj/item/bodypart/part = get_bodypart(zone)

	return part?.plaintext_zone || parse_zone(zone)

///Return a string for the specified body zone. Should be used for parsing non-instantiated bodyparts, otherwise use [/obj/item/bodypart/var/plaintext_zone]
/proc/parse_zone(zone)
	switch(zone)
		if(BODY_ZONE_CHEST)
			return "chest"
		if(BODY_ZONE_HEAD)
			return "head"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "right hand"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "left hand"
		if(BODY_ZONE_L_ARM)
			return "left arm"
		if(BODY_ZONE_R_ARM)
			return "right arm"
		if(BODY_ZONE_L_LEG)
			return "left leg"
		if(BODY_ZONE_R_LEG)
			return "right leg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "left foot"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "right foot"
		if(BODY_ZONE_PRECISE_GROIN)
			return "groin"
		else
			return zone

///Takes a zone and returns its "parent" zone, if it has one.
/proc/deprecise_zone(precise_zone)
	switch(precise_zone)
		if(BODY_ZONE_PRECISE_GROIN)
			return BODY_ZONE_CHEST
		if(BODY_ZONE_PRECISE_EYES)
			return BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_MOUTH)
			return BODY_ZONE_HEAD
		if(BODY_ZONE_PRECISE_R_HAND)
			return BODY_ZONE_R_ARM
		if(BODY_ZONE_PRECISE_L_HAND)
			return BODY_ZONE_L_ARM
		if(BODY_ZONE_PRECISE_L_FOOT)
			return BODY_ZONE_L_LEG
		if(BODY_ZONE_PRECISE_R_FOOT)
			return BODY_ZONE_R_LEG
		else
			return precise_zone

///Returns a list of strings for a given slot flag.
/proc/parse_slot_flags(slot_flags)
	var/list/slot_strings = list()
	if(slot_flags & ITEM_SLOT_BACK)
		slot_strings += "back"
	if(slot_flags & ITEM_SLOT_MASK)
		slot_strings += "mask"
	if(slot_flags & ITEM_SLOT_NECK)
		slot_strings += "neck"
	if(slot_flags & ITEM_SLOT_HANDCUFFED)
		slot_strings += "handcuff"
	if(slot_flags & ITEM_SLOT_LEGCUFFED)
		slot_strings += "legcuff"
	if(slot_flags & ITEM_SLOT_BELT)
		slot_strings += "belt"
	if(slot_flags & ITEM_SLOT_ID)
		slot_strings += "id"
	if(slot_flags & ITEM_SLOT_EARS)
		slot_strings += "ear"
	if(slot_flags & ITEM_SLOT_EYES)
		slot_strings += "glasses"
	if(slot_flags & ITEM_SLOT_GLOVES)
		slot_strings += "glove"
	if(slot_flags & ITEM_SLOT_HEAD)
		slot_strings += "head"
	if(slot_flags & ITEM_SLOT_FEET)
		slot_strings += "shoe"
	if(slot_flags & ITEM_SLOT_OCLOTHING)
		slot_strings += "oversuit"
	if(slot_flags & ITEM_SLOT_ICLOTHING)
		slot_strings += "undersuit"
	if(slot_flags & ITEM_SLOT_SUITSTORE)
		slot_strings += "suit storage"
	if(slot_flags & (ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET))
		slot_strings += "pocket"
	if(slot_flags & ITEM_SLOT_HANDS)
		slot_strings += "hand"
	if(slot_flags & ITEM_SLOT_DEX_STORAGE)
		slot_strings += "dextrous storage"
	if(slot_flags & ITEM_SLOT_BACKPACK)
		slot_strings += "backpack"
	if(slot_flags & ITEM_SLOT_BELTPACK)
		slot_strings += "belt" // ?
	return slot_strings

///Returns the direction that the initiator and the target are facing
/proc/check_target_facings(mob/living/initiator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overridden at the same time*/
	if(!isliving(target) || target.body_position == LYING_DOWN)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FALSE
	if(initiator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_source_facing_target(initiator,target) && is_source_facing_target(target,initiator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initiator.dir + 2 == target.dir || initiator.dir - 2 == target.dir || initiator.dir + 6 == target.dir || initiator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

///Returns the occupant mob or brain from a specified input
/proc/get_mob_or_brainmob(occupant)
	var/mob/living/mob_occupant

	if(isliving(occupant))
		mob_occupant = occupant

	else if(isorgan(occupant))
		var/obj/item/organ/brain/brain = occupant
		mob_occupant = brain.brainmob

	return mob_occupant

///Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
/mob/proc/apply_pref_name(preference_type, client/requesting_client)
	if(!requesting_client)
		requesting_client = client
	var/oldname = real_name
	var/newname
	var/loop = 1
	var/safety = 0

	var/random = CONFIG_GET(flag/force_random_names) || (requesting_client ? is_banned_from(requesting_client.ckey, "Appearance") : FALSE)

	while(loop && safety < 5)
		if(!safety && !random)
			newname = requesting_client?.prefs?.read_preference(preference_type)
		else
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			if (requesting_client?.prefs)
				newname = preference.create_informed_default_value(requesting_client.prefs)
			else
				newname = preference.create_default_value()

		for(var/mob/living/checked_mob in GLOB.player_list)
			if(checked_mob == src)
				continue
			if(!newname || checked_mob.real_name == newname)
				newname = null
				loop++ // name is already taken so we roll again
				break
		loop--
		safety++

	if(newname)
		fully_replace_character_name(oldname, newname)
		return TRUE
	return FALSE

///Returns the amount of currently living players
/proc/living_player_count()
	var/living_player_count = 0
	for(var/mob in GLOB.player_list)
		if(mob in GLOB.alive_mob_list)
			living_player_count += 1
	return living_player_count

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

///Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.set_invis_see(invis_flags)

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	name = "INTERNAL DVIEW MOB"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	move_resist = INFINITY
	var/ready_to_die = FALSE

/mob/dview/Initialize(mapload) //Properly prevents this mob from gaining huds or joining any global lists
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	return INITIALIZE_HINT_NORMAL

/mob/dview/Destroy(force = FALSE)
	if(!ready_to_die)
		stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

		if (!force)
			return QDEL_HINT_LETMELIVE

		log_world("EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS")
		GLOB.dview_mob = new
	return ..()


#define FOR_DVIEW(type, range, center, invis_flags) \
	GLOB.dview_mob.loc = center;           \
	GLOB.dview_mob.set_invis_see(invis_flags); \
	for(type in view(range, GLOB.dview_mob))

#define FOR_DVIEW_END GLOB.dview_mob.loc = null

///Makes a call in the context of a different usr. Use sparingly
/world/proc/push_usr(mob/user_mob, datum/callback/invoked_callback, ...)
	var/temp = usr
	usr = user_mob
	if (length(args) > 2)
		. = invoked_callback.Invoke(arglist(args.Copy(3)))
	else
		. = invoked_callback.Invoke()
	usr = temp
