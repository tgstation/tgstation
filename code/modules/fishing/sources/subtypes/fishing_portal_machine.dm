//This file contains sources that accessed or unlocked for the fishing portal generator

/datum/fish_source/portal
	fish_table = list(
		FISHING_DUD = 7,
		/obj/item/fish/goldfish = 10,
		/obj/item/fish/guppy = 10,
		/obj/item/fish/angelfish = 10,
		/obj/item/fish/perch = 5,
		/obj/item/fish/goldfish/three_eyes = 3,
		/obj/item/fish/plasmatetra = 3,
	)
	catalog_description = "Aquarium dimension (Fishing portal generator)"
	radial_state = "fish_tank"
	associated_safe_turfs = list(/turf/open/water)
	safe_turfs_blacklist = list(/turf/open/water/hot_spring, /turf/open/water/beach)
	///The name of this option shown in the radial menu on the fishing portal generator
	var/radial_name = "Aquarium"

/datum/fish_source/portal/beach
	fish_table = list(
		FISHING_DUD = 7,
		/obj/effect/spawner/message_in_a_bottle = 3,
		/obj/item/fish/clownfish = 10,
		/obj/item/fish/pufferfish = 10,
		/obj/item/fish/cardinal = 10,
		/obj/item/fish/greenchromis = 10,
		/obj/item/fish/squid = 8,
		/obj/item/fish/plaice = 8,
		/obj/item/survivalcapsule/fishing = 1,
	)
	fish_counts = list(
		/obj/item/survivalcapsule/fishing = 1,
	)
	catalog_description = "Beach dimension (Fishing portal generator)"
	radial_name = "Beach"
	radial_state = "palm_beach"
	overlay_state = "portal_beach"
	associated_safe_turfs = list(/turf/open/water/beach)

/datum/fish_source/portal/beach/on_fishing_spot_init(datum/component/fishing_spot/spot)
	ADD_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/beach/on_fishing_spot_del(datum/component/fishing_spot/spot)
	REMOVE_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/chasm
	background = "background_chasm"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab = 10,
		/obj/item/fish/boned = 5,
		/obj/item/stack/sheet/bone = 5,
	)
	catalog_description = "Chasm dimension (Fishing portal generator)"
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	radial_name = "Chasm"
	overlay_state = "portal_chasm"
	radial_state = "ground_hole"

/datum/fish_source/portal/ocean
	fish_table = list(
		FISHING_DUD = 3,
		/obj/effect/spawner/message_in_a_bottle = 2,
		/obj/item/fish/lanternfish = 5,
		/obj/item/fish/firefish = 5,
		/obj/item/fish/gunner_jellyfish = 5,
		/obj/item/fish/moonfish/dwarf = 4,
		/obj/item/fish/needlefish = 5,
		/obj/item/fish/armorfish = 5,
		/obj/item/fish/zipzap = 5,
		/obj/item/fish/stingray = 4,
		/obj/item/fish/monkfish = 4,
		/obj/item/fish/swordfish = 3,
		/obj/item/fish/moonfish = 1,
	)
	fish_counts = list(
		/obj/item/fish/swordfish = 2,
	)
	fish_count_regen = list(
		/obj/item/fish/swordfish = 5 MINUTES,
	)
	catalog_description = "Ocean dimension (Fishing portal generator)"
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	radial_name = "Ocean"
	overlay_state = "portal_ocean"
	radial_state = "seaboat"
	associated_safe_turfs = list(/turf/open/water/beach)

/datum/fish_source/portal/ocean/on_fishing_spot_init(datum/component/fishing_spot/spot)
	ADD_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/ocean/on_fishing_spot_del(datum/component/fishing_spot/spot)
	REMOVE_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/hyperspace
	background = "background_space"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/starfish = 6,
		/obj/item/fish/baby_carp = 6,
		/obj/item/stack/ore/bluespace_crystal = 2,
		/mob/living/basic/carp = 2,
	)
	fish_counts = list(
		/obj/item/stack/ore/bluespace_crystal = 10,
	)
	catalog_description = "Hyperspace dimension (Fishing portal generator)"
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	radial_name = "Hyperspace"
	overlay_state = "portal_hyperspace"
	radial_state = "space_rocket"
	associated_safe_turfs = list(/turf/open/space)

