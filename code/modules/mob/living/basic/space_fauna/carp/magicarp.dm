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

/**
 * # Magicarp
 *
 * Carp who can cast spells!
 * Mostly created via wizard event or transformation.
 * Come in 'does one thing' and 'does random things' varieties.
 */
/mob/living/basic/carp/magic
	name = "magicarp"
	desc = "50% magic, 50% carp, 100% horrible."
	icon_gib = "magicarp_gib"
	maxHealth = 50
	health = 50
	gold_core_spawnable = NO_SPAWN
	greyscale_config = /datum/greyscale_config/carp_magic
	ai_controller = /datum/ai_controller/basic_controller/carp/ranged
	tamed_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/attack/carp,
		/datum/pet_command/point_targetting/use_ability/magicarp,
	)
	/// List of all projectiles we can fire.
	/// Non-static, because subtypes can have their own lists.
	var/list/allowed_projectile_types
	/// Our magic attack
	var/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/spell

/mob/living/basic/carp/magic/Initialize(mapload)
	. = ..()
	allowed_projectile_types = spell_list()
	assign_spell()

/mob/living/basic/carp/magic/Destroy()
	QDEL_NULL(spell)
	return ..()

/// Returns the list of spells we are allowed to cast
/mob/living/basic/carp/magic/proc/spell_list()
	return GLOB.magicarp_spell_types

/// Updates name based on chosen spell
/mob/living/basic/carp/magic/proc/assign_spell()
	var/obj/projectile/spell_type = pick(allowed_projectile_types)
	name = "[GLOB.magicarp_spell_types[spell_type]] [name]"
	set_greyscale(colors = list(GLOB.magicarp_spell_colours[spell_type]))

	spell = new (src)
	spell.projectile_type = spell_type
	spell.button_icon_state = initial(spell_type.icon_state)
	spell.Grant(src)
	ai_controller.blackboard[BB_MAGICARP_SPELL] = WEAKREF(spell)
	assign_spell_ai(spell_type)

/// If you have certain spells, use a different targetting datum
/mob/living/basic/carp/magic/proc/assign_spell_ai(spell_type)
	var/static/list/spell_special_targetting = list(
		/obj/projectile/magic/animate = MAGICARP_SPELL_OBJECTS,
		/obj/projectile/magic/door = MAGICARP_SPELL_WALLS,
		/obj/projectile/magic/resurrection = MAGICARP_SPELL_CORPSES,
	)

	ai_controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETTING] = spell_special_targetting[spell_type]

/// Shoot when you click away from you
/mob/living/basic/carp/magic/RangedAttack(atom/atom_target, modifiers)
	spell.Trigger(target = atom_target)

/***
 * # Chaos Magicarp
 *
 * Fires a random spell (and changes colour) every time, also beefier.
 * Sometimes actually more durable than the much larger megacarp. That's magic for you.
 * They trade off for this with a tendency to fireball themselves.
 */
/mob/living/basic/carp/magic/chaos
	name = "chaos magicarp"
	desc = "50% carp, 100% magic, 150% horrible."
	maxHealth = 75
	health = 75

/mob/living/basic/carp/magic/chaos/assign_spell()
	var/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/chaos_bolt = new(src)
	chaos_bolt.permitted_projectiles = allowed_projectile_types
	chaos_bolt.Grant(src)
	spell = chaos_bolt
	ai_controller.blackboard[BB_MAGICARP_SPELL] = spell
	RegisterSignal(spell, COMSIG_ACTION_TRIGGER, PROC_REF(apply_colour))

/// Has a more limited spell pool but can appear from gold slime cores
/mob/living/basic/carp/magic/xenobiology
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/basic/carp/magic/xenobiology/spell_list()
	return GLOB.xenobiology_magicarp_spell_types

/mob/living/basic/carp/magic/chaos/xenobiology
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/basic/carp/magic/chaos/xenobiology/spell_list()
	return GLOB.xenobiology_magicarp_spell_types
