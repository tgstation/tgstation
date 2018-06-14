

/mob/living/carbon/human/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE)
	// depending on the species, it will run the corresponding apply_damage code there
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src)

//Rebooting IPCs via weldheal/cableheal
/mob/living/carbon/human/revive(full_heal = 0, admin_revive = 0)
	if(..())
		if(dna && dna.species)
			dna.species.spec_revival(src)