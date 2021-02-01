/mob/living/simple_animal/hostile/lucift //what they all should have
	name = "Lucift"
	desc = "if you read this i fucked up and also you're gay"
	icon = 'icons/mob/valormobs.dmi'
	vision_range = 7
	wander = 1
	pass_flags = PASSTABLE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	del_on_death = TRUE
	robust_searching = 1

/mob/living/simple_animal/hostile/lucift/death()
	new /obj/effect/decal/cleanable/robot_debris(src.loc)
	qdel(src)
	return ..()

/mob/living/simple_animal/hostile/lucift/petasia
	name = "Petasia"
	desc = "The peak of beauty, here to make you beautiful too."
	icon_state = "petasia"
	maxHealth = 600
	health = 600
	speed = 4
	move_to_delay = 4
	armour_penetration = 30
	melee_damage_lower = 30
	melee_damage_upper = 30
	attack_verb_continuous = "stabs"
	attack_verb_simple = "stab"
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

/mob/living/simple_animal/hostile/lucift/gello
	name = "Gello"
	desc = "A beautiful creature cut in half."
	icon_state = "gello"
	maxHealth = 80
	health = 80
	speed = 8
	move_to_delay = 12
	melee_damage_lower = 10
	melee_damage_upper = 10

/mob/living/simple_animal/hostile/lucift/byzo
	name = "Byzo"
	desc = "A shambling, beautiful creature."
	maxHealth = 130
	health = 130
	icon_state = "byzo"
	speed = 7
	move_to_delay = 7
	melee_damage_lower = 20
	melee_damage_upper = 20

