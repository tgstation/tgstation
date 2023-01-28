/**
 * ## Space Carp
 *
 * A migratory dwarf fortress reference who swim through space and sometimes bump into the space station.
 * Can be created in dehydrated form by traitors, and are also summoned through rifts by space dragons.
 *
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
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500

	/// Cytology cells you can swab from this creature
	var/cell_line = CELL_LINE_TABLE_CARP
	/// What colour is our 'healing' outline?
	var/regenerate_colour = COLOR_PALE_GREEN
	/// Ability which lets carp teleport around
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/teleport
	/// Information to apply when treating this carp as a vehicle
	var/ridable_data = /datum/component/riding/creature/carp
	/// Commands you can give this carp once it is tamed, not static because subtypes can modify it
	var/tamed_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targetting/attack/carp
	)
	/// Carp want to eat raw meat
	var/static/list/desired_food = list(/obj/item/food/meat/slab, /obj/item/food/meat/rawcutlet)
	/// Carp want to eat delicious six pack plastic rings
	var/static/list/desired_trash = list(/obj/item/storage/cans)
	/// Weighted list of colours a carp can be
	/// Weighted list of usual carp colors
	var/static/list/carp_colors = list(
		COLOR_CARP_PURPLE = 7,
		COLOR_CARP_PINK = 7,
		COLOR_CARP_GREEN = 7,
		COLOR_CARP_GRAPE = 7,
		COLOR_CARP_SWAMP = 7,
		COLOR_CARP_TURQUOISE = 7,
		COLOR_CARP_BROWN = 7,
		COLOR_CARP_TEAL = 7,
		COLOR_CARP_LIGHT_BLUE = 7,
		COLOR_CARP_RUSTY = 7,
		COLOR_CARP_RED = 7,
		COLOR_CARP_YELLOW = 7,
		COLOR_CARP_BLUE = 7,
		COLOR_CARP_PALE_GREEN = 7,
		COLOR_CARP_SILVER = 1, // The rare silver carp
	)

/mob/living/basic/carp/Initialize(mapload, mob/tamer)
	. = ..()
	apply_colour()
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CARP_RIFTS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)

	if (cell_line)
		AddElement(/datum/element/swabable, cell_line, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_flee_while_injured)
	setup_eating()

	AddComponent(/datum/component/regenerator, outline_colour = regenerate_colour)
	if (tamer)
		befriend(tamer)
		on_tamed(tamer, FALSE)
	else
		AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat), tame_chance = 10, bonus_tame_chance = 5, after_tame = CALLBACK(src, PROC_REF(on_tamed)))

	teleport = new(src)
	teleport.Grant(src)
	ai_controller.blackboard[BB_CARP_RIFT] = teleport

/mob/living/basic/carp/Destroy()
	QDEL_NULL(teleport)
	return ..()

/// Tell the elements and the blackboard what food we want to eat
/mob/living/basic/carp/proc/setup_eating()
	AddElement(/datum/element/basic_eating, 10, 0, null, desired_food)
	AddElement(/datum/element/basic_eating, 0, 10, BRUTE, desired_trash) // We are killing our planet
	ai_controller.blackboard[BB_BASIC_FOODS] = desired_food + desired_trash

/// Set a random colour on the carp, override to do something else
/mob/living/basic/carp/proc/apply_colour()
	if (!greyscale_config)
		return
	set_greyscale(colors = list(pick_weight(carp_colors)))

/// Called when another mob has forged a bond of friendship with this one, passed the taming mob as 'tamer'
/mob/living/basic/carp/proc/on_tamed(mob/tamer, feedback = TRUE)
	buckle_lying = 0
	AddElement(/datum/element/ridable, ridable_data)
	AddComponent(/datum/component/obeys_commands, tamed_commands)
	if (!feedback)
		return
	spin(spintime = 10, speed = 1)
	visible_message("[src] spins in a circle as it seems to bond with [tamer].")

/// Teleport when you right click away from you
/mob/living/basic/carp/ranged_secondary_attack(atom/atom_target, modifiers)
	teleport.Trigger(target = atom_target)

/// Gives the carp a list of destinations to try and travel between when it has nothing better to do
/mob/living/basic/carp/proc/migrate_to(list/migration_points)
	ai_controller.blackboard[BB_CARP_MIGRATION_PATH] = migration_points

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

/// Holocarp don't eat food
/mob/living/basic/carp/holographic/setup_eating()
	return FALSE

/**
 * Pet carp, abstract carp which just holds some shared properties.
 */
/mob/living/basic/carp/pet
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	gender = FEMALE // Both current existing pet carp are female but you can remove this if someone else gets a male one?
	ai_controller = /datum/ai_controller/basic_controller/carp/pet

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

/// Boosted chance for Cayenne to be silver
#define RARE_CAYENNE_CHANCE 10

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
	/// Overlay to apply to display the disk
	var/mutable_appearance/disk_overlay
	/// Overlay to apply over the disk so it looks like cayenne is holding it
	var/mutable_appearance/mouth_overlay

/mob/living/basic/carp/pet/cayenne/Initialize(mapload)
	. = ..()
	var/datum/callback/got_disk = CALLBACK(src, PROC_REF(got_disk))
	var/datum/callback/display_disk = CALLBACK(src, PROC_REF(display_disk))
	AddComponent(/datum/component/nuclear_bomb_operator, got_disk, display_disk)

/mob/living/basic/carp/pet/cayenne/apply_colour()
	if (prob(RARE_CAYENNE_CHANCE))
		set_greyscale(colors = list(COLOR_CARP_SILVER))
	else
		return ..()

/// She did it! Treats for Cayenne!
/mob/living/basic/carp/pet/cayenne/proc/got_disk(obj/item/disk/nuclear/disky)
	if (disky.fake) // Never mind she didn't do it
		return
	client.give_award(/datum/award/achievement/misc/cayenne_disk, src)

/// Adds an overlay to show the disk on Cayenne
/mob/living/basic/carp/pet/cayenne/proc/display_disk(list/new_overlays)
	if (!mouth_overlay)
		mouth_overlay = mutable_appearance(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/carp/disk_mouth, greyscale_colors), "disk_mouth")
	new_overlays += mouth_overlay

	if (!disk_overlay)
		disk_overlay = mutable_appearance('icons/mob/simple/carp.dmi', "disk_overlay")
	new_overlays += disk_overlay

#undef RARE_CAYENNE_CHANCE
