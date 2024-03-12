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
	source.apply_status_effect(/datum/status_effect/full_throttle_boost)

/// Removes itself if you die, buffs your saiyan limbs if you do not
/datum/status_effect/full_throttle_boost
	id = "full_throttle_boost"
	alert_type = null

/datum/status_effect/full_throttle_boost/on_apply()
	. = ..()
	if (!.)
		return FALSE

	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_died))
	return TRUE

/datum/status_effect/full_throttle_boost/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_STATCHANGE, COMSIG_LIVING_DEATH))

/// Upgrade all of your limb stats if you recovered, wow
/datum/status_effect/full_throttle_boost/proc/on_stat_changed(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if (new_stat != CONSCIOUS || !iscarbon(source))
		return

	var/mob/living/carbon/limb_haver = owner
	var/upgraded = 0
	for (var/obj/item/bodypart/part as anything in limb_haver.bodyparts)
		if (!HAS_TRAIT(part, TRAIT_SAIYAN_STRENGTH))
			continue
		part.unarmed_damage_high += 2
		part.unarmed_damage_low += 2
		part.unarmed_effectiveness += 2 // This is maybe stronger than increasing the damage tbqh
		part.brute_modifier = max(0, part.brute_modifier - 0.05)
		part.burn_modifier = max(0, part.burn_modifier - 0.05)
		upgraded++

	if (upgraded > 0)
		to_chat(owner, span_notice("Your near-death experience grants you more strength!"))
		owner.maxHealth += 5 // Fuck knows if this actually does anything

	qdel(src)

/datum/status_effect/full_throttle_boost/proc/on_died(mob/living/source)
	SIGNAL_HANDLER
	qdel(src)
