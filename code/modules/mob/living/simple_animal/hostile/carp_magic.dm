/// A list of spells magicarp can use and a corresponding name prefix to apply
GLOBAL_LIST_INIT(magicarp_spell_types, list(
	/obj/projectile/magic/animate = "dancing",
	/obj/projectile/magic/arcane_barrage = "arcane",
	/obj/projectile/magic/change = "transforming",
	/obj/projectile/magic/death = "grim",
	/obj/projectile/magic/door = "unbarred",
	/obj/projectile/magic/fireball = "blazing",
	/obj/projectile/magic/resurrection = "vital",
	/obj/projectile/magic/spellblade = "vorpal",
	/obj/projectile/magic/teleport = "warping",
	/obj/projectile/magic/babel = "babbling",
))

/// A reduced list of spells for magicarp spawned in xenobiology, less disruptive
GLOBAL_LIST_INIT(xenobiology_magicarp_spell_types, list(
	/obj/projectile/magic/animate = "dancing",
	/obj/projectile/magic/teleport = "warping",
	/obj/projectile/magic/door = "unbarred",
	/obj/projectile/magic/fireball = "blazing",
	/obj/projectile/magic/spellblade = "vorpal",
	/obj/projectile/magic/arcane_barrage = "arcane",
))

/// Associative list of magicarp spells to colours, expand this list if you expand the other lists
GLOBAL_LIST_INIT(magicarp_spell_colours, list(
	/obj/projectile/magic/animate = COLOR_CARP_RUSTY,
	/obj/projectile/magic/arcane_barrage = COLOR_CARP_PURPLE,
	/obj/projectile/magic/change = COLOR_CARP_PINK,
	/obj/projectile/magic/death = COLOR_CARP_DARK_BLUE,
	/obj/projectile/magic/door = COLOR_CARP_GREEN,
	/obj/projectile/magic/fireball = COLOR_CARP_RED,
	/obj/projectile/magic/resurrection = COLOR_CARP_PALE_GREEN,
	/obj/projectile/magic/spellblade = COLOR_CARP_SILVER,
	/obj/projectile/magic/teleport = COLOR_CARP_GRAPE,
	/obj/projectile/magic/babel = COLOR_CARP_BROWN,
))

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
