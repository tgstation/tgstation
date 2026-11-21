/mob/living/carbon/human/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype = ALL)
	. = ..()
	if(. >= 0) // 0 = no damage, + values = healed damage
		return .

	if(AT_TOXIN_VOMIT_THRESHOLD(src))
		apply_status_effect(/datum/status_effect/tox_vomit)

/mob/living/carbon/human/set_tox_loss(amount, updating_health, forced, required_biotype)
	. = ..()
	if(. >= 0)
		return .

	if(AT_TOXIN_VOMIT_THRESHOLD(src))
		apply_status_effect(/datum/status_effect/tox_vomit)
