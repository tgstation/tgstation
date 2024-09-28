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
	health = 25
	maxHealth = 25
	pressure_resistance = 200
	combat_mode = TRUE
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_attack_cooldown = 1.5 SECONDS
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	faction = list(FACTION_CARP)
	butcher_results = list(/obj/item/food/fishmeat/carp = 2, /obj/item/stack/sheet/animalhide/carp = 1)
	greyscale_config = /datum/greyscale_config/carp
	ai_controller = /datum/ai_controller/basic_controller/carp
	habitable_atmos = null
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500

	/// If true we will run away from attackers even at full health
	var/cowardly = FALSE
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
		/datum/pet_command/point_targeting/attack
	)
	/// Carp want to eat raw meat
	var/static/list/desired_food = list(/obj/item/food/meat/slab, /obj/item/food/meat/rawcutlet)
	/// Carp want to eat delicious six pack plastic rings
	var/static/list/desired_trash = list(/obj/item/storage/cans)
	/// Structures that AI carp are willing to attack. This prevents them from deconstructing supermatter cooling equipment.
	var/static/list/allowed_obstacle_targets = typecacheof(list(
		/obj/structure/closet,
		/obj/machinery/door,
		/obj/structure/door_assembly,
		/obj/structure/filingcabinet,
		/obj/structure/frame,
		/obj/structure/grille,
		/obj/structure/plasticflaps,
		/obj/structure/rack,
		/obj/structure/reagent_dispensers, // Carp can have a little welding fuel, as a treat
		/obj/structure/table,
		/obj/machinery/vending,
		/obj/structure/window,
	))

/mob/living/basic/carp/Initialize(mapload, mob/tamer)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT) //Need to set before init cause if we init in hyperspace we get dragged before the trait can be added
	. = ..()
	apply_colour()
	add_traits(list(TRAIT_HEALS_FROM_CARP_RIFTS, TRAIT_SPACEWALK), INNATE_TRAIT)

	if (cell_line)
		AddElement(/datum/element/swabable, cell_line, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/simple_flying)
	if (!cowardly)
		AddElement(/datum/element/ai_flee_while_injured)
	setup_eating()

	AddComponent(/datum/component/aggro_emote, emote_list = string_list(list("gnashes")))
	AddComponent(/datum/component/regenerator, outline_colour = regenerate_colour)
	AddComponent(/datum/component/profound_fisher)
	if (tamer)
		tamed(tamer, feedback = FALSE)
		befriend(tamer)
	else
		AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat), tame_chance = 10, bonus_tame_chance = 5)

	teleport = new(src)
	teleport.Grant(src)
	ai_controller.set_blackboard_key(BB_CARP_RIFT, teleport)
	ai_controller.set_blackboard_key(BB_OBSTACLE_TARGETING_WHITELIST, allowed_obstacle_targets)

/// Tell the elements and the blackboard what food we want to eat
/mob/living/basic/carp/proc/setup_eating()
	AddElement(/datum/element/basic_eating, food_types = desired_food)
	AddElement(/datum/element/basic_eating, heal_amt = 0, damage_amount = 10, damage_type = BRUTE, food_types = desired_trash) // We are killing our planet
	var/list/foods_list = desired_food + desired_trash
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(foods_list))

/// Set a random colour on the carp, override to do something else
/mob/living/basic/carp/proc/apply_colour()
	if (!greyscale_config)
		return
	set_greyscale(colors = list(pick_weight(GLOB.carp_colors)))

/// Called when another mob has forged a bond of friendship with this one, passed the taming mob as 'tamer'
/mob/living/basic/carp/tamed(mob/living/tamer, atom/food, feedback = TRUE)
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

/// Gives the carp a list of weakrefs of destinations to try and travel between when it has nothing better to do
/mob/living/basic/carp/proc/migrate_to(list/datum/weakref/migration_points)
	ai_controller.can_idle = FALSE
	ai_controller.set_ai_status(AI_STATUS_ON) // We need htem to actually walk to the station
	var/list/actual_points = list()
	for(var/datum/weakref/point_ref as anything in migration_points)
		var/turf/point_resolved = point_ref.resolve()
		if(QDELETED(point_resolved))
			return // invalid list, we can't migrate to this
		actual_points += point_resolved

	ai_controller.set_blackboard_key(BB_CARP_MIGRATION_PATH, actual_points)

/mob/living/basic/carp/death(gibbed)
	. = ..()

	REMOVE_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)

/mob/living/basic/carp/revive(full_heal_flags, excess_healing, force_grab_ghost)
	. = ..()

	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)

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
	faction = list(FACTION_NEUTRAL)
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

/mob/living/basic/carp/advanced
	health = 40
	maxHealth = 40
	obj_damage = 15

#undef RARE_CAYENNE_CHANCE

///Carp-parasite from carpellosis disease
/mob/living/basic/carp/ella
	name = "Ella"
	real_name = "Ella"
	desc = "It came out of someone."
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/carp/ella/Initialize(mapload)
	. = ..()
	death() // It comes into the world dead when the disease is cured

///Wild carp that just vibe ya know
/mob/living/basic/carp/passive
	name = "false carp"
	desc = "A close relative of the space carp which is entirely toothless and feeds by stealing its cousin's leftovers."

	icon_state = "base_friend"
	icon_living = "base_friend"
	icon_dead = "base_friend_dead"
	greyscale_config = /datum/greyscale_config/carp_friend

	attack_verb_continuous = "suckers"
	attack_verb_simple = "suck"

	melee_damage_lower = 0
	melee_damage_upper = 0
	cowardly = TRUE
	ai_controller = /datum/ai_controller/basic_controller/carp/passive
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/basic/carp/passive/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(on_attacked)))
	AddElement(/datum/element/pet_bonus, "bloops happily!")
	ADD_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)

/// If someone slaps one of the school, scatter
/mob/living/basic/carp/passive/proc/on_attacked(mob/living/attacker)
	for(var/mob/living/basic/carp/passive/schoolmate in oview(src, 9))
		schoolmate.ai_controller?.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)
