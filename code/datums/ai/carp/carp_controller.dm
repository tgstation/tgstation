/datum/ai_controller/carp
	blackboard = list(
		BB_CARP_ORDER_MODE = null,
		BB_CARP_FRIEND = null,
		BB_FOLLOW_TARGET = null,
		BB_ATTACK_TARGET = null,
		BB_VISION_RANGE = AI_CARP_VISION_RANGE,
	)
	ai_movement = /datum/ai_movement/basic_avoidance

	var/list/food_types = list(
		/obj/item/food/meat
	)

	var/tame_chance = 10
	var/bonus_tame_chance = 5

	var/ride_penalty_movement = 1 SECONDS

	COOLDOWN_DECLARE(command_cooldown)

/datum/ai_controller/carp/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/carp/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attack_by)
	RegisterSignal(new_pawn, COMSIG_PARENT_EXAMINE, .proc/on_examined)
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, .proc/check_altclicked)
	RegisterSignal(new_pawn, COMSIG_RIDDEN_DRIVER_MOVE, .proc/on_ridden_driver_move)
	return ..() //Run parent at end

/datum/ai_controller/carp/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_PARENT_EXAMINE,
		COMSIG_CLICK_ALT,
		COMSIG_LIVING_DEATH,
		COMSIG_PARENT_QDELETING
	))
	return ..() //Run parent at end

/datum/ai_controller/carp/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/carp/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return

	return simple_pawn.access_card

/datum/ai_controller/carp/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby || length(living_pawn.buckled_mobs))
		return

	if(DT_PROB(5, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE))
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

/datum/ai_controller/carp/proc/on_ridden_driver_move(atom/movable/movable_parent, mob/living/user, direction)
	SIGNAL_HANDLER
	PauseAi(ride_penalty_movement)

/// Someone's giving us meat, let's see if we should befriend them
/datum/ai_controller/carp/proc/on_attack_by(datum/source, obj/item/food, mob/living/attacker, params)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	if(!is_type_in_list(food, food_types))
		return

	attacker.visible_message(span_notice("[attacker] hand-feeds [food] to [pawn]."), span_notice("You hand-feed [food] to [pawn]."))
	qdel(food)
	var/datum/weakref/current_ref = blackboard[BB_CARP_FRIEND]
	if(current_ref?.resolve())
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if (prob(tame_chance)) //note: lack of feedback message is deliberate, keep them guessing!
		befriend(attacker)
	else
		tame_chance += bonus_tame_chance
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Befriends someone
/datum/ai_controller/carp/proc/befriend(mob/living/new_friend)
	var/datum/weakref/current_ref = blackboard[BB_CARP_FRIEND]
	var/datum/weakref/friend_ref = WEAKREF(new_friend)
	var/mob/living/old_friend = current_ref?.resolve()
	if(old_friend)
		unfriend(old_friend)
	else
		blackboard[BB_CARP_FRIEND] = null

	if(in_range(pawn, new_friend))
		new_friend.visible_message("<b>[pawn]</b> looks at [new_friend] in a friendly manner!", span_notice("[pawn] looks at you in a friendly manner!"))
	blackboard[BB_CARP_FRIEND] = friend_ref
	RegisterSignal(new_friend, COMSIG_MOB_POINTED, .proc/check_point)
	RegisterSignal(new_friend, COMSIG_MOB_SAY, .proc/check_verbal_command)
	if(ishostile(pawn))
		var/mob/living/simple_animal/hostile/living_pawn = pawn
		// Turn off default AI
		living_pawn.can_have_ai = FALSE
		living_pawn.toggle_ai(AI_OFF)
		living_pawn.friends = new_friend
		living_pawn.faction = new_friend.faction.Copy()

		living_pawn.can_buckle = TRUE
		living_pawn.buckle_lying = 0
		living_pawn.AddElement(/datum/element/ridable, /datum/component/riding/creature/carp)


/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/carp/proc/unfriend()
	var/datum/weakref/friend_ref = blackboard[BB_CARP_FRIEND]
	var/mob/living/old_friend = friend_ref.resolve()
	if(old_friend)
		UnregisterSignal(old_friend, list(COMSIG_MOB_POINTED, COMSIG_MOB_SAY))
	blackboard[BB_CARP_FRIEND] = null
	tame_chance = initial(tame_chance)
	if(ishostile(old_friend))
		var/mob/living/simple_animal/hostile/living_pawn = pawn
		living_pawn.can_have_ai = TRUE
		living_pawn.toggle_ai(AI_IDLE)
		living_pawn.friends = initial(living_pawn.friends)
		living_pawn.faction = initial(living_pawn.faction)

