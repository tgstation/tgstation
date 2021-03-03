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

	COOLDOWN_DECLARE(heel_cooldown)
	COOLDOWN_DECLARE(command_cooldown)
	COOLDOWN_DECLARE(reset_ignore_cooldown)


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
	RegisterSignal(SSdcs, COMSIG_GLOB_CARBON_THROW_THING, .proc/listened_throw)
	return ..() //Run parent at end

/datum/ai_controller/dog/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_GLOB_CARBON_THROW_THING, COMSIG_CLICK_ALT))
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

/datum/ai_controller/dog/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/living_pawn = pawn

	// occasionally reset our ignore list
	if(COOLDOWN_FINISHED(src, reset_ignore_cooldown) && length(blackboard[BB_FETCH_IGNORE_LIST]))
		COOLDOWN_START(src, reset_ignore_cooldown, AI_FETCH_IGNORE_DURATION)
		blackboard[BB_FETCH_IGNORE_LIST] = list()

	// if we were just ordered to heel, chill out for a bit
	if(!COOLDOWN_FINISHED(src, heel_cooldown))
		return

	// if we're not already carrying something and we have a fetch target (and we're not already doing something with it), see if we can eat/equip it
	if(!blackboard[BB_SIMPLE_CARRY_ITEM] && blackboard[BB_FETCH_TARGET])
		var/atom/movable/interact_target = blackboard[BB_FETCH_TARGET]
		if(in_range(living_pawn, interact_target) && (isturf(interact_target.loc)))
			current_movement_target = interact_target
			if(IS_EDIBLE(interact_target))
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/eat_snack)
			else
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/simple_equip)
			return

	// if we're carrying something and we have a destination to deliver it, do that
	if(blackboard[BB_SIMPLE_CARRY_ITEM] && blackboard[BB_FETCH_DELIVER_TO])
		var/atom/return_target = blackboard[BB_FETCH_DELIVER_TO]
		if(!can_see(pawn, return_target, length=AI_DOG_VISION_RANGE))
			// if the return target isn't in sight, we'll just forget about it and carry the thing around
			blackboard[BB_FETCH_DELIVER_TO] = null
			return
		current_movement_target = return_target
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/deliver_item)
		return

	// occasionally see if there's any loose snacks in sight nearby
	if(DT_PROB(40, delta_time))
		for(var/obj/item/potential_snack in oview(living_pawn,2))
			if(IS_EDIBLE(potential_snack) && (isturf(potential_snack.loc) || ishuman(potential_snack.loc)))
				current_movement_target = potential_snack
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/eat_snack)
				return

/datum/ai_controller/dog/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	// if we were just ordered to heel, chill out for a bit
	if(!COOLDOWN_FINISHED(src, heel_cooldown))
		return

	// if we're just ditzing around carrying something, occasionally print a message so people know we have something
	if(blackboard[BB_SIMPLE_CARRY_ITEM] && DT_PROB(5, delta_time))
		var/obj/item/carry_item = blackboard[BB_SIMPLE_CARRY_ITEM]
		living_pawn.visible_message("<span class='notice'>[living_pawn] gently teethes on \the [carry_item] in [living_pawn.p_their()] mouth.</span>", vision_distance=COMBAT_MESSAGE_RANGE)

	if(DT_PROB(5, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE))
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(DT_PROB(10, delta_time))
		living_pawn.manual_emote(pick("dances around.","chases [living_pawn.p_their()] tail!"))
		living_pawn.AddComponent(/datum/component/spinny)

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
	if(blackboard[BB_FETCH_IGNORE_LIST][thrown_thing])
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
	current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/fetch)

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
		if(blackboard[BB_SIMPLE_CARRY_ITEM] && !current_movement_target && friends[user])
			var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
			pawn.visible_message("<span='danger'>[pawn] drops [carried_item] at [user]'s feet!</span>")
			// maybe have a dedicated proc for dropping things
			carried_item.forceMove(get_turf(user))
			blackboard[BB_SIMPLE_CARRY_ITEM] = null

