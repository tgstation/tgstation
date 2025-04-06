/// Status effect from multiple sources, when all sources are removed, so is the effect
/datum/status_effect/grouped
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	// Grouped effects adds itself to [var/sources] and destroys itself if one exists already, there are never actually multiple
	status_type = STATUS_EFFECT_MULTIPLE
	/// A list of all sources applying this status effect. Sources are a list of keys
	var/list/sources = list()

/datum/status_effect/grouped/on_creation(mob/living/new_owner, source)
	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(existing)
		existing.sources |= source
		merge_with_existing(existing, source)
		qdel(src)
		return FALSE

	sources |= source
	return ..()

/datum/status_effect/grouped/proc/merge_with_existing(datum/status_effect/grouped/existing, source)
	return

/datum/status_effect/grouped/before_remove(source)
	sources -= source
	return !length(sources)
