/**
 * ## Space Carp
 *
 * A migratory dwarf fortress reference who swim through space and sometimes bump into the space station.
 * Can be created in dehydrated form by traitors, and are also summoned through rifts by space dragons.
 *
 * Have a limited ability to open teleportation rifts themselves, helping them migrate through the space station without spacing it.
 * Begin regenerating their health after a short time without taking any damage, and will try to run away to do this if they get hurt.
 * Lethally attracted to loose plastic.
 *
 * Tameable by feeding them meat, and can follow basic instructions. Rideable.
 * Owned as a pet both by the HoS (sometimes) and also the Nuclear Operatives.
 */
/mob/living/basic/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/simple/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	gold_core_spawnable = HOSTILE_SPAWN
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	movement_type = FLYING
	health = 25
	maxHealth = 25
	pressure_resistance = 200
	combat_mode = TRUE
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	faction = list("carp")
	butcher_results = list(/obj/item/food/fishmeat/carp = 2, /obj/item/stack/sheet/animalhide/carp = 1)
	greyscale_config = /datum/greyscale_config/carp
	ai_controller = /datum/ai_controller/basic_controller/carp

	/// Cytology cells you can swab from this creature
	var/cell_line = CELL_LINE_TABLE_CARP
	/// Is the carp tamed?
	var/tamed = FALSE
	/// What colour is our 'healing' outline?
	var/regenerate_colour = "#20e28e"
	/// Weighted list of colours a carp can be
	var/static/list/carp_colors = list(
		"#aba2ff" = 7,
		"#da77a8" = 7,
		"#70ff25" = 7,
		"#df0afb" = 7,
		"#e5e75a" = 7,
		"#04e1ed" = 7,
		"#ca805a" = 7,
		"#20e28e" = 7,
		"#4d88cc" = 7,
		"#dd5f34" = 7,
		"#fd6767" = 7,
		"#f3ca4a" = 7,
		"#09bae1" = 7,
		"#7ef099" = 7,
		"#fdfbf3" = 1, // The rare silver carp
	)

/mob/living/basic/carp/Initialize(mapload, mob/tamer)
	. = ..()
	apply_colour()
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

	if (cell_line)
		AddElement(/datum/element/swabable, cell_line, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/simple_flying)

	if (tamer)
		on_tamed(tamer)
	else
		AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat), tame_chance = 10, bonus_tame_chance = 5, after_tame = CALLBACK(src, .proc/on_tamed))
	AddComponent(/datum/component/regenerator, outline_colour = regenerate_colour)

/// Set a random colour on the carp, override to do something else
/mob/living/basic/carp/proc/apply_colour()
	if (!greyscale_config)
		return
	set_greyscale(colors= list(pick_weight(carp_colors)))

/// Called when another mob has forged a bond of friendship with this one, passed the taming mob as 'tamer'
/mob/living/basic/carp/proc/on_tamed(mob/tamer)
	tamed = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/carp)
	spin(20, 1)
	visible_message("[src] spins in a circle as it seems to bond with [tamer].")

/**
 * Holographic carp from the holodeck
 */
/mob/living/basic/carp/holographic
	icon_state = "holocarp"
	icon_living = "holocarp"
	gold_core_spawnable = NO_SPAWN
	greyscale_config = NONE
	basic_mob_flags = DEL_ON_DEATH
	cell_line = NONE
	regenerate_colour = "#ffffff"

/**
 * Pet carp, abstract carp which just holds some shared properties.
 */
/mob/living/basic/carp/pet
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	gender = FEMALE // Both current existing pet carp are female but you can remove this if someone else gets a male one?
	ai_controller = /datum/ai_controller/basic_controller/carp/retaliate

/mob/living/basic/carp/pet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "bloops happily!")

/**
 * Lia - Sometimes the pet of the Head of Security.
 * Has a lot more health than a normal carp because she's meant to be a mildly more threatening pet to have to assassinate than an aging corgi.
 */
/mob/living/basic/carp/pet/lia
	name = "Lia"
	real_name = "Lia"
	desc = "A failed experiment of Nanotrasen to create weaponised carp technology. This less than intimidating carp now serves as the Head of Security's pet."
	faction = list("neutral")
	maxHealth = 200
	health = 200
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	icon_living = "magicarp"
	icon_state = "magicarp"
	greyscale_config = NONE

/**
 * Cayenne - Loyal member of the nuclear operatives.
 * Spawns in the nuke op shuttle, can be made sapient if they want to do that for some reason.
 * Is very talented and also capable of holding the nuclear disk.
 */
/mob/living/basic/carp/pet/cayenne
	name = "Cayenne"
	real_name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	faction = list(ROLE_SYNDICATE)

/mob/living/basic/carp/pet/cayenne/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/nuclear_bomb_operator, mutable_appearance(icon, "disk_overlay") , mutable_appearance(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/carp/disk_mouth, greyscale_colors), "disk_mouth"))
	RegisterSignal(src, COMSIG_HANDLESS_MOB_COLLECTED_DISK, .proc/got_disk)

/// She did it! Treats for Cayenne!
/mob/living/basic/carp/pet/cayenne/proc/got_disk(atom/source, obj/item/disk/nuclear/disky)
	if (disky.fake) // Never mind she didn't do it
		return
	client.give_award(/datum/award/achievement/misc/cayenne_disk, src)
