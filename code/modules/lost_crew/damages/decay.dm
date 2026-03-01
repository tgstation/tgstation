/// We simulate decay on bodies. This is always used, but severity can differ (though tending to the more severe)
/datum/corpse_damage/post_mortem/organ_decay
	damage_type = CORPSE_DAMAGE_ORGAN_DECAY
	/// The max amount of decay we can apply to organs, scaled by severity
	var/max_decay_time = 40 MINUTES

/datum/corpse_damage/post_mortem/organ_decay/apply_to_body(mob/living/carbon/human/body, severity, list/sorage, list/datum/callback/on_revive_and_player_occupancy)
	if(!body.organs)
		return FALSE

	// * 0.5 because life ticks happen about every 2 seconds (we really need a way to get the current life tickspeed)
	var/decay_ticks = max_decay_time * severity * 0.5

	for(var/obj/item/organ/internal in body.organs)
		internal.apply_organ_damage(decay_ticks * internal.decay_factor)

	return TRUE

/datum/corpse_damage/post_mortem/organ_decay/light
	max_decay_time = 15 MINUTES

/datum/corpse_damage/post_mortem/organ_decay/heavy
	max_decay_time = 48 HOURS