///Unlocked by emagging the fishing portal generator with an emag.
/datum/fish_source/portal/syndicate
	background = "background_lavaland"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/donkfish = 5,
		/obj/item/fish/emulsijack = 5,
		/obj/item/fish/jumpercable = 5,
		/obj/item/fish/chainsawfish = 2,
		/obj/item/fish/pike/armored = 2,
	)
	fish_counts = list(
		/obj/item/fish/chainsawfish = 1,
		/obj/item/fish/pike/armored = 1,
	)
	fish_count_regen = list(
		/obj/item/fish/chainsawfish = 7 MINUTES,
		/obj/item/fish/pike/armored = 7 MINUTES,
	)
	catalog_description = "Syndicate dimension (Fishing portal generator)"
	radial_name = "Syndicate"
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 25
	overlay_state = "portal_syndicate"
	radial_state = "syndi_snake"
	associated_safe_turfs = list(/turf/open/water)
	safe_turfs_blacklist = list(/turf/open/water/hot_spring, /turf/open/water/beach)

/**
 * A special portal fish source which fish table is populated on init with the contents of all
 * portal fish sources, except for FISHING_DUD, and a couple more caveats.
 */
/datum/fish_source/portal/random
	fish_table = null //It's populated the first time the source is loaded on a fishing portal generator.
	catalog_description = null // it'd make a bad entry in the catalog.
	radial_name = "Randomizer"
	overlay_state = "portal_randomizer"
	radial_state = "misaligned_question_mark"
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD
	var/static/list/all_portal_fish_sources_at_once

///Generate the fish table if we don't have one already.
/datum/fish_source/portal/random/on_fishing_spot_init(datum/component/fishing_spot/spot)
	if(fish_table)
		return

	///rewards not found in other fishing portals
	fish_table = list(
		/obj/item/fish/holo/checkered = 1,
	)

	for(var/portal_type in GLOB.preset_fish_sources)
		if(portal_type == type || !ispath(portal_type, /datum/fish_source/portal))
			continue
		var/datum/fish_source/portal/preset_portal = GLOB.preset_fish_sources[portal_type]
		fish_table |= preset_portal.fish_table

	///We don't serve duds.
	fish_table -= FISHING_DUD

	for(var/reward_path in fish_table)
		fish_table[reward_path] = rand(1, 4)

///Difficulty has to be calculated before the rest, because of how it influences jump chances
/datum/fish_source/portal/random/calculate_difficulty(datum/fishing_challenge/challenge, result, obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	. += rand(-10, 15)

///In the spirit of randomness, we skew a few values here and there
/datum/fish_source/portal/random/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
	challenge.bait_bounce_mult = max(challenge.bait_bounce_mult + rand(-3, 3) * 0.1, 0.1)
	challenge.completion_loss = max(challenge.completion_loss + rand(-2, 2), 0)
	challenge.completion_gain = max(challenge.completion_gain + rand(-1, 1), 2)
	challenge.mover.short_jump_velocity_limit += rand(-100, 100)
	challenge.mover.long_jump_velocity_limit += rand(-100, 100)
	var/static/list/active_effects = bitfield_to_list(FISHING_MINIGAME_ACTIVE_EFFECTS)
	for(var/effect in active_effects)
		if(prob(30))
			challenge.special_effects |= effect
	RegisterSignal(challenge, COMSIG_FISHING_CHALLENGE_MOVER_INITIALIZED, PROC_REF(randomize_mover_velocity))

/datum/fish_source/portal/random/proc/randomize_mover_velocity(datum/source, datum/fish_movement/mover)
	SIGNAL_HANDLER
	mover.short_jump_velocity_limit += rand(-100, 100)
	mover.long_jump_velocity_limit += rand(-100, 100)

///Cherry on top, fish caught from the randomizer portal also have (almost completely) random traits
/datum/fish_source/portal/random/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot, obj/item/fishing_rod/used_rod)
	if(!ispath(reward_path, /obj/item/fish))
		return ..()

	var/static/list/weighted_traits
	if(!weighted_traits)
		weighted_traits = list()
		for(var/trait_type in GLOB.fish_traits)
			var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
			weighted_traits[trait.type] = round(trait.inheritability**2/100)

	var/obj/item/fish/caught_fish = new reward_path(spawn_location, FALSE)
	var/list/new_traits = list()
	for(var/iteration in 1 to rand(1, 4))
		new_traits |= pick_weight(weighted_traits)
	caught_fish.inherit_traits(new_traits)
	caught_fish.randomize_size_and_weight(deviation = 0.3)
	return caught_fish