/// Someone is being nice to us, let's make them a friend!
/datum/ai_controller/dog/proc/befriend(mob/living/new_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	if(friends[new_friend])
		return
	if(in_range(pawn, new_friend))
		new_friend.visible_message("<b>[pawn]</b> licks at [new_friend] in a friendly manner!", "<span class='notice'>[pawn] licks at you in a friendly manner!</span>")
	friends[new_friend] = TRUE
	RegisterSignal(new_friend, COMSIG_MOB_POINTED, .proc/check_point)
	RegisterSignal(new_friend, COMSIG_MOB_SAY, .proc/check_verbal_command)

/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/dog/proc/unfriend(mob/living/ex_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	friends[ex_friend] = null
	UnregisterSignal(ex_friend, list(COMSIG_MOB_POINTED, COMSIG_MOB_SAY))

/// Someone is looking at us, if we're currently carrying something then show what it is, and include a message if they're our friend
/datum/ai_controller/dog/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carried_item)
		examine_text += "<span class='notice'>[pawn.p_they(TRUE)] [pawn.p_are()] carrying [carried_item.get_examine_string(user)] in [pawn.p_their()] mouth.</span>"
	if(blackboard[BB_DOG_FRIENDS][user])
		examine_text += "<span class='notice'>[pawn.p_they(TRUE)] seem[pawn.p_s()] happy to see you!</span>"

/// If we died, drop anything we were carrying
/datum/ai_controller/dog/proc/on_death(mob/living/ol_yeller)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(!carried_item)
		return

	ol_yeller.visible_message("<span='danger'>[ol_yeller] drops [carried_item] as [ol_yeller.p_they()] die[ol_yeller.p_s()].</span>")
	carried_item.forceMove(get_turf(ol_yeller))
	blackboard[BB_SIMPLE_CARRY_ITEM] = null

// next section is regarding commands

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/dog/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(!istype(clicker) || !blackboard[BB_DOG_FRIENDS][clicker])
		return
	. = COMPONENT_CANCEL_CLICK_ALT
	INVOKE_ASYNC(src, .proc/command_radial, clicker)

/// Show the command radial menu
/datum/ai_controller/dog/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		COMMAND_HEEL = image(icon = 'icons/Testing/turf_analysis.dmi', icon_state = "red_arrow"),
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

	if(!blackboard[BB_DOG_FRIENDS][speaker])
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
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
			pawn.visible_message("<span class='notice'>[pawn]'s ears prick up at [commander]'s command, and [pawn.p_they()] sit[pawn.p_s()] down obediently, awaiting further orders.</span>")
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			COOLDOWN_START(src, heel_cooldown, AI_DOG_HEEL_DURATION)
			CancelActions()
		// fetch: whatever the commander points to, try and bring it back
		if(COMMAND_FETCH)
			pawn.visible_message("<span class='notice'>[pawn]'s ears prick up at [commander]'s command, and [pawn.p_they()] bounce[pawn.p_s()] slightly in anticipation.</span>")
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_FETCH
		// attack: harass whoever the commander points to
		if(COMMAND_ATTACK)
			pawn.visible_message("<span class='danger'>[pawn]'s ears prick up at [commander]'s command, and [pawn.p_they()] growl[pawn.p_s()] intensely.</span>") // imagine getting intimidated by a corgi
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_ATTACK
		if(COMMAND_DIE)
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			CancelActions()
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/play_dead)

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/dog/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(pointed_movable == pawn || blackboard[BB_FETCH_TARGET] || !istype(pointed_movable) || blackboard[BB_DOG_ORDER_MODE] == DOG_COMMAND_NONE) // busy or no command
		return
	if(!can_see(pawn, pointing_friend, length=AI_DOG_VISION_RANGE) || !can_see(pawn, pointed_movable, length=AI_DOG_VISION_RANGE))
		return

	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)

	switch(blackboard[BB_DOG_ORDER_MODE])
		if(DOG_COMMAND_FETCH)
			if(ismob(pointed_movable) || pointed_movable.anchored)
				return
			pawn.visible_message("<span class='notice'>[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and barks excitedly!</span>")
			current_movement_target = pointed_movable
			blackboard[BB_FETCH_TARGET] = pointed_movable
			blackboard[BB_FETCH_DELIVER_TO] = pointing_friend
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/fetch)
		if(DOG_COMMAND_ATTACK)
			pawn.visible_message("<span class='notice'>[pawn] follows [pointing_friend]'s gesture towards [pointed_movable] and growls intensely!</span>")
			current_movement_target = pointed_movable
			blackboard[BB_DOG_HARASS_TARGET] = pointed_movable
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/harass)
