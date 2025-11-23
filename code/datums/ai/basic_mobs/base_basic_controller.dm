/datum/ai_controller/basic_controller
	movement_delay = 0.4 SECONDS

/datum/ai_controller/basic_controller/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/basic_mob = new_pawn

	update_speed(basic_mob)
	RegisterSignal(basic_mob, COMSIG_LIVING_BEFRIENDED, PROC_REF(on_tamed))
	RegisterSignal(basic_mob, COMSIG_LIVING_UNFRIENDED, PROC_REF(on_untamed))
	RegisterSignals(basic_mob, list(POST_BASIC_MOB_UPDATE_VARSPEED, COMSIG_MOB_MOVESPEED_UPDATED), PROC_REF(update_speed))
	RegisterSignal(basic_mob, COMSIG_MOB_ATE, PROC_REF(on_mob_eat))

	return ..() //Run parent at end

/datum/ai_controller/basic_controller/on_stat_changed(mob/living/source, new_stat)
	. = ..()
	update_able_to_run()

/datum/ai_controller/basic_controller/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_MOB_INCAPACITATE_CHANGED, PROC_REF(update_able_to_run))
	if(ai_traits & PAUSE_DURING_DO_AFTER)
		RegisterSignals(pawn, list(COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_able_to_run))


/datum/ai_controller/basic_controller/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_MOB_INCAPACITATE_CHANGED, COMSIG_MOB_STATCHANGE, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))
	return ..()

/datum/ai_controller/basic_controller/get_able_to_run()
	. = ..()
	if(. & AI_UNABLE_TO_RUN)
		return .
	var/mob/living/living_pawn = pawn
	if (living_pawn.stat && !(ai_traits & CAN_ACT_WHILE_DEAD))
		return AI_UNABLE_TO_RUN

	var/ignore_incap_flags = NONE
	if((ai_traits & CAN_ACT_IN_STASIS))
		ignore_incap_flags |= INCAPABLE_STASIS
	if((ai_traits & CAN_ACT_WHILE_GRABBED))
		ignore_incap_flags |= INCAPABLE_GRAB

	if(INCAPACITATED_IGNORING(living_pawn, ignore_incap_flags))
		return AI_UNABLE_TO_RUN

	if(ai_traits & PAUSE_DURING_DO_AFTER && LAZYLEN(living_pawn.do_afters))
		return AI_UNABLE_TO_RUN | AI_PREVENT_CANCEL_ACTIONS //dont erase targets post a do_after

/datum/ai_controller/basic_controller/proc/update_speed(mob/living/basic_mob)
	SIGNAL_HANDLER
	movement_delay = basic_mob.cached_multiplicative_slowdown

/datum/ai_controller/basic_controller/proc/on_mob_eat()
	SIGNAL_HANDLER
	var/food_cooldown = blackboard[BB_EAT_FOOD_COOLDOWN] || EAT_FOOD_COOLDOWN
	set_blackboard_key(BB_NEXT_FOOD_EAT, world.time + food_cooldown)


/datum/ai_controller/proc/on_tamed(datum/source, mob/living/new_friend)
	SIGNAL_HANDLER
	forgive_target(new_friend)
	clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST) //we have just been tamed by a new party, clean slate for everyone!
	RegisterSignal(new_friend, COMSIG_LIVING_MADE_NEW_FRIEND, PROC_REF(on_master_tame))

/datum/ai_controller/proc/on_untamed(datum/source, mob/living/old_friend)
	SIGNAL_HANDLER
	UnregisterSignal(old_friend, COMSIG_LIVING_MADE_NEW_FRIEND)

/datum/ai_controller/proc/on_master_tame(datum/master, mob/living/master_new_friend)
	SIGNAL_HANDLER
	forgive_target(master_new_friend)

/datum/ai_controller/proc/forgive_target(atom/target)
	var/static/list/keys_to_check = list(
		BB_BASIC_MOB_CURRENT_TARGET,
		BB_CURRENT_PET_TARGET,
	)
	for(var/key in keys_to_check)
		if(target == blackboard[key])
			clear_blackboard_key(key)
	remove_from_blackboard_lazylist_key(BB_BASIC_MOB_RETALIATE_LIST, target) //make peace with our friend's new pet!
