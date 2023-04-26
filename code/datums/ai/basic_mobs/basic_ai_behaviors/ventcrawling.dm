/// We hop into the vents through a vent outlet, and then crawl around a bit. Jolly good times.
/// This also assumes that we are on the turf that the vent outlet is on. If it isn't, shit.
/datum/ai_behavior/crawl_around_vents
	action_cooldown = 1 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/crawl_around_vents/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/machinery/atmospherics/components/unary/vent_pump/target = controller.blackboard[target_key]
	return istype(target)

/datum/ai_behavior/crawl_around_vents/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent = controller.blackboard[target_key]
	var/mob/living/cached_pawn = controller.pawn
	if(check_vent(entry_vent) || !controller.blackboard[BB_CURRENTLY_TARGETTING_VENT])
		return

	if(!cached_pawn.can_enter_vent(entry_vent, provide_feedback = FALSE)) // we're an AI we scoff at feedback
		finish_action(controller, FALSE, target_key)
		return

	var/vent_we_exit_out_of = calculate_exit_vent(datum/ai_controller/controller, target_key)
	if(isnull(vent_we_exit_out_of)) // don't get into the vents if we can't get out of them, that's SILLY.
		finish_action(controller, FALSE, target_key)
		return

	cached_pawn.handle_ventcrawl(entry_vent)
	if(!HAS_TRAIT(TRAIT_MOVE_VENTCRAWLING)) //something failed and we ARE NOT IN THE VENT even though the earlier check said we were good to go! odd.
		stack_trace("AI with Crawl Around Vents behavior failed to get in the vents! Odd.")
		finish_action(controller, FALSE, target_key)
		return

	controller.set_blackboard_key(BB_CURRENTLY_TARGETTING_VENT, FALSE)
	controller.set_blackboard_key(BB_EXIT_VENT_TARGET, vent_we_exit_out_of)

	if(prob(50))
		visible_message(
			span_warning("[src] scrambles into the ventilation ducts!"),
			span_hear("You hear something scampering through the ventilation ducts.",
		))

	var/lower_vent_time_limit = controller.blackboard[BB_LOWER_VENT_TIME_LIMIT] // the least amount of time we spend in the vents
	var/upper_vent_time_limit = controller.blackboard[BB_UPPER_VENT_TIME_LIMIT] // the most amount of time we spend in the vents

	addtimer(CALLBACK(src, PROC_REF(exit_the_vents), controller), rand(lower_vent_time_limit, upper_vent_time_limit))
	addtimer(CALLBACK(src, PROC_REF(suicide_pill), controller), controller.blackboard[BB_GIVE_UP_ON_VENT_PATHING])

/// Figure out an exit vent that we should head towards. If we don't have one, default to the entry vent. If they're all kaput, we die.
/datum/ai_behavior/crawl_around_vents/proc/calculate_exit_vent(datum/ai_controller/controller, target_key)
	var/obj/machinery/atmospherics/components/unary/vent_pump/returnable_vent
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent_we_entered_through = controller.blackboard[target_key]

	var/datum/pipeline/entry_vent_parent = entry_vent.parents[1]
	var/list/potential_exits = list()

	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in entry_vent_parent.other_atmos_machines)
		if(check_vent(vent))
			potential_exits.Add(vent)

	if(length(potential_exits))
		returnable_vent = pick(potential_exits)
		return returnable_vent

	// if we're here, we're in "what the flarp" mode... okay maybe we can default to the vent we entered in.
	returnable_vent = vent_we_entered_through
	if(check_vent(vent_we_entered_through))
		// AH WHAT THE FUCK. okay, maybe we're not inside the vents yet? let's return null and we can pick up on that based on the wider context of the proc that invokes it.
		return null

	return returnable_vent // we return null in case something yonked between then and now so it's all good man

/// We've had enough horsing around in the vents, it's time to get out.
/datum/ai_behavior/crawl_around_vents/proc/exit_the_vents(datum/ai_controller/controller)
	var/obj/machinery/atmospherics/components/unary/vent_pump/returnable_vent
	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = controller.blackboard[BB_EXIT_VENT_TARGET]
	var/mob/living/cached_pawn = controller.pawn
	if(check_vent(exit_vent) && !cached_pawn.can_enter_vent(entry_vent, provide_feedback = FALSE))
		// oh shit, something happened while we were waiting on that timer. let's figure out a different way to get out of here.
		returnable_vent = calculate_exit_vent(controller)
		if(isnull(returnable_vent))
			// it's joever. we cooked too hard.
			suicide_pill(controller, target_key)

		addtimer(CALLBACK(src, PROC_REF(exit_the_vents), controller), (rand(lower_vent_time_limit, upper_vent_time_limit) / 2)) // we're in danger mode, so scurry out at half the time it would normally take.
		return

	cached_pawn.handle_ventcrawl(target)
	if(HAS_TRAIT(TRAIT_MOVE_VENTCRAWLING)) // how'd we fail? what the fuck
		stack_trace("We failed to exit the vents, even though we should have been fine? This is very weird.")
		suicide_pill() // all of the prior checks say we should have definitely made it through, but we didn't. dammit.
		return

	finish_action(controller, TRUE) // we did it! we went into the vents and out of the vents. poggers.

/// Simple copy-pasta reducer to see if a vent is valid or not.
/datum/ai_behavior/crawl_around_vents/proc/check_vent(obj/machinery/atmospherics/components/unary/vent_pump/checkable)
	return !QDELETED(checkable) && !checkable.welded

/// Aw fuck, we may have been bested somehow. Regardless of what we do, we can't exit through a vent! Let's end our misery and prevent useless endless calculations.
/datum/ai_behavior/crawl_around_vents/proc/suicide_pill(datum/ai_controller/controller)
	controller.pawn.death(gibbed = TRUE) // call gibbed as true because we are never coming back it is so fucking joever

/datum/ai_behavior/crawl_around_vents/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()

	controller.clear_blackboard_key(target_key)

