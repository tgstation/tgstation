/datum/status_effect/centcom_grace
	id = "centcom_grace"
	tick_interval = -1
	alert_type = null
	var/last_active = FALSE

/datum/status_effect/centcom_grace/on_apply()
	. = ..()
	if(!.)
		return
	giveth_taketh()
	RegisterSignals(owner, list(COMSIG_ENTER_AREA, COMSIG_HUMAN_BEGIN_DUEL, COMSIG_HUMAN_END_DUEL), PROC_REF(giveth_taketh))

/datum/status_effect/centcom_grace/on_remove()
	. = ..()
	take_traits()
	UnregisterSignal(owner, list(COMSIG_ENTER_AREA, COMSIG_HUMAN_BEGIN_DUEL, COMSIG_HUMAN_END_DUEL))

/datum/status_effect/centcom_grace/proc/giveth_taketh()
	SIGNAL_HANDLER
	if(active())
		if(!last_active)
			owner.SetAllImmobility(0)
			owner.set_safe_hunger_level()
			owner.extinguish_mob()
		give_traits()
		last_active = TRUE
	else
		take_traits()
		last_active = FALSE

/datum/status_effect/centcom_grace/proc/active()
	. = TRUE
	if(istype(owner, /mob/living/carbon/human/ghost))
		var/mob/living/carbon/human/ghost/ghost_owner = owner
		if(ghost_owner.dueling)
			return FALSE
	var/area/centcom/centcom_area = get_area(owner)
	if(!istype(centcom_area) || !centcom_area.grace)
		return FALSE

/datum/status_effect/centcom_grace/proc/give_traits()
	if(QDELETED(owner))
		qdel(src)
		return
	owner.add_traits(list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_STABLEHEART,
		TRAIT_STABLELIVER,
		TRAIT_BOMBIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_TUMOR_SUPPRESSED,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NOFIRE,
		TRAIT_NODISMEMBER
	), id)

/datum/status_effect/centcom_grace/proc/take_traits()
	if(QDELETED(owner))
		qdel(src)
		return
	REMOVE_TRAITS_IN(owner, id)
