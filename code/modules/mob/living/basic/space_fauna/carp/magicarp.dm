/// List of spells that a carp can cast
#define MAGICARP_SPELL_LIST list(\
	/obj/projectile/magic/animate = "dancing",\
	/obj/projectile/magic/arcane_barrage = "arcane",\
	/obj/projectile/magic/change = "transforming",\
	/obj/projectile/magic/death = "grim",\
	/obj/projectile/magic/door = "unbarred",\
	/obj/projectile/magic/fireball = "blazing",\
	/obj/projectile/magic/resurrection = "vital",\
	/obj/projectile/magic/spellblade = "vorpal",\
	/obj/projectile/magic/teleport = "warping",\
	/obj/projectile/magic/babel = "babbling",\
)

/// Filtered list of spells that a carp can cast if spawned from a xenobiology slime
#define XENOBIOLOGY_MAGICARP_SPELL_LIST list(\
	/obj/projectile/magic/animate = "dancing",\
	/obj/projectile/magic/teleport = "warping",\
	/obj/projectile/magic/door = "unbarred",\
	/obj/projectile/magic/fireball = "blazing",\
	/obj/projectile/magic/spellblade = "vorpal",\
	/obj/projectile/magic/arcane_barrage = "arcane",\
)

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
	/// Types of projectiles fish are allowed to throw, not static so that subtypes can modify this
	/// Each spell corresponds to a name so we can update the fish name and colour
	var/list/projectile_types = MAGICARP_SPELL_LIST
	/// Our magic attack
	var/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/spell

/mob/living/basic/carp/magic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pet_command/point_targetting/use_ability, pointed_reaction = "starts glowing intensely")
	assign_spell()

/// Updates name based on chosen spell
/mob/living/basic/carp/magic/proc/assign_spell()
	var/obj/projectile/spell_type = pick(projectile_types)
	name = "[projectile_types[spell_type]] [name]"

	colour_by_spell(spell_type)
	assign_spell_ai(spell_type)

	spell = new (src)
	spell.projectile_type = spell_type
	spell.button_icon_state = initial(spell_type.icon_state)
	spell.Grant(src)
	ai_controller.blackboard[BB_MAGICARP_SPELL] = spell

/// Convert name of spell to colour
/mob/living/basic/carp/magic/proc/colour_by_spell(spell_type)
	var/static/list/spell_colours = list(
		/obj/projectile/magic/animate = "#fd6767",
		/obj/projectile/magic/arcane_barrage = "#aba2ff",
		/obj/projectile/magic/change = "#da77a8",
		/obj/projectile/magic/death = "#3a384d",
		/obj/projectile/magic/door = "#70ff25",
		/obj/projectile/magic/fireball = "#dd5f34",
		/obj/projectile/magic/resurrection = "#7ef099",
		/obj/projectile/magic/spellblade = "#fdfbf3",
		/obj/projectile/magic/teleport = "#df0afb",
		/obj/projectile/magic/babel = "#ca805a",
	)

	var/spell_colour = spell_colours[spell_type]
	set_greyscale(colors= list(spell_colour))

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
	chaos_bolt.permitted_projectiles = projectile_types
	chaos_bolt.Grant(src)
	spell = chaos_bolt
	ai_controller.blackboard[BB_MAGICARP_SPELL] = spell
	RegisterSignal(spell, COMSIG_ACTION_TRIGGER, PROC_REF(apply_colour))

/// Has a more limited spell pool but can appear from gold slime cores
/mob/living/basic/carp/magic/xenobiology
	gold_core_spawnable = HOSTILE_SPAWN
	projectile_types = XENOBIOLOGY_MAGICARP_SPELL_LIST

/mob/living/basic/carp/magic/chaos/xenobiology
	gold_core_spawnable = HOSTILE_SPAWN
	projectile_types = XENOBIOLOGY_MAGICARP_SPELL_LIST

#undef MAGICARP_SPELL_LIST
#undef XENOBIOLOGY_MAGICARP_SPELL_LIST
