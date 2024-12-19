/// Maximum severity level possible.
#define MAX_SEVERITY 3

/// Nearsighted
/datum/status_effect/grouped/nearsighted
	id = "nearsighted"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	// This is not "remove on fullheal" as in practice,
	// fullheal should instead remove all the sources and in turn cure this

	/// Static list of signals that, when received, we force an update to our nearsighted overlay
	var/static/list/update_signals = list(
		SIGNAL_ADDTRAIT(TRAIT_NEARSIGHTED_CORRECTED),
		SIGNAL_REMOVETRAIT(TRAIT_NEARSIGHTED_CORRECTED),
		SIGNAL_ADDTRAIT(TRAIT_SIGHT_BYPASS),
		SIGNAL_REMOVETRAIT(TRAIT_SIGHT_BYPASS),
	)

	/* ("source_id" = num) */
	/// Associated list of sources with their supplied severity level. Cannot be corrected with glasses.
	var/absolute_sources = list()
	/// Associated list of sources with their supplied severity level. Can be corrected with glasses.
	var/correctable_sources = list()

	/// Highest severity value in [var/absolute_sources].
	var/absolute_severity = 0
	/// Highest severity value in [var/correctable_sources].
	var/correctable_severity = 0

/datum/status_effect/grouped/nearsighted/source_added(source, severity = 2, correctable = TRUE)
	set_severity(source, severity, correctable)

/datum/status_effect/grouped/nearsighted/source_removed(source, removing)
	if(correctable_sources[source])
		correctable_sources -= source
		recalculate_severity(correctable=TRUE)
	if(absolute_sources[source])
		absolute_sources -= source
		recalculate_severity(correctable=FALSE)
	if(!removing) //so the overlay doesn't update twice
		update_nearsighted_overlay()

/datum/status_effect/grouped/nearsighted/on_apply()
	RegisterSignals(owner, update_signals, PROC_REF(update_nearsightedness))
	update_nearsighted_overlay()
	return ..()

/datum/status_effect/grouped/nearsighted/on_remove()
	UnregisterSignal(owner, update_signals)
	owner.clear_fullscreen(id)
	return ..()

/// Signal proc for when we gain or lose [TRAIT_NEARSIGHTED_CORRECTED] - (temporarily) disable the overlay if we're correcting it
/datum/status_effect/grouped/nearsighted/proc/update_nearsightedness(datum/source)
	SIGNAL_HANDLER
	update_nearsighted_overlay()

/// Checks if we should be nearsighted currently, or if we should clear the overlay
/datum/status_effect/grouped/nearsighted/proc/should_be_nearsighted()
	if(HAS_TRAIT(owner, TRAIT_SIGHT_BYPASS))
		return NEARSIGHTED_DISABLED
	if(HAS_TRAIT(owner, TRAIT_NEARSIGHTED_CORRECTED))
		return NEARSIGHTED_CORRECTED
	return NEARSIGHTED_ENABLED

/// Updates our nearsightd overlay, either removing it if we have the trait or adding it if we don't
/datum/status_effect/grouped/nearsighted/proc/update_nearsighted_overlay()
	var/severity = get_severity()
	if(severity <= 0) // We aren't nearsighted
		owner.clear_fullscreen(id)
	else
		owner.overlay_fullscreen(id, /atom/movable/screen/fullscreen/impaired, severity)

/// Gets the severity value that would be used when calculating impairment.
/datum/status_effect/grouped/nearsighted/proc/get_severity()
	var/are_we_nearsighted = should_be_nearsighted()

	if(!are_we_nearsighted)
		return 0

	var/final_severity = absolute_severity
	if(are_we_nearsighted != NEARSIGHTED_CORRECTED) //We don't have corrective vision
		final_severity = max(absolute_severity, correctable_severity)

	final_severity = min(final_severity, MAX_SEVERITY)

	return final_severity

/// Sets the severity of a source. Recalculates the severity variables if there is a change
/datum/status_effect/grouped/nearsighted/proc/set_severity(source, new_severity, correctable = FALSE)
	if(!source)
		return
	if(!isnum(new_severity))
		return

	var/list/to_search = correctable ? correctable_sources : absolute_sources
	if(to_search[source] == new_severity)
		return

	if(new_severity > 0)
		to_search[source] = new_severity
	else
		to_search -= source

	recalculate_severity(correctable)

	/* If we have no more of this source, let's remove it (and potentially ourselves) */
	if(!absolute_sources[source] && !correctable_sources[source])
		owner.remove_status_effect(type, source) //this will update our overlay as well if we're still around
	else
		update_nearsighted_overlay()

/datum/status_effect/grouped/nearsighted/proc/recalculate_severity(correctable)
	if(isnull(correctable))
		CRASH("was not provided with an argument (this needs to be explicit)")

	var/highest_severity = 0
	var/list/to_search = correctable ? correctable_sources : absolute_sources

	for(var/existing_source in to_search)
		var/candidate = to_search[existing_source]
		if(candidate > highest_severity)
			highest_severity = candidate

	if(correctable)
		correctable_severity = highest_severity
	else
		absolute_severity = highest_severity

#undef MAX_SEVERITY
