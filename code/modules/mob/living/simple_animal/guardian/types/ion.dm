//ion man

/datum/guardian_abilities/ion
	id = "ion"
	value = 7 //you may think this is bullshit, but this ability is actually VERY strong.
	name = "Electronic Disruption"

/datum/guardian_abilities/ion/handle_stats()
	. = ..()
	guardian.projectiletype = /obj/item/projectile/ion
	guardian.ranged_cooldown_time = 5
	guardian.ranged = TRUE
	guardian.range += 3
	guardian.melee_damage_lower += 3
	guardian.melee_damage_upper += 3

/datum/guardian_abilities/ion/ability_act()
	empulse(guardian.target, 1, 1)
