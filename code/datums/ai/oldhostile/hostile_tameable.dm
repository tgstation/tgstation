///This code needs to be removed at some point as it doesn't actually utilize the AI.

/datum/ai_controller/hostile_friend
	blackboard = list(
		BB_HOSTILE_ORDER_MODE = null,
		BB_HOSTILE_FRIEND = null,
		BB_FOLLOW_TARGET = null,
		BB_ATTACK_TARGET = null,
		BB_VISION_RANGE = BB_HOSTILE_VISION_RANGE,
		BB_HOSTILE_ATTACK_WORD = "growls",
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/hostile_tameable

	var/ride_penalty_movement = 1 SECONDS

	COOLDOWN_DECLARE(command_cooldown)

/datum/ai_controller/hostile_friend/process(seconds_per_tick)
	if(isliving(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/hostile_friend/TryPossessPawn(atom/new_pawn)
	if(!ishostile(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, PROC_REF(check_altclicked))
	RegisterSignal(new_pawn, COMSIG_RIDDEN_DRIVER_MOVE, PROC_REF(on_ridden_driver_move))
	RegisterSignal(new_pawn, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_prebuckle))
	return ..() //Run parent at end

/datum/ai_controller/hostile_friend/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXAMINE,
		COMSIG_CLICK_ALT,
		COMSIG_LIVING_DEATH,
		COMSIG_QDELETING
	))
	unfriend()
	return ..() //Run parent at end

/datum/ai_controller/hostile_friend/proc/on_prebuckle(mob/source, mob/living/buckler, force, buckle_mob_flags)
	SIGNAL_HANDLER
	if(force || ai_status == AI_STATUS_OFF)
		return
	if(buckler != blackboard[BB_HOSTILE_FRIEND])
		return COMPONENT_BLOCK_BUCKLE

/datum/ai_controller/hostile_friend/on_stat_changed(mob/living/source, new_stat)
	. = ..()
	update_able_to_run()

/datum/ai_controller/hostile_friend/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_MOB_INCAPACITATE_CHANGED, PROC_REF(update_able_to_run))

/datum/ai_controller/hostile_friend/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_MOB_INCAPACITATE_CHANGED, COMSIG_MOB_STATCHANGE))
	return ..()

/datum/ai_controller/hostile_friend/get_able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/hostile_friend/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return

	return simple_pawn.access_card.GetAccess()

/datum/ai_controller/hostile_friend/proc/on_ridden_driver_move(atom/movable/movable_parent, mob/living/user, direction)
	SIGNAL_HANDLER
	PauseAi(ride_penalty_movement)

/// Befriends someone
/datum/ai_controller/hostile_friend/proc/befriend(mob/living/new_friend)
	var/mob/living/old_friend = blackboard[BB_HOSTILE_FRIEND]
	if(old_friend)
		unfriend(old_friend)

	if(pawn.Adjacent(pawn, new_friend))
		new_friend.visible_message("<b>[pawn]</b> looks at [new_friend] in a friendly manner!", span_notice("[pawn] looks at you in a friendly manner!"))
	set_blackboard_key(BB_HOSTILE_FRIEND, new_friend)
	RegisterSignal(new_friend, COMSIG_MOVABLE_POINTED, PROC_REF(check_point))
	RegisterSignal(new_friend, COMSIG_MOB_SAY, PROC_REF(check_verbal_command))

/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/hostile_friend/proc/unfriend()
	var/mob/living/old_friend = blackboard[BB_HOSTILE_FRIEND]
	if(old_friend)
		UnregisterSignal(old_friend, list(COMSIG_MOVABLE_POINTED, COMSIG_MOB_SAY))
	clear_blackboard_key(BB_HOSTILE_FRIEND)

/// Someone is looking at us, if we're currently carrying something then show what it is, and include a message if they're our friend
/datum/ai_controller/hostile_friend/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if(blackboard[BB_HOSTILE_FRIEND] != user)
		return

	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn))
		examine_text += span_notice("[pawn.p_They()] seem[pawn.p_s()] happy to see you!")

// next section is regarding commands

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/hostile_friend/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(!istype(clicker) || blackboard[BB_HOSTILE_FRIEND] != clicker || !clicker.can_perform_action(source))
		return

	INVOKE_ASYNC(src, PROC_REF(command_radial), clicker)
	return CLICK_ACTION_BLOCKING

/// Show the command radial menu
/datum/ai_controller/hostile_friend/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		COMMAND_STOP = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow"),
		COMMAND_FOLLOW = image(icon = 'icons/mob/actions/actions_spells.dmi', icon_state = "summons"),
		COMMAND_ATTACK = image(icon = 'icons/effects/effects.dmi', icon_state = "bite"),
		)

	var/choice = show_radial_menu(clicker, pawn, commands, custom_check = CALLBACK(src, PROC_REF(check_menu), clicker), tooltips = TRUE)
	if(!choice || !check_menu(clicker))
		return
	set_command_mode(clicker, choice)


