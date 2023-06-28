/// Gondola love, makes hugs inject pax if the arms are exposed
/datum/martial_art/hugs_of_the_gondola
	name = "Hugs of the Gondola"
	id = MARTIALART_HUGS_OF_THE_GONDOLA

/datum/martial_art/hugs_of_the_gondola/help_act(mob/living/attacker, mob/living/defender)
	if(ishuman(defender) && ishuman(attacker))
		var/mob/living/carbon/human/human_attacker = attacker
		var/mob/living/carbon/human/human_defender = defender
		var/list/covered_body_zones = human_attacker.get_covered_body_zones()
		var/pax_injected = 4
		if(BODY_ZONE_L_ARM in covered_body_zones)
			pax_injected -= 2
		if(BODY_ZONE_R_ARM in covered_body_zones)
			pax_injected -= 2
		if(pax_injected)
			human_defender.reagents.add_reagent(/datum/reagent/pax, pax_injected)
			to_chat(defender, span_warning("You feel a tiny prick!"))
	//this is so it hugs/shakes up as usual
	return MARTIAL_ATTACK_INVALID
