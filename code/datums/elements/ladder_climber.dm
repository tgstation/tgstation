/// Simple element that allows mobs to climb ladders by clicking.
/datum/element/ladder_climber
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/ladder_climber/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return

	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(check_and_climb_ladder))

/datum/element/ladder_climber/Detach(datum/target)
	UnregisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	return ..()

/// Proc that checks if we're attacking a ladder, and then climbs it. Only return COMPONENT_HOSTILE_NO_ATTACK if we successfully use the ladder.
/datum/element/ladder_climber/proc/check_and_climb_ladder(mob/living/climber, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/ladder))
		return

	var/obj/structure/ladder/laddy = target
	INVOKE_ASYNC(laddy, PROC_REF(use), climber) // something in here sleeps and it's way too deep in the logic to find
	return COMPONENT_HOSTILE_NO_ATTACK
