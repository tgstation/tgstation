//ion man

/datum/sutando_abilities/ion
	id = "ion"
	value = 7 //you may think this is bullshit, but this ability is actually VERY strong.
	name = "Electronic Disruption"

/datum/sutando_abilities/ion/handle_stats()
	. = ..()
	stand.projectiletype = /obj/item/projectile/ion
	stand.ranged_cooldown_time = 5
	stand.ranged = TRUE
	stand.range += 3
	stand.melee_damage_lower += 3
	stand.melee_damage_upper += 3

/datum/sutando_abilities/ion/ability_act()
	empulse(stand.target, 1, 1)
