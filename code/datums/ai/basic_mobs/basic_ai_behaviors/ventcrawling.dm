/// We hop into the vents through a vent outlet, and then crawl around a bit. Jolly good times.
/// This also assumes that we are on the turf that the vent outlet is on. If it isn't, shit.

/// Warning: this was really snowflake code lifted from an obscure feature that likely has not been touched for over five years years.
/// Something that isn't implemented is the ability to actually crawl through vents ourselves because I think that's just a waste of time for the same effect (instead of psuedo-teleportation, do REAL forceMoving)
/// If you are seriously considering using this component, it would be a great idea to extend this proc to be more versatile/less overpowered - the mobs that currently implement this benefit the most
/// since they are weak as shit with only five health. Up to you though, don't take what's written here as gospel.
/datum/ai_behavior/crawl_through_vents
	action_cooldown = 10 SECONDS

/datum/ai_behavior/crawl_through_vents/get_cooldown(datum/ai_controller/cooldown_for)
	return cooldown_for.blackboard[BB_VENTCRAWL_COOLDOWN] || initial(action_cooldown)

/datum/ai_behavior/crawl_through_vents/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/machinery/atmospherics/components/unary/vent_pump/target = controller.blackboard[target_key] || controller.blackboard[BB_ENTRY_VENT_TARGET]
	return istype(target) && isliving(controller.pawn) // only mobs can vent crawl in the current framework

/datum/ai_behavior/crawl_through_vents/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent = controller.blackboard[target_key] || controller.blackboard[BB_ENTRY_VENT_TARGET]
	var/mob/living/cached_pawn = controller.pawn
	if(HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING) || !controller.blackboard[BB_CURRENTLY_TARGETING_VENT] || !is_vent_valid(entry_vent))
		return AI_BEHAVIOR_DELAY

	if(!cached_pawn.can_enter_vent(entry_vent, provide_feedback = FALSE)) // we're an AI we scoff at feedback
		// "never enter a hole you can't get out of"
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/vent_we_exit_out_of = calculate_exit_vent(controller, target_key)
	if(isnull(vent_we_exit_out_of)) // don't get into the vents if we can't get out of them, that's SILLY.
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_CURRENTLY_TARGETING_VENT, FALSE) // must be done here because we have a do_after sleep in handle_ventcrawl unfortunately and double dipping could lead to erroneous suicide pill calls.
	cached_pawn.handle_ventcrawl(entry_vent)
	if(!HAS_TRAIT(cached_pawn, TRAIT_MOVE_VENTCRAWLING)) //something failed and we ARE NOT IN THE VENT even though the earlier check said we were good to go! odd.
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(BB_EXIT_VENT_TARGET, vent_we_exit_out_of)

	if(prob(50))
		cached_pawn.visible_message(
			span_warning("[src] scrambles into the ventilation ducts!"),
			span_hear("You hear something scampering through the ventilation ducts."),
		)

	var/lower_vent_time_limit = controller.blackboard[BB_LOWER_VENT_TIME_LIMIT] // the least amount of time we spend in the vents
	var/upper_vent_time_limit = controller.blackboard[BB_UPPER_VENT_TIME_LIMIT] // the most amount of time we spend in the vents

	addtimer(CALLBACK(src, PROC_REF(exit_the_vents), controller), rand(lower_vent_time_limit, upper_vent_time_limit))
	controller.set_blackboard_key(BB_GIVE_UP_ON_VENT_PATHING_TIMER_ID, addtimer(CALLBACK(src, PROC_REF(delayed_suicide_pill), controller, target_key), controller.blackboard[BB_TIME_TO_GIVE_UP_ON_VENT_PATHING], TIMER_STOPPABLE))
	return AI_BEHAVIOR_DELAY

/// Figure out an exit vent that we should head towards. If we don't have one, default to the entry vent. If they're all kaput, we die.
/datum/ai_behavior/crawl_through_vents/proc/calculate_exit_vent(datum/ai_controller/controller, target_key)
	var/obj/machinery/atmospherics/components/unary/vent_pump/returnable_vent
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent_we_entered_through = controller.blackboard[target_key] || controller.blackboard[BB_ENTRY_VENT_TARGET]

	var/datum/pipeline/entry_vent_parent = vent_we_entered_through.parents[1]
	var/list/potential_exits = list()

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in entry_vent_parent.other_atmos_machines)
		if(is_vent_valid(vent))
			potential_exits.Add(vent)

	if(length(potential_exits))
		returnable_vent = pick(potential_exits)
		return returnable_vent

	// if we're here, we're in "what the flarp" mode... okay maybe we can default to the vent we entered in.
	returnable_vent = vent_we_entered_through
	if(is_vent_valid(vent_we_entered_through))
		// AH WHAT THE FUCK. okay, maybe we're not inside the vents yet? let's return null and we can pick up on that based on the wider context of the proc that invokes it.
		return null

	return returnable_vent // we return null in case something yonked between then and now so it's all good man

