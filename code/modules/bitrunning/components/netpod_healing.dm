/datum/component/netpod_healing
	/// Brute damage to heal over a second
	var/brute_heal = 0
	/// Burn damage to heal over a second
	var/burn_heal = 0
	/// Toxin damage to heal over a second
	var/toxin_heal = 0
	/// Amount of cloning damage to heal over a second
	var/clone_heal = 0
	/// Amount of blood to heal over a second
	var/blood_heal = 0

/datum/component/netpod_healing/Initialize(
	brute_heal = 0,
	burn_heal = 0,
	toxin_heal = 0,
	clone_heal = 0,
	blood_heal = 0,
)
	var/mob/living/carbon/player = parent
	if (!iscarbon(player))
		return COMPONENT_INCOMPATIBLE

	player.apply_status_effect(/datum/status_effect/embryonic, STASIS_NETPOD_EFFECT)

	START_PROCESSING(SSmachines, src)

	src.brute_heal = brute_heal
	src.burn_heal = burn_heal
	src.toxin_heal = toxin_heal
	src.clone_heal = clone_heal
	src.blood_heal = blood_heal

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
	need_mob_update += owner.adjustBruteLoss(-brute_heal * seconds_per_tick, updating_health = FALSE)
	need_mob_update += owner.adjustFireLoss(-burn_heal * seconds_per_tick, updating_health = FALSE)
	need_mob_update += owner.adjustToxLoss(-toxin_heal * seconds_per_tick, updating_health = FALSE, forced = TRUE)
	need_mob_update += owner.adjustCloneLoss(-clone_heal * seconds_per_tick, updating_health = FALSE)

	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume += blood_heal * seconds_per_tick

	if(need_mob_update)
		owner.updatehealth()

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
