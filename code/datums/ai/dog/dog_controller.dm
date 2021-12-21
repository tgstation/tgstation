/datum/ai_controller/dog
	blackboard = list(\
		BB_SIMPLE_CARRY_ITEM = null,\
		BB_FETCH_TARGET = null,\
		BB_FETCH_DELIVER_TO = null,\
		BB_DOG_FRIENDS = list(),\
		BB_FETCH_IGNORE_LIST = list(),\
		BB_DOG_ORDER_MODE = DOG_COMMAND_NONE,\
		BB_DOG_PLAYING_DEAD = FALSE,\
		BB_DOG_HARASS_TARGET = null)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(/datum/ai_planning_subtree/dog)

	COOLDOWN_DECLARE(heel_cooldown)
	COOLDOWN_DECLARE(command_cooldown)


/datum/ai_controller/dog/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/dog/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(new_pawn, COMSIG_PARENT_EXAMINE, .proc/on_examined)
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, .proc/check_altclicked)
	RegisterSignal(new_pawn, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), .proc/on_death)
	RegisterSignal(SSdcs, COMSIG_GLOB_CARBON_THROW_THING, .proc/listened_throw)
	return ..() //Run parent at end

/datum/ai_controller/dog/UnpossessPawn(destroy)
	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carried_item)
		pawn.visible_message(span_danger("[pawn] drops [carried_item]"))
		carried_item.forceMove(pawn.drop_location())
		blackboard[BB_SIMPLE_CARRY_ITEM] = null
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_CLICK_ALT, COMSIG_LIVING_DEATH, COMSIG_GLOB_CARBON_THROW_THING, COMSIG_PARENT_QDELETING))
	return ..() //Run parent at end

/datum/ai_controller/dog/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/dog/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return

	return simple_pawn.access_card

/// Someone has thrown something, see if it's someone we care about and start listening to the thrown item so we can see if we want to fetch it when it lands
/datum/ai_controller/dog/proc/listened_throw(datum/source, mob/living/carbon/carbon_thrower)
	SIGNAL_HANDLER
	if(blackboard[BB_FETCH_TARGET] || blackboard[BB_FETCH_DELIVER_TO] || blackboard[BB_DOG_PLAYING_DEAD]) // we're already busy
		return
	if(!COOLDOWN_FINISHED(src, heel_cooldown))
		return
	if(!can_see(pawn, carbon_thrower, length=AI_DOG_VISION_RANGE))
		return
	var/obj/item/thrown_thing = carbon_thrower.get_active_held_item()
	if(!isitem(thrown_thing))
		return
	if(blackboard[BB_FETCH_IGNORE_LIST][WEAKREF(thrown_thing)])
		return

	RegisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED, .proc/listen_throw_land)

/// A throw we were listening to has finished, see if it's in range for us to try grabbing it
/datum/ai_controller/dog/proc/listen_throw_land(obj/item/thrown_thing, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	UnregisterSignal(thrown_thing, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_THROW_LANDED))
	if(!istype(thrown_thing) || !isturf(thrown_thing.loc) || !can_see(pawn, thrown_thing, length=AI_DOG_VISION_RANGE))
		return

	current_movement_target = thrown_thing
	blackboard[BB_FETCH_TARGET] = thrown_thing
	blackboard[BB_FETCH_DELIVER_TO] = throwing_datum.thrower
	queue_behavior(/datum/ai_behavior/fetch)

/// Someone's interacting with us by hand, see if they're being nice or mean
/datum/ai_controller/dog/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(user.combat_mode)
		unfriend(user)
	else
		if(prob(AI_DOG_PET_FRIEND_PROB))
			befriend(user)
		// if the dog has something in their mouth that they're not bringing to someone for whatever reason, have them drop it when pet by a friend
		var/list/friends = blackboard[BB_DOG_FRIENDS]
		if(blackboard[BB_SIMPLE_CARRY_ITEM] && !current_movement_target && friends[WEAKREF(user)])
			var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
			pawn.visible_message(span_danger("[pawn] drops [carried_item] at [user]'s feet!"))
			// maybe have a dedicated proc for dropping things
			carried_item.forceMove(get_turf(user))
			blackboard[BB_SIMPLE_CARRY_ITEM] = null

