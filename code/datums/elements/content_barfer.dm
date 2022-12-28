/**
 * Content Barfer; which expels the contents of a mob when it dies, or is transformed
 *
 * Used for morphs and bileworms!
 */
/datum/element/content_barfer
	argument_hash_start_idx = 2

/datum/element/content_barfer/Attach(datum/target, tally_string)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignals(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_ON_WABBAJACKED), PROC_REF(barf_contents))

/datum/element/content_barfer/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_ON_WABBAJACKED))
	return ..()

/datum/element/content_barfer/proc/barf_contents(mob/living/target)
	SIGNAL_HANDLER

	for(var/atom/movable/barfed_out in target)
		barfed_out.forceMove(target.loc)
		if(prob(90))
			step(barfed_out, pick(GLOB.alldirs))