/// We've had enough horsing around in the vents, it's time to get out.
/datum/ai_behavior/crawl_through_vents/proc/exit_the_vents(datum/ai_controller/controller, target_key)
	var/obj/machinery/atmospherics/components/unary/vent_pump/emergency_vent // vent we will scramble to search for in case plan A is a bust (exit vent)
	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = controller.blackboard[BB_EXIT_VENT_TARGET]
	var/mob/living/living_pawn = controller.pawn

	if(!HAS_TRAIT(living_pawn, TRAIT_MOVE_VENTCRAWLING) && isturf(get_turf(living_pawn))) // we're out of the vents, so no need to do an exit
		// assume that we got yeeted out somehow and return this so we can halt the suicide pill timer.
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	living_pawn.forceMove(exit_vent)
	if(!living_pawn.can_enter_vent(exit_vent, provide_feedback = FALSE))
		// oh shit, something happened while we were waiting on that timer. let's figure out a different way to get out of here.
		emergency_vent = calculate_exit_vent(controller)
		if(isnull(emergency_vent))
			// it's joever. we cooked too hard.
			return suicide_pill(controller) | AI_BEHAVIOR_DELAY

		controller.set_blackboard_key(BB_EXIT_VENT_TARGET, emergency_vent) // assign and go again
		addtimer(CALLBACK(src, PROC_REF(exit_the_vents), controller), (rand(controller.blackboard[BB_LOWER_VENT_TIME_LIMIT], controller.blackboard[BB_UPPER_VENT_TIME_LIMIT]) / 2)) // we're in danger mode, so scurry out at half the time it would normally take.
		return

	living_pawn.handle_ventcrawl(exit_vent)
	if(HAS_TRAIT(living_pawn, TRAIT_MOVE_VENTCRAWLING)) // how'd we fail? what the fuck
		stack_trace("We failed to exit the vents, even though we should have been fine? This is very weird.")
		return suicide_pill(controller) | AI_BEHAVIOR_DELAY // all of the prior checks say we should have definitely made it through, but we didn't. dammit.

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED // we did it! we went into the vents and out of the vents. poggers.

/// Incredibly stripped down version of the overarching `can_enter_vent` proc on `/mob, just meant for rapid rechecking of a vent. Will be TRUE if not blocked, FALSE otherwise.
/datum/ai_behavior/crawl_through_vents/proc/is_vent_valid(obj/machinery/atmospherics/components/unary/vent_pump/checkable)
	return !QDELETED(checkable) && !checkable.welded

/// Wraps a delayed defeat, so we gotta handle the return value properly ya feel?
/datum/ai_behavior/crawl_through_vents/proc/delayed_suicide_pill(datum/ai_controller/controller, target_key)
	if(suicide_pill(controller) & AI_BEHAVIOR_FAILED)
		finish_action(controller, FALSE, target_key)

/// Aw fuck, we may have been bested somehow. Regardless of what we do, we can't exit through a vent! Let's end our misery and prevent useless endless calculations.
/datum/ai_behavior/crawl_through_vents/proc/suicide_pill(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(istype(living_pawn))
		if(isnull(living_pawn.client)) // only call death if we don't have a client because maybe their natural intelligence can pick up where our AI calculations have failed
			living_pawn.death(TRUE) // call gibbed as true because we are never coming back it is so fucking joever

		return AI_BEHAVIOR_FAILED

	if(QDELETED(living_pawn)) // we got deleted by some other means, just presume the action is a wash and get outta here
		return NONE

	qdel(living_pawn) // failover, we really should've been caught in the istype() but lets just bow out of existing at this point
	return NONE

/datum/ai_behavior/crawl_through_vents/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()

	deltimer(controller.blackboard[BB_GIVE_UP_ON_VENT_PATHING_TIMER_ID])
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_ENTRY_VENT_TARGET)
	controller.clear_blackboard_key(BB_EXIT_VENT_TARGET)
	controller.set_blackboard_key(BB_CURRENTLY_TARGETING_VENT, FALSE) // just in case

