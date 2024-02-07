/// Increments a blackboard key while the attached mob is engaged with a particular target, does nothing else on its own
/datum/component/ai_target_timer
	/// Blackboard key to store data inside
	var/increment_key
	/// Blackboard key to watch to indicate whether we are 'in combat'
	var/target_key
	/// Amount of time we have spent focused on one target
	var/time_on_target = 0
	/// The last target we had
	var/atom/last_target
	/// Timer used to see if you
	var/reset_clock_timer

/datum/component/ai_target_timer/Initialize(increment_key = BB_BASIC_MOB_HAS_TARGET_TIME, target_key = BB_BASIC_MOB_CURRENT_TARGET)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/mob_parent = parent
	if (isnull(mob_parent.ai_controller))
		return COMPONENT_INCOMPATIBLE
	src.increment_key = increment_key
	src.target_key = target_key

/datum/component/ai_target_timer/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(changed_target))
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(lost_target))
	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/ai_target_timer/UnregisterFromParent()
	finalise_losing_target()
	UnregisterSignal(parent, list(COMSIG_AI_BLACKBOARD_KEY_SET(target_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key)))
	REMOVE_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)
	return ..()

/datum/component/ai_target_timer/Destroy(force)
	finalise_losing_target()
	return ..()

/// When we get a new target, reset the timer and start processing
/datum/component/ai_target_timer/proc/changed_target(mob/living/source)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	var/atom/new_target = living_parent.ai_controller.blackboard[target_key]
	deltimer(reset_clock_timer)
	if (new_target == last_target)
		return
	time_on_target = 0
	store_current_time()
	START_PROCESSING(SSdcs, src)
	if (!isnull(last_target))
		UnregisterSignal(last_target, COMSIG_QDELETING)
	RegisterSignal(new_target, COMSIG_QDELETING, PROC_REF(finalise_losing_target))
	last_target = new_target

/// When we lose our target, start a short timer in case we reacquire it very quickly
/datum/component/ai_target_timer/proc/lost_target()
	SIGNAL_HANDLER
	reset_clock_timer = addtimer(CALLBACK(src, PROC_REF(finalise_losing_target)), 3 SECONDS, TIMER_STOPPABLE | TIMER_DELETE_ME)

/// Called if we have had no target for long enough
/datum/component/ai_target_timer/proc/finalise_losing_target()
	deltimer(reset_clock_timer)
	STOP_PROCESSING(SSdcs, src)
	if (!isnull(last_target))
		UnregisterSignal(last_target, COMSIG_QDELETING)
	last_target = null
	time_on_target = 0
	if (!QDELETED(parent))
		store_current_time()

/// Store the current time on our timer in our blackboard key
/datum/component/ai_target_timer/proc/store_current_time()
	var/mob/living/living_parent = parent
	living_parent.ai_controller.set_blackboard_key(increment_key, time_on_target)

/datum/component/ai_target_timer/process(seconds_per_tick)
	time_on_target += seconds_per_tick SECONDS
	store_current_time()