/// Someone is being nice to us, let's make them a friend!
/datum/ai_controller/dog/proc/befriend(mob/living/new_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	var/datum/weakref/friend_ref = WEAKREF(new_friend)
	if(friends[friend_ref])
		return
	if(in_range(pawn, new_friend))
		new_friend.visible_message("<b>[pawn]</b> licks at [new_friend] in a friendly manner!", span_notice("[pawn] licks at you in a friendly manner!"))
	friends[friend_ref] = TRUE
	RegisterSignal(new_friend, COMSIG_MOB_POINTED, .proc/check_point)
	RegisterSignal(new_friend, COMSIG_MOB_SAY, .proc/check_verbal_command)

/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/dog/proc/unfriend(mob/living/ex_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	friends -= WEAKREF(ex_friend)
	UnregisterSignal(ex_friend, list(COMSIG_MOB_POINTED, COMSIG_MOB_SAY))

/// Someone is looking at us, if we're currently carrying something then show what it is, and include a message if they're our friend
/datum/ai_controller/dog/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carried_item)
		examine_text += span_notice("[pawn.p_they(TRUE)] [pawn.p_are()] carrying [carried_item.get_examine_string(user)] in [pawn.p_their()] mouth.")
	if(blackboard[BB_DOG_FRIENDS][WEAKREF(user)])
		var/mob/living/living_pawn = pawn
		if(!IS_DEAD_OR_INCAP(living_pawn))
			examine_text += span_notice("[pawn.p_they(TRUE)] seem[pawn.p_s()] happy to see you!")

/// If we died, drop anything we were carrying
/datum/ai_controller/dog/proc/on_death(mob/living/ol_yeller)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(!carried_item)
		return

	ol_yeller.visible_message(span_danger("[ol_yeller] drops [carried_item] as [ol_yeller.p_they()] die[ol_yeller.p_s()]."))
	carried_item.forceMove(ol_yeller.drop_location())
	blackboard[BB_SIMPLE_CARRY_ITEM] = null

// next section is regarding commands

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/dog/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(!istype(clicker) || !blackboard[BB_DOG_FRIENDS][WEAKREF(clicker)])
		return
	. = COMPONENT_CANCEL_CLICK_ALT
	INVOKE_ASYNC(src, .proc/command_radial, clicker)

/// Show the command radial menu
/datum/ai_controller/dog/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		COMMAND_HEEL = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow"),
		COMMAND_FETCH = image(icon = 'icons/mob/actions/actions_spells.dmi', icon_state = "summons"),
		COMMAND_ATTACK = image(icon = 'icons/effects/effects.dmi', icon_state = "bite"),
		COMMAND_DIE = image(icon = 'icons/mob/pets.dmi', icon_state = "puppy_dead")
		)

	var/choice = show_radial_menu(clicker, pawn, commands, custom_check = CALLBACK(src, .proc/check_menu, clicker), tooltips = TRUE)
	if(!choice || !check_menu(clicker))
		return
	set_command_mode(clicker, choice)

/datum/ai_controller/dog/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("A non-mob is trying to issue an order to [pawn].")
	if(user.incapacitated() || !can_see(user, pawn))
		return FALSE
	return TRUE

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/dog/proc/check_verbal_command(mob/speaker, speech_args)
	SIGNAL_HANDLER

	if(!blackboard[BB_DOG_FRIENDS][WEAKREF(speaker)])
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE] // probably should check for full words
	var/command
	if(findtext(spoken_text, "heel") || findtext(spoken_text, "sit") || findtext(spoken_text, "stay"))
		command = COMMAND_HEEL
	else if(findtext(spoken_text, "fetch") || findtext(spoken_text, "get it"))
		command = COMMAND_FETCH
	else if(findtext(spoken_text, "attack") || findtext(spoken_text, "sic"))
		command = COMMAND_ATTACK
	else if(findtext(spoken_text, "play dead"))
		command = COMMAND_DIE
	else
		return

	if(!can_see(pawn, speaker, length=AI_DOG_VISION_RANGE))
		return
	set_command_mode(speaker, command)

/// Whether we got here via radial menu or a verbal command, this is where we actually process what our new command will be
/datum/ai_controller/dog/proc/set_command_mode(mob/commander, command)
	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)

	switch(command)
		// heel: stop what you're doing, relax and try not to do anything for a little bit
		if(COMMAND_HEEL)
			pawn.visible_message(span_notice("[pawn]'s ears prick up at [commander]'s command, and [pawn.p_they()] sit[pawn.p_s()] down obediently, awaiting further orders."))
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			COOLDOWN_START(src, heel_cooldown, AI_DOG_HEEL_DURATION)
			CancelActions()
		// fetch: whatever the commander points to, try and bring it back
		if(COMMAND_FETCH)
			pawn.visible_message(span_notice("[pawn]'s ears prick up at [commander]'s command, and [pawn.p_they()] bounce[pawn.p_s()] slightly in anticipation."))
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_FETCH
		// attack: harass whoever the commander points to
		if(COMMAND_ATTACK)
			pawn.visible_message(span_danger("[pawn]'s ears prick up at [commander]'s command, and [pawn.p_they()] growl[pawn.p_s()] intensely.")) // imagine getting intimidated by a corgi
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_ATTACK
		if(COMMAND_DIE)
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			CancelActions()
			queue_behavior(/datum/ai_behavior/play_dead)

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/dog/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)
	SIGNAL_HANDLER

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(pointed_movable == pawn || blackboard[BB_FETCH_TARGET] || !istype(pointed_movable) || blackboard[BB_DOG_ORDER_MODE] == DOG_COMMAND_NONE) // busy or no command
		return
	if(!can_see(pawn, pointing_friend, length=AI_DOG_VISION_RANGE) || !can_see(pawn, pointed_movable, length=AI_DOG_VISION_RANGE))
		return

	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)

	switch(blackboard[BB_DOG_ORDER_MODE])
		if(DOG_COMMAND_FETCH)
			if(!isitem(pointed_movable) || pointed_movable.anchored)
				return
			var/obj/item/pointed_item = pointed_movable
			if(pointed_item.obj_flags & ABSTRACT)
				return
			pawn.visible_message(span_notice("[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and barks excitedly!"))
			current_movement_target = pointed_movable
			blackboard[BB_FETCH_TARGET] = pointed_movable
			blackboard[BB_FETCH_DELIVER_TO] = pointing_friend
			if(living_pawn.buckled)
				queue_behavior(/datum/ai_behavior/resist)//in case they are in bed or something
			queue_behavior(/datum/ai_behavior/fetch)
		if(DOG_COMMAND_ATTACK)
			pawn.visible_message(span_notice("[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and growls intensely!"))
			current_movement_target = pointed_movable
			blackboard[BB_DOG_HARASS_TARGET] = WEAKREF(pointed_movable)
			if(living_pawn.buckled)
				queue_behavior(/datum/ai_behavior/resist)//in case they are in bed or something
			queue_behavior(/datum/ai_behavior/harass)
