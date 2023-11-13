#define BASE_HEAL 4

/datum/component/netpod_healing

/datum/component/netpod_healing/Initialize(obj/machinery/netpod/pod)
	if (!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(pod, COMSIG_BITRUNNER_NETPOD_OPENED, PROC_REF(on_opened))

	var/mob/living/carbon/player = parent
	player.apply_status_effect(/datum/status_effect/embryonic, STASIS_NETPOD_EFFECT)

	START_PROCESSING(SSmachines, src)

/datum/component/netpod_healing/Destroy(force, silent)
	STOP_PROCESSING(SSmachines, src)

	var/mob/living/carbon/player = parent
	player.remove_status_effect(/datum/status_effect/embryonic)

	return ..()

/datum/component/netpod_healing/process(seconds_per_tick)
	var/mob/living/carbon/owner = parent
	if(isnull(owner))
		qdel(src)
		return

	var/need_mob_update = FALSE
	need_mob_update += owner.adjustBruteLoss(-BASE_HEAL * seconds_per_tick, updating_health = FALSE)
	need_mob_update += owner.adjustFireLoss(-BASE_HEAL * seconds_per_tick, updating_health = FALSE)
	need_mob_update += owner.adjustToxLoss(-BASE_HEAL * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	need_mob_update += owner.adjustCloneLoss(-BASE_HEAL * seconds_per_tick, updating_health = FALSE)

	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume += BASE_HEAL * seconds_per_tick

	if(need_mob_update)
		owner.updatehealth()

/// Deletes itself when the machine was opened
/datum/component/netpod_healing/proc/on_opened()
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/embryonic
	id = "embryonic"
	alert_type = /atom/movable/screen/alert/status_effect/embryonic

/datum/status_effect/embryonic/on_apply()
	ADD_TRAIT(owner, TRAIT_STASIS, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/embryonic/on_remove()
	REMOVE_TRAIT(owner, TRAIT_STASIS, TRAIT_STATUS_EFFECT(id))

/atom/movable/screen/alert/status_effect/embryonic
	name = "Embryonic Stasis"
	icon_state = "netpod_stasis"
	desc = "You feel like you're in a dream."

#undef BASE_HEAL
