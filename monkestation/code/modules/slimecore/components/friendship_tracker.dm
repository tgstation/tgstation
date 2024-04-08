/datum/component/friendship_container
	///our friendship thresholds from lowest to highest
	var/list/friendship_levels = list()
	///our current friends stored as a weakref = amount
	var/list/weakrefed_friends = list()
	///list of friendship levels that we send BEFRIEND signals on, if someone drops below these levels its over
	var/befriend_level
	///list of all befriended refs
	var/list/befriended_refs = list()

/datum/component/friendship_container/Initialize(friendship_levels = list(), befriend_level)
	. = ..()
	if(!length(friendship_levels))
		return FALSE

	src.friendship_levels = friendship_levels
	src.befriend_level = befriend_level


/datum/component/friendship_container/RegisterWithParent()
	RegisterSignal(parent, COMSIG_FRIENDSHIP_CHECK_LEVEL, PROC_REF(check_friendship_level))
	RegisterSignal(parent, COMSIG_FRIENDSHIP_CHANGE, PROC_REF(change_friendship))

/datum/component/friendship_container/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_FRIENDSHIP_CHECK_LEVEL)
	UnregisterSignal(parent, COMSIG_FRIENDSHIP_CHANGE)

/datum/component/friendship_container/proc/change_friendship(mob/living/source, atom/target, amount)
	for(var/datum/weakref/ref as anything in weakrefed_friends)
		if(ref.resolve() == target)

			///handles registering pet commands and other things that use BEFRIEND
			if(amount < 0)
				if((friendship_levels[befriend_level] > weakrefed_friends[ref]) && (ref in befriended_refs))
					SEND_SIGNAL(parent, COMSIG_LIVING_UNFRIENDED, ref.resolve())
					befriended_refs -= ref
					source.ai_controller?.remove_thing_from_blackboard_key(BB_FRIENDS_LIST, target)

			else if((friendship_levels[befriend_level] <= weakrefed_friends[ref]) && !(ref in befriended_refs))
				SEND_SIGNAL(parent, COMSIG_LIVING_BEFRIENDED, ref.resolve())
				befriended_refs += ref
				source.ai_controller?.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, target)

			weakrefed_friends[ref] += amount
			return TRUE
	weakrefed_friends += list(WEAKREF(target) = amount)
	return TRUE

///Returns {TRUE} if friendship is above a certain threshold else returns {FALSE}
/datum/component/friendship_container/proc/check_friendship_level(mob/living/source, atom/target, friendship_level)
	for(var/datum/weakref/ref as anything in weakrefed_friends)
		if(ref.resolve() == target)
			if(friendship_levels[friendship_level] <= weakrefed_friends[ref])
				return TRUE
			return FALSE
	return FALSE
