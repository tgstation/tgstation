/mob/living/basic/alien/queen
	name = "alien queen"
	icon_state = "alienq"
	icon_living = "alienq"
	icon_dead = "alienq_dead"
	health = 250
	maxHealth = 250
	melee_damage_lower = 15
	melee_damage_upper = 15
	status_flags = NONE //can't shove the queen, kiddo.
	unique_name = FALSE

	ai_controller = /datum/ai_controller/basic_controller/alien/queen

	///The type of projectile that fires from attacks.
	var/projectiletype = /obj/projectile/neurotoxin/damaging
	///The sound that plays when the projectile is fired.
	var/projectilesound = 'sound/weapons/pierce.ogg'

/mob/living/basic/alien/queen/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = projectiletype, projectile_sound = projectilesound, cooldown_time = 1 SECONDS)

/mob/living/basic/alien/queen/large
	name = "alien empress"
	icon = 'icons/mob/nonhuman-player/alienqueen.dmi'
	icon_state = "alienq"
	icon_living = "alienq"
	icon_dead = "alienq_dead"
	health_doll_icon = "alienq"
	bubble_icon = "alienroyal"
	maxHealth = 400
	health = 400
	butcher_results = list(
		/obj/item/food/meat/slab/xeno = 10,
		/obj/item/stack/sheet/animalhide/xeno = 2,
	)
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = NO_SPAWN

