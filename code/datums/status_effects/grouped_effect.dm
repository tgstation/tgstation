/// Status effect from multiple sources, when all sources are removed, so is the effect
/datum/status_effect/grouped
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	// Grouped effects adds itself to [var/sources] and destroys itself if one exists already, there are never actually multiple
	status_type = STATUS_EFFECT_MULTIPLE
	/// A list of all sources applying this status effect. Sources are a list of keys
	var/list/sources = list()

/datum/status_effect/grouped/on_creation(mob/living/new_owner, source, ...)
	//Get our supplied arguments, without new_owner
	var/list/new_source_args = args.Copy(2)

	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(existing)
		existing.sources |= source
		existing.source_added(arglist(new_source_args))
		qdel(src)
		return FALSE

	/* We are the original */

	. = ..()
	if(.)
		sources |= source
		source_added(arglist(new_source_args))

/**
 * Called after a source is added to the status effect,
 * this includes the first source added after creation.
 */
/datum/status_effect/grouped/proc/source_added(source, ...)
	return

/**
 * Called after a source is removed from the status effect. \
 * `removing` will be TRUE if this is the last source, which means
 * the effect will be deleted.
 */
/datum/status_effect/grouped/proc/source_removed(source, removing)
	return

/datum/status_effect/grouped/before_remove(source)
	sources -= source
	var/was_last_source = !length(sources)
	source_removed(source, was_last_source)
	return was_last_source
