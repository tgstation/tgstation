/// A global list of all ongoing hallucinations, primarily for easy access to be able to stop (delete) hallucinations.
GLOBAL_LIST_EMPTY(all_ongoing_hallucinations)

/// Wrapper for _cause_hallucination to use named arguments
#define cause_hallucination(arguments...) _cause_hallucination(list(##arguments))

/// Causes a hallucination of a certain type to the mob.
/// Use the wrapper for named argument support, don't use this.
/mob/living/proc/_cause_hallucination(list/raw_args)
	var/datum/hallucination/hallucination_type = raw_args[1] // first arg is the type always
	if(!ispath(hallucination_type))
		CRASH("cause_hallucination was given a non-hallucination type.")

	var/hallucination_source = raw_args[2] // and second arg, the source
	var/list/passed_args = raw_args.Copy(3)
	passed_args.Insert(1, src)

	var/datum/hallucination/new_hallucination = new hallucination_type(arglist(passed_args))
	if(QDELETED(new_hallucination))
		return
	if(!new_hallucination.start())
		qdel(new_hallucination)
		return

	investigate_log("was afflicted with a hallucination of type [hallucination_type] by: [hallucination_source]. ([new_hallucination.feedback_details])", INVESTIGATE_HALLUCINATIONS)
	return new_hallucination

/**
 * Emits a hallucinating pulse around the passed atom.
 * Affects everyone in the passed radius who can view the center,
 * except for those with TRAIT_MADNESS_IMMUNE, or those who are blind.
 *
 * center - required, the center of the pulse
 * radius - the radius around that the pulse reaches
 * hallucination_duration - how much hallucination is added by the pulse. reduced based on distance to the center.
 * hallucination_max_duration - a cap on how much hallucination can be added
 * optional_messages - optional list of messages passed. Those affected by pulses will be given one of the messages in said list.
 */
/proc/visible_hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/nearby_living in view(center, radius))
		if(HAS_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE) || (nearby_living.mind && HAS_TRAIT(nearby_living.mind, TRAIT_MADNESS_IMMUNE)))
			continue

		if(nearby_living.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.adjust_timed_status_effect(hallucination_duration * dist, /datum/status_effect/hallucination, max_duration = hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))