/datum/ai_controller/hostile_friend/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("A non-mob is trying to issue an order to [pawn].")
	if(user.incapacitated || !can_see(user, pawn))
		return FALSE
	return TRUE

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/hostile_friend/proc/check_verbal_command(mob/speaker, speech_args)
	SIGNAL_HANDLER

	if(blackboard[BB_HOSTILE_FRIEND] != speaker)
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE] // probably should check for full words
	var/command
	if(findtext(spoken_text, "stop") || findtext(spoken_text, "stay"))
		command = COMMAND_STOP
	else if(findtext(spoken_text, "follow") || findtext(spoken_text, "come"))
		command = COMMAND_FOLLOW
	else if(findtext(spoken_text, "attack") || findtext(spoken_text, "sic"))
		command = COMMAND_ATTACK
	else
		return

	if(!can_see(pawn, speaker, length=blackboard[BB_VISION_RANGE]))
		return
	set_command_mode(speaker, command)

/// Whether we got here via radial menu or a verbal command, this is where we actually process what our new command will be
/datum/ai_controller/hostile_friend/proc/set_command_mode(mob/commander, command)
	COOLDOWN_START(src, command_cooldown, AI_HOSTILE_COMMAND_COOLDOWN)

	switch(command)
		// heel: stop what you're doing, relax and try not to do anything for a little bit
		if(COMMAND_STOP)
			pawn.visible_message(span_notice("[pawn] [blackboard[BB_HOSTILE_ATTACK_WORD]] at [commander]'s command, and [pawn.p_they()] stop[pawn.p_s()] obediently, awaiting further orders."))
			set_blackboard_key(BB_HOSTILE_ORDER_MODE, HOSTILE_COMMAND_NONE)
			CancelActions()
		// follow: whatever the commander points to, try and bring it back
		if(COMMAND_FOLLOW)
			pawn.visible_message(span_notice("[pawn] [blackboard[BB_HOSTILE_ATTACK_WORD]] at [commander]'s command, and [pawn.p_they()] follow[pawn.p_s()] slightly in anticipation."))
			CancelActions()
			set_blackboard_key(BB_HOSTILE_ORDER_MODE, HOSTILE_COMMAND_FOLLOW)
			set_blackboard_key(BB_FOLLOW_TARGET, commander)
			set_movement_target(type, commander)
			var/mob/living/living_pawn = pawn
			if(living_pawn.buckled)
				queue_behavior(/datum/ai_behavior/resist)//in case they are in bed or something
			queue_behavior(/datum/ai_behavior/follow)
		// attack: harass whoever the commander points to
		if(COMMAND_ATTACK)
			pawn.visible_message(span_danger("[pawn] [blackboard[BB_HOSTILE_ATTACK_WORD]] at [commander]'s command, and [pawn.p_they()] growl[pawn.p_s()] intensely.")) // imagine getting intimidated by a corgi
			CancelActions()
			set_blackboard_key(BB_HOSTILE_ORDER_MODE, HOSTILE_COMMAND_ATTACK)

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/hostile_friend/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable, obj/effect/temp_visual/point/point)
	SIGNAL_HANDLER

	var/mob/living/simple_animal/hostile/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(blackboard[BB_HOSTILE_FRIEND] == pointed_movable \
		|| pointed_movable == pawn \
		|| !istype(pointed_movable) \
		|| blackboard[BB_HOSTILE_ORDER_MODE] == HOSTILE_COMMAND_NONE) // busy or no command
		return
	if(!can_see(pawn, pointing_friend, length=blackboard[BB_VISION_RANGE]) || !can_see(pawn, pointed_movable, length=blackboard[BB_VISION_RANGE]))
		return

	CancelActions()
	COOLDOWN_START(src, command_cooldown, AI_HOSTILE_COMMAND_COOLDOWN)

	if(blackboard[BB_HOSTILE_ORDER_MODE] == HOSTILE_COMMAND_ATTACK)
		pawn.visible_message(span_notice("[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and [blackboard[BB_HOSTILE_ATTACK_WORD]] intensely!"))
		set_movement_target(type, pointed_movable)
		set_blackboard_key(BB_ATTACK_TARGET, pointed_movable)
		if(living_pawn.buckled)
			queue_behavior(/datum/ai_behavior/resist)//in case they are in bed or something
		queue_behavior(/datum/ai_behavior/attack)


/datum/idle_behavior/idle_random_walk/hostile_tameable
	walk_chance = 5
