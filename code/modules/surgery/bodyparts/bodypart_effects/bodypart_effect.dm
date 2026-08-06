/// Effects added to a carbon focused on the bodyparts itself, such as adding a photosynthesis component that
/datum/status_effect/grouped/bodypart_effect
	id = "bodypart_effect"
	duration = STATUS_EFFECT_PERMANENT
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS

	/// List of bodyparts contributing to this effect
	var/list/bodyparts = list()
	/// Minimum amount of bodyparts required for on_apply to be called. When tipping below, on_remove is called
	var/minimum_bodyparts = 1
	/// Are we currently active? We don't NEED to track it, but it's a lot easier and faster if we do
	var/is_active = FALSE

/datum/status_effect/grouped/bodypart_effect/source_added(source, obj/item/bodypart/bodypart, special, lazy)
	add_bodypart(bodypart, special, lazy)

/// Merge a bodypart into the effect
/datum/status_effect/grouped/bodypart_effect/proc/add_bodypart(obj/item/bodypart/bodypart, special, lazy)
	RegisterSignal(bodypart, COMSIG_BODYPART_REMOVED, PROC_REF(on_bodypart_removed))
	RegisterSignal(bodypart, COMSIG_QDELETING, PROC_REF(on_bodypart_destroyed))

	bodyparts.Add(bodypart)

	if(!is_active && bodyparts.len >= minimum_bodyparts)
		activate()

/// Remove a bodypart from the effect. Deleting = TRUE is used during clean-up phase
/datum/status_effect/grouped/bodypart_effect/proc/remove_bodypart(mob/living/carbon/old_owner, obj/item/bodypart/bodypart, deleting)
	UnregisterSignal(bodypart, list(COMSIG_BODYPART_REMOVED, COMSIG_QDELETING))

	bodyparts.Remove(bodypart)

	if(deleting)
		return

	if(bodyparts.len == 0 && !QDELETED(old_owner))
		qdel(src)

	else if(is_active && bodyparts.len < minimum_bodyparts)
		deactivate()

/// Signal called when a bodypart is removed
/datum/status_effect/grouped/bodypart_effect/proc/on_bodypart_removed(obj/item/bodypart/bodypart, special)
	SIGNAL_HANDLER

	remove_bodypart(owner, bodypart)

/// Signal called when a bodypart is destroyed. Destruction of a bodypart doesn't necessarily drop it
/datum/status_effect/grouped/bodypart_effect/proc/on_bodypart_destroyed(obj/item/bodypart/bodypart)
	SIGNAL_HANDLER

	remove_bodypart(bodypart.owner, bodypart)

/// Activate some sort of effect when a threshold is reached
/datum/status_effect/grouped/bodypart_effect/proc/activate()
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	is_active = TRUE
	// Maybe add support for different stages? AKA add a stronger effect when there are more limbs

/// Remove an effect whenever a threshold is no longer reached
/datum/status_effect/grouped/bodypart_effect/proc/deactivate()
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	is_active = FALSE

/// Clean up all references and self-destruct
/datum/status_effect/grouped/bodypart_effect/Destroy()
	deactivate()
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		remove_bodypart(bodypart.owner, bodypart, deleting = TRUE)

	return ..()
