/// An element that lets this mob see other mobs while ventcrawling
/datum/element/see_mobs_while_ventcrawling
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/see_mobs_while_ventcrawling/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_RESTORE_INITIAL_SIGHT, PROC_REF(on_restore_initial_sight))

	var/mob/living/living_target = target
	living_target.update_sight()

/datum/element/see_mobs_while_ventcrawling/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_LIVING_RESTORE_INITIAL_SIGHT)

	var/mob/living/living_source = source
	living_source.update_sight()
	return ..()

/datum/element/see_mobs_while_ventcrawling/proc/on_restore_initial_sight(mob/living/source)
	SIGNAL_HANDLER
	if (HAS_TRAIT(source, TRAIT_MOVE_VENTCRAWLING) && istype(source.loc, /obj/machinery/atmospherics))
		return SEE_MOBS
