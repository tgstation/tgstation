#define TRAIT_METEOR_SHIELD_FIELD_MONITORED	"meteor_shield_field_monitored"

GLOBAL_LIST_EMPTY_TYPED(meteor_shielded_turfs, /turf/open)

/// Stupid element to handle tracking which turfs are in a meteor sat's range,
/// without messing up in situations like with overlapping ranges.
/datum/element/meteor_shield_coverage
	// Detach whenever destroyed, so we can ensure there's no hanging references to the turf in GLOB.meteor_shielded_turfs
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	/// Signals to attach to all turfs.
	var/static/list/attach_signals = list(
		SIGNAL_ADDTRAIT(TRAIT_COVERED_BY_METEOR_SHIELD),
		SIGNAL_REMOVETRAIT(TRAIT_COVERED_BY_METEOR_SHIELD)
	)

/datum/element/meteor_shield_coverage/Attach(turf/open/target)
	. = ..()
	if(!isgroundlessturf(target))
		return ELEMENT_INCOMPATIBLE
	// We use a trait to prevent duplicate assignments.
	if(!HAS_TRAIT(target, TRAIT_METEOR_SHIELD_FIELD_MONITORED))
		ADD_TRAIT(target, TRAIT_METEOR_SHIELD_FIELD_MONITORED, ELEMENT_TRAIT(type))
		RegisterSignals(target, attach_signals, PROC_REF(update_global_shield_list))
		GLOB.meteor_shielded_turfs += target

/datum/element/meteor_shield_coverage/Detach(turf/open/target)
	REMOVE_TRAIT(target, TRAIT_METEOR_SHIELD_FIELD_MONITORED, ELEMENT_TRAIT(type))
	UnregisterSignal(target, attach_signals)
	GLOB.meteor_shielded_turfs -= target
	return ..()

/datum/element/meteor_shield_coverage/proc/update_global_shield_list(turf/open/source)
	SIGNAL_HANDLER
	if(!isgroundlessturf(source) || !HAS_TRAIT(source, TRAIT_COVERED_BY_METEOR_SHIELD))
		source.RemoveElement(/datum/element/meteor_shield_coverage)

/proc/get_meteor_sat_coverage() as num
	return length(GLOB.meteor_shielded_turfs)

#undef TRAIT_METEOR_SHIELD_FIELD_MONITORED
