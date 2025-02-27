/// A component that is given to a body when the soul inside is inhabiting a soulcatcher. this is mostly here so that the bodies of souls can be revived.
/datum/component/previous_body
	/// What soulcatcher soul do we need to return to the body?
	var/datum/weakref/soulcatcher_soul
	/// Do we want to try and restore the mind when this is destroyed?
	var/restore_mind = TRUE

/datum/component/previous_body/Initialize(...)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_SOULCATCHER_CHECK_SOUL, PROC_REF(signal_destroy))
	RegisterSignal(parent, COMSIG_SOULCATCHER_SCAN_BODY, PROC_REF(scan_body))

/// Destroys the source component through a signal. `mind_restored` controls whether or not the mind will be grabbed upon deletion.
/datum/component/previous_body/proc/signal_destroy(mob/source_mob, mind_restored = TRUE)
	SIGNAL_HANDLER
	if(!mind_restored)
		restore_mind = FALSE

	qdel(src)

	return TRUE

/// Attempts to scan the soul referenced in the `soulcatcher_soul` variable. Returns TRUE if the soul has been scanned, otherwise returns FALSE
/datum/component/previous_body/proc/scan_body(mob/source_mob)
	SIGNAL_HANDLER

	if(!soulcatcher_soul)
		return FALSE

	var/mob/living/soulcatcher_soul/target_soul = soulcatcher_soul.resolve()
	if(!target_soul || !target_soul.body_scan_needed)
		return FALSE

	to_chat(target_soul, span_cyan("Your body has scanned, revealing your true identity."))
	target_soul.name = source_mob.real_name
	target_soul.body_scan_needed = FALSE

	var/datum/preferences/preferences = target_soul.client?.prefs
	if(preferences)
		var/total_desc = preferences.read_preference(/datum/preference/text/flavor_short_desc)
		total_desc = "[total_desc]\n\n" + preferences.read_preference(/datum/preference/text/flavor_extended_desc)
		target_soul.soul_desc = total_desc

	return TRUE

/// Attempts to destroy the component. If `restore_mind` is true, it will attempt to place the mind back inside of the body and delete the soulcatcher soul.
/datum/component/previous_body/Destroy(force)
	UnregisterSignal(parent, COMSIG_SOULCATCHER_CHECK_SOUL)
	UnregisterSignal(parent, COMSIG_SOULCATCHER_SCAN_BODY)

	if(restore_mind)
		var/mob/living/original_body = parent
		var/mob/living/soulcatcher_soul/soul = soulcatcher_soul.resolve()
		if(original_body && soul && !original_body.mind)
			var/datum/mind/mind_to_tranfer = soul.mind
			if(mind_to_tranfer)
				mind_to_tranfer.transfer_to(original_body)

			soul.previous_body = FALSE
			qdel(soul)

	return ..()
