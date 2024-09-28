/datum/corpse_damage/post_mortem/organ_decay
	damage_type = CORPSE_DAMAGE_ORGAN_DECAY
	var/max_decay_time = 40 MINUTES

/datum/corpse_damage/post_mortem/organ_decay/apply_to_body(mob/living/carbon/human/body, severity)
	if(!body.organs)
		return FALSE

	// * 0.5 because life ticks happen about every 2 seconds (we really need a way to get the current life tickspeed)
	var/decay_ticks = max_decay_time * severity * 0.5

	for(var/obj/item/organ/internal/internal in body.organs)
		internal.apply_organ_damage(decay_ticks * internal.decay_factor)

	return TRUE

/datum/corpse_damage/post_mortem/organ_decay/light
	max_decay_time = 15 MINUTES

/datum/corpse_damage/post_mortem/organ_decay/heavy
	max_decay_time = 48 HOURS
