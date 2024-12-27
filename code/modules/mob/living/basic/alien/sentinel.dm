/mob/living/basic/alien/sentinel
	name = "alien sentinel"
	icon_state = "aliens"
	icon_living = "aliens"
	icon_dead = "aliens_dead"
	health = 150
	maxHealth = 150
	melee_damage_lower = 15
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/alien/sentinel

	///The type of projectile that fires from attacks.
	var/projectiletype = /obj/projectile/neurotoxin/damaging
	///The sound that plays when the projectile is fired.
	var/projectilesound = 'sound/items/weapons/pierce.ogg'

/mob/living/basic/alien/sentinel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = projectiletype, projectile_sound = projectilesound, cooldown_time = 1 SECONDS)
