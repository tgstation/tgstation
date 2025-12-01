/**
 * Content Barfer; which expels the contents of a mob when it dies, or is transformed
 *
 * Used for morphs and bileworms!
 */
/datum/element/content_barfer

/datum/element/content_barfer/Attach(datum/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignals(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_UNSHAPESHIFTED, COMSIG_MOB_CHANGED_TYPE), PROC_REF(barf_contents))

/datum/element/content_barfer/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_UNSHAPESHIFTED, COMSIG_MOB_CHANGED_TYPE))
	return ..()

/datum/element/content_barfer/proc/barf_contents(mob/living/target)
	SIGNAL_HANDLER

	for(var/atom/movable/barfed_out as anything in target)
		if(HAS_TRAIT(barfed_out, TRAIT_NOT_BARFABLE))
			continue
		barfed_out.forceMove(target.loc)
		if(prob(90))
			step(barfed_out, pick(GLOB.alldirs))
