/datum/status_effect/accesshunter
	id = "accesshunter"
	duration = 4 SECONDS
	tick_interval = -1
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE
	var/datum/weakref/linked_belt
	on_remove_on_mob_delete = TRUE

//Stolen from /datum/status_effect/death_sound

/datum/status_effect/accesshunter/on_apply()

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	return TRUE

/datum/status_effect/accesshunter/proc/on_death()

	SIGNAL_HANDLER

	if(linked_belt)
		var/obj/item/access_hunter/found_belt = linked_belt.resolve()
		if(found_belt)
			found_belt.steal_access(owner)

	owner.remove_status_effect(src)

/datum/status_effect/accesshunter/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)