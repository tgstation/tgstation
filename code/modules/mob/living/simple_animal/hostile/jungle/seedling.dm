#define SEEDLING_STATE_NEUTRAL 0
#define SEEDLING_STATE_WARMUP 1
#define SEEDLING_STATE_ACTIVE 2
#define SEEDLING_STATE_RECOVERY 3

//A plant rooted in the ground that forfeits its melee attack in favor of ranged barrages.
//It will fire flurries of solar energy, and occasionally charge up a powerful blast that makes it vulnerable to attack.
/mob/living/simple_animal/hostile/jungle/seedling
	name = "seedling"
	desc = "This oversized, predatory flower conceals what can only be described as an organic energy cannon, and it will not die until its hidden vital organs are sliced out. \
	 The concentrated streams of energy it sometimes produces require its full attention, attacking it during this time will prevent it from finishing its attack."
	icon = 'icons/mob/jungle/seedling.dmi'
	icon_state = "seedling"
	icon_living = "seedling"
	icon_dead = "seedling_dead"
	maxHealth = 100
	health = 100
	melee_damage_lower = 30
	melee_damage_upper = 30
	pixel_x = -16
	pixel_y = -14
	minimum_distance = 3
	move_to_delay = 20
	vision_range = 9
	aggro_vision_range = 15
	ranged = TRUE
	ranged_cooldown_time = 10
	projectiletype = /obj/projectile/seedling
	projectilesound = 'sound/weapons/pierce.ogg'
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	var/combatant_state = SEEDLING_STATE_NEUTRAL
	var/obj/seedling_weakpoint/weak_point
	var/mob/living/beam_debuff_target
	var/solar_beam_identifier = 0

/obj/projectile/seedling
	name = "solar energy"
	icon_state = "seedling"
	damage = 10
	damage_type = BURN
	light_range = 2
	flag = ENERGY
	light_color = LIGHT_COLOR_YELLOW
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	nondirectional_sprite = TRUE

/mob/living/simple_animal/hostile/jungle/seedling/Goto()
	if(combatant_state != SEEDLING_STATE_NEUTRAL)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/update_icons()
	. = ..()
	if(!stat)
		switch(combatant_state)
			if(SEEDLING_STATE_NEUTRAL)
				icon_state = "seedling"
			if(SEEDLING_STATE_WARMUP)
				icon_state = "seedling_charging"
			if(SEEDLING_STATE_ACTIVE)
				icon_state = "seedling_fire"
			if(SEEDLING_STATE_RECOVERY)
				icon_state = "seedling"

#undef SEEDLING_STATE_NEUTRAL
#undef SEEDLING_STATE_WARMUP
#undef SEEDLING_STATE_ACTIVE
#undef SEEDLING_STATE_RECOVERY
