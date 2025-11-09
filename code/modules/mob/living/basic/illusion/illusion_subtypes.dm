/mob/living/basic/illusion/escape
	retreat_distance = 10
	minimum_distance = 10
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -1
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE


/mob/living/basic/illusion/escape/AttackingTarget()
	return FALSE

/mob/living/basic/illusion/mirage
	AIStatus = AI_OFF
	density = FALSE

/mob/living/basic/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()
