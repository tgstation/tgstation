/// A warrior's heart which gains experience from fighting (and losing)
/obj/item/organ/internal/heart/saiyan
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5 // Vulnerable to heart disease

/obj/item/organ/internal/heart/saiyan/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))

/obj/item/organ/internal/heart/saiyan/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOB_STATCHANGE)

/// When we enter crit, prepare for a zenkai boost
/obj/item/organ/internal/heart/saiyan/proc/on_stat_changed(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if (new_stat != UNCONSCIOUS)
		return
	source.apply_status_effect(/datum/status_effect/saiyan_survivor_tracker)

/// Removes itself if you die, buffs your saiyan limbs if you do not
/datum/status_effect/saiyan_survivor_tracker
	id = "saiyan_survivor_tracker"
	alert_type = null

/datum/status_effect/saiyan_survivor_tracker/on_apply()
	. = ..()
	if (!.)
		return FALSE

	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_died))
	return TRUE

/datum/status_effect/saiyan_survivor_tracker/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_DEATH))

/// Upgrade all of your limb stats if you recovered, wow
/datum/status_effect/saiyan_survivor_tracker/proc/on_stat_changed(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if (new_stat != CONSCIOUS || !iscarbon(source))
		return
	SEND_SIGNAL(source, COMSIG_SAIYAN_SURVIVOR)
	qdel(src)

/datum/status_effect/saiyan_survivor_tracker/proc/on_died(mob/living/source)
	SIGNAL_HANDLER
	qdel(src)
