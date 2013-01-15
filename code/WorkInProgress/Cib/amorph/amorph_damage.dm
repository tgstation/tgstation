/mob/living/carbon/amorph/proc/HealDamage(zone, brute, burn)
	return heal_overall_damage(brute, burn)

/mob/living/carbon/amorph/UpdateDamageIcon()
	// no damage sprites for amorphs yet
	return

/mob/living/carbon/amorph/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/used_weapon = null)
	if(damagetype == BRUTE)
		take_overall_damage(damage, 0)
	else
		take_overall_damage(0, damage)