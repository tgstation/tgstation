//now what does dancing have to do with cybernetics?
//idk stop asking :) - borbop

// Dancing
/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily."
	muzzle_ignore = TRUE
	hands_use_check = FALSE
	cooldown = 2 SECONDS

/datum/emote/living/dance/run_emote(mob/user, params, type_override, intentional)
	. = TRUE
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	if((user.movement_type & FLOATING) || HAS_TRAIT(user, TRAIT_FLOORED) || HAS_TRAIT(user, TRAIT_INCAPACITATED) \
		|| HAS_TRAIT_NOT_FROM(user, TRAIT_DANCING, EMOTE_TRAIT))
		return FALSE

	var/static/list/possible_affirmative_messages = list(
		"starts dancing!",
		"busts a move!",
		"busts a groove!",
		"boogies!",
		"rocks it out!",
		"goes with the flow!",
		"slams it on the dance floor!",
		"jujus on that beat!",
		"ghost rides the whip!",
		"does the macarena!",
		"does the gangnam style!",
		"does the harlem shake!",
		"does the mario!",
		"does the whip AND nae nae!",
		"starts flossing!",
		"default dances!",,
		"starts mario partying!",
	)
	var/static/list/possible_negative_messages = list(
		"stops dancing!",
		"sobers up!",
		"stops boogying!",
		"loses the flow!",
		"breaks the breakdance!",
		"is no longer goated with the sauce!",
		"no longer has a loose foot!",
	)
	var/is_intentionally_dancing = HAS_TRAIT_FROM(user, TRAIT_DANCING, EMOTE_TRAIT)
	var/msg = is_intentionally_dancing ? pick(possible_negative_messages) : pick(possible_affirmative_messages)
	if(!msg)
		return

	user.log_message(msg, LOG_EMOTE)
	var/dchatmsg = "<span style='color: [user.chat_color];'><b>[user]</b></span> [msg]"

	var/tmp_sound = get_sound(user)
	if(tmp_sound && (!only_forced_audio || !intentional) && !TIMER_COOLDOWN_CHECK(user, type))
		TIMER_COOLDOWN_START(user, type, audio_cooldown)
		playsound(user, tmp_sound, 50, vary)

	var/user_turf = get_turf(user)
	if(user.client)
		for(var/mob/ghost as anything in GLOB.dead_mob_list)
			if(!ghost.client || isnewplayer(ghost))
				continue
			if(ghost.client.prefs?.chat_toggles & CHAT_GHOSTSIGHT && !(ghost in viewers(user_turf, null)))
				ghost.show_message("<span class='emote'>[FOLLOW_LINK(ghost, user)] [dchatmsg]</span>")

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg, audible_message_flags = EMOTE_MESSAGE)
	else
		user.visible_message(msg, visible_message_flags = EMOTE_MESSAGE)

	if(!is_intentionally_dancing)
		user.AddComponent(/datum/component/dancing, EMOTE_TRAIT)
	else
		qdel(user.GetComponent(/datum/component/dancing))
	SEND_SIGNAL(user, COMSIG_MOB_EMOTED(key))


/datum/component/dancing
	/// The source of the dancing trait we give
	var/trait_source = EMOTE_TRAIT
	/// Signals that cause us to detach
	var/static/list/dancing_stop_signals
	///this is our dance
	var/datum/dance/chosen_dance

/datum/component/dancing/Initialize(trait_source)
	. = ..()
	if(!dancing_stop_signals)
		dancing_stop_signals = list(
			SIGNAL_ADDTRAIT(TRAIT_MOVE_FLOATING),
			SIGNAL_ADDTRAIT(TRAIT_FLOORED),
			SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED),
		)
	src.trait_source = trait_source
	if(!HAS_TRAIT(parent, TRAIT_DANCING))
		var/list/dances = typesof(/datum/dance)
		chosen_dance = pick(dances)
		chosen_dance = new chosen_dance
		INVOKE_ASYNC(chosen_dance, TYPE_PROC_REF(/datum/dance, trigger_dance), parent)
	//ADD_TRAIT(target, TRAIT_IMMOBILIZED, trait_source)
	ADD_TRAIT(parent, TRAIT_DANCING, trait_source)
	RegisterSignals(parent, dancing_stop_signals, PROC_REF(stop_dancing))

/datum/component/dancing/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_DANCING, trait_source)
	//REMOVE_TRAIT(source, TRAIT_IMMOBILIZED, trait_source)
	if(!HAS_TRAIT(parent, TRAIT_DANCING))
		chosen_dance?.end_dance(parent)
		QDEL_NULL(chosen_dance)
	UnregisterSignal(parent, dancing_stop_signals)
	. = ..()

/datum/component/dancing/proc/stop_dancing(atom/movable/source)
	SIGNAL_HANDLER

	qdel(src)


/datum/dance
	var/continues = TRUE

/datum/dance/proc/trigger_dance(mob/target)
	animate(target, pixel_y = 2, time = 2, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -2, time = 2, flags = ANIMATION_RELATIVE)

/datum/dance/proc/end_dance(mob/target)
	var/final_pixel_y = target.base_pixel_y
	// Living mobs also have a 'body_position_pixel_y_offset' variable that has to be taken into account here.
	if(isliving(target))
		var/mob/living/living_target = target
		final_pixel_y += living_target.body_position_pixel_y_offset
	animate(target, pixel_y = final_pixel_y, time = 0.5 SECONDS)

/datum/dance/head_spin/trigger_dance(mob/living/target)
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, type)
	animate(target, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	var/matrix/initial_matrix = matrix(target.transform)
	for (var/i in 1 to 60)
		if (!target)
			return
		if(!continues)
			break
		if (i<31)
			initial_matrix = matrix(target.transform)
			initial_matrix.Translate(0,1)
			animate(target, transform = initial_matrix, time = 1, loop = 0)
		if (i>30)
			initial_matrix = matrix(target.transform)
			initial_matrix.Translate(0,-1)
			animate(target, transform = initial_matrix, time = 1, loop = 0)
		target.setDir(turn(target.dir, 90))
		switch (target.dir)
			if (NORTH)
				initial_matrix = matrix(target.transform)
				initial_matrix.Translate(0,3)
				animate(target, transform = initial_matrix, time = 1, loop = 0)
			if (SOUTH)
				initial_matrix = matrix(target.transform)
				initial_matrix.Translate(0,-3)
				animate(target, transform = initial_matrix, time = 1, loop = 0)
			if (EAST)
				initial_matrix = matrix(target.transform)
				initial_matrix.Translate(3,0)
				animate(target, transform = initial_matrix, time = 1, loop = 0)
			if (WEST)
				initial_matrix = matrix(target.transform)
				initial_matrix.Translate(-3,0)
				animate(target, transform = initial_matrix, time = 1, loop = 0)
		sleep(1)
	if(continues)
		restart_dance(target)
		return
	target.lying_fix()

/datum/dance/head_spin/proc/restart_dance(mob/target)
	INVOKE_ASYNC(src, PROC_REF(trigger_dance), target)

/datum/dance/head_spin/end_dance(mob/target)
	continues = FALSE
	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, type)
