
/// depending on the species, it will run the corresponding apply_damage code there
/mob/living/carbon/human/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE)
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, forced, spread_damage)
