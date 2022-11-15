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
	/// Type of spell this fish can cast
	var/spell_type
	/// Types of projectiles fish are allowed to throw, not static so that subtypes can modify this
	/// Each spell corresponds to a name so we can update the fish name and colour
	var/list/projectile_types = list(
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
	)

/mob/living/basic/carp/magic/Initialize(mapload)
	spell_type = pick(projectile_types)
	name = "[projectile_types[spell_type]] [name]"
	return ..()

/// Colour based on spell selection
/mob/living/basic/carp/magic/apply_colour()
	var/spell_colour = spell_to_colour(projectile_types[spell_type])
	set_greyscale(colors= list(spell_colour))
	update_appearance()

/// Convert name of spell to colour
/mob/living/basic/carp/magic/proc/spell_to_colour(spell_name)
	var/static/list/spell_colours = list(
		"dancing" = "#fd6767",
		"arcane" = "#aba2ff",
		"transforming" = "#da77a8",
		"grim" = "#3a384d",
		"unbarred" = "#70ff25",
		"blazing" = "#dd5f34",
		"vital" = "#7ef099",
		"vorpal" = "#fdfbf3",
		"warping" = "#df0afb",
		"babbling" = "#ca805a",
	)
	return spell_colours[spell_name]
