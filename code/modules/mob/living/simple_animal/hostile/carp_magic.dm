/mob/living/simple_animal/hostile/carp/ranged
	name = "magicarp"
	desc = "50% magic, 50% carp, 100% horrible."
	ranged = 1
	retreat_distance = 2
	minimum_distance = 0 //Between shots they can and will close in to nash
	projectiletype = /obj/projectile/magic
	projectilesound = 'sound/weapons/emitter.ogg'
	maxHealth = 50
	health = 50
	gold_core_spawnable = NO_SPAWN
	greyscale_config = /datum/greyscale_config/carp_magic
	/// List of all projectiles we can fire.
	/// Non-static, because subtypes can have their own lists.
	var/list/allowed_projectile_types

/mob/living/simple_animal/hostile/carp/ranged/Initialize(mapload)
	. = ..()
	allowed_projectile_types = spell_list()
	assign_spell()

/// Returns the list of spells we are allowed to cast
/mob/living/simple_animal/hostile/carp/ranged/proc/spell_list()
	return GLOB.magicarp_spell_types

/// Pick a random spell then update name and colour based on which one we picked
/mob/living/simple_animal/hostile/carp/ranged/proc/assign_spell()
	projectiletype = pick(allowed_projectile_types)
	name = "[GLOB.magicarp_spell_types[projectiletype]] [name]"
	set_greyscale(colors = list(GLOB.magicarp_spell_colours[projectiletype]))


/mob/living/simple_animal/hostile/carp/ranged/chaos
	name = "chaos magicarp"
	desc = "50% carp, 100% magic, 150% horrible."
	color = "#00FFFF"
	maxHealth = 75
	health = 75
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/carp/ranged/chaos/assign_spell()
	return

/mob/living/simple_animal/hostile/carp/ranged/chaos/Shoot()
	projectiletype = pick(allowed_projectile_types)
	apply_colour()
	return ..()

/mob/living/simple_animal/hostile/carp/ranged/xenobiology // these are for the xenobio gold slime pool
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/carp/ranged/xenobiology/spell_list()
	return GLOB.xenobiology_magicarp_spell_types

/mob/living/simple_animal/hostile/carp/ranged/chaos/xenobiology
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/carp/ranged/chaos/xenobiology/spell_list()
	return GLOB.xenobiology_magicarp_spell_types