/// Someone is looking at us, if we're currently carrying something then show what it is, and include a message if they're our friend
/datum/ai_controller/carp/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if(blackboard[BB_CARP_FRIEND] == WEAKREF(user))
		var/mob/living/living_pawn = pawn
		if(!IS_DEAD_OR_INCAP(living_pawn))
			examine_text += span_notice("[pawn.p_they(TRUE)] seem[pawn.p_s()] happy to see you!")

// next section is regarding commands

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/carp/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(!istype(clicker) || !blackboard[BB_CARP_FRIEND] == WEAKREF(clicker))
		return
	. = COMPONENT_CANCEL_CLICK_ALT
	INVOKE_ASYNC(src, .proc/command_radial, clicker)

/// Show the command radial menu
/datum/ai_controller/carp/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		COMMAND_STOP = image(icon = 'icons/mob/carp.dmi', icon_state = "base"),
		COMMAND_FOLLOW = image(icon = 'icons/mob/carp.dmi', icon_state = "base"),
		COMMAND_ATTACK = image(icon = 'icons/mob/carp.dmi', icon_state = "base"),
		)

	var/choice = show_radial_menu(clicker, pawn, commands, custom_check = CALLBACK(src, .proc/check_menu, clicker), tooltips = TRUE)
	if(!choice || !check_menu(clicker))
		return
	set_command_mode(clicker, choice)

/datum/ai_controller/carp/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("A non-mob is trying to issue an order to [pawn].")
	if(user.incapacitated() || !can_see(user, pawn))
		return FALSE
	return TRUE

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/carp/proc/check_verbal_command(mob/speaker, speech_args)
	SIGNAL_HANDLER

	if(blackboard[BB_CARP_FRIEND] != WEAKREF(speaker))
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
/datum/ai_controller/carp/proc/set_command_mode(mob/commander, command)
	COOLDOWN_START(src, command_cooldown, AI_CARP_COMMAND_COOLDOWN)

	switch(command)
		// heel: stop what you're doing, relax and try not to do anything for a little bit
		if(COMMAND_STOP)
			pawn.visible_message(span_notice("[pawn] gnashes at [commander]'s command, and [pawn.p_they()] stop[pawn.p_s()] obediently, awaiting further orders."))
			blackboard[BB_CARP_ORDER_MODE] = CARP_COMMAND_NONE
			CancelActions()
		// fetch: whatever the commander points to, try and bring it back
		if(COMMAND_FOLLOW)
			pawn.visible_message(span_notice("[pawn] gnashes at [commander]'s command, and [pawn.p_they()] follow[pawn.p_s()] slightly in anticipation."))
			CancelActions()
			blackboard[BB_CARP_ORDER_MODE] = CARP_COMMAND_FOLLOW
			blackboard[BB_FOLLOW_TARGET] = WEAKREF(commander)
			current_movement_target = commander
			var/mob/living/living_pawn = pawn
			if(living_pawn.buckled)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/resist)//in case they are in bed or something
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/follow)
		// attack: harass whoever the commander points to
		if(COMMAND_ATTACK)
			pawn.visible_message(span_danger("[pawn] gnashes at [commander]'s command, and [pawn.p_they()] growl[pawn.p_s()] intensely.")) // imagine getting intimidated by a corgi
			CancelActions()
			blackboard[BB_CARP_ORDER_MODE] = CARP_COMMAND_ATTACK

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/carp/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)
	SIGNAL_HANDLER

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(blackboard[BB_CARP_FRIEND] == WEAKREF(pointed_movable) || pointed_movable == pawn || !istype(pointed_movable) || blackboard[BB_CARP_ORDER_MODE] == CARP_COMMAND_NONE) // busy or no command
		return
	if(!can_see(pawn, pointing_friend, length=blackboard[BB_VISION_RANGE]) || !can_see(pawn, pointed_movable, length=blackboard[BB_VISION_RANGE]))
		return

	CancelActions()
	COOLDOWN_START(src, command_cooldown, AI_CARP_COMMAND_COOLDOWN)

	if(blackboard[BB_CARP_ORDER_MODE] == CARP_COMMAND_ATTACK)
		pawn.visible_message(span_notice("[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and gnashes intensely!"))
		current_movement_target = pointed_movable
		blackboard[BB_ATTACK_TARGET] = WEAKREF(pointed_movable)
		if(living_pawn.buckled)
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/resist)//in case they are in bed or something
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/attack)
