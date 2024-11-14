/datum/fish_source/ocean
	radial_state = "seaboat"
	overlay_state = "portal_ocean"
	fish_table = list(
		FISHING_DUD = 10,
		/obj/effect/spawner/message_in_a_bottle = 4,
		/obj/item/coin/gold = 6,
		/obj/item/fish/clownfish = 11,
		/obj/item/fish/pufferfish = 11,
		/obj/item/fish/cardinal = 11,
		/obj/item/fish/greenchromis = 11,
		/obj/item/fish/squid = 11,
		/obj/item/fish/stingray = 8,
		/obj/item/fish/plaice = 8,
		/obj/item/fish/monkfish = 5,
		/obj/item/fish/lanternfish = 7,
		/obj/item/fish/zipzap = 7,
		/obj/item/fish/clownfish/lube = 5,
		/obj/item/fish/swordfish = 5,
		/obj/structure/mystery_box/fishing = 2,
	)
	fish_counts = list(
		/obj/item/fish/clownfish/lube = 2,
		/obj/item/fish/swordfish = 2,
		/obj/structure/mystery_box/fishing = 1,
	)
	fish_count_regen = list(
		/obj/item/fish/clownfish/lube = 3 MINUTES,
		/obj/item/fish/swordfish = 5 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/ocean/beach
	catalog_description = "Beach shore water"
	radial_state = "palm_beach"
	overlay_state = "portal_beach"

/datum/fish_source/ice_fishing
	catalog_description = "Ice-covered water"
	radial_state = "ice"
	overlay_state = "portal_ocean"
	fish_table = list(
		FISHING_DUD = 4,
		/obj/item/fish/arctic_char = 5,
		/obj/item/fish/sockeye_salmon = 5,
		/obj/item/fish/chasm_crab/ice = 2,
		/obj/item/fish/boned = 1,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20

/datum/fish_source/river
	catalog_description = "River water"
	radial_state = "river"
	overlay_state = "portal_river"
	fish_table = list(
		FISHING_DUD = 4,
		/obj/item/fish/goldfish = 5,
		/obj/item/fish/guppy = 5,
		/obj/item/fish/perch = 4,
		/obj/item/fish/angelfish = 4,
		/obj/item/fish/catfish = 4,
		/obj/item/fish/perch = 5,
		/obj/item/fish/slimefish = 2,
		/obj/item/fish/sockeye_salmon = 1,
		/obj/item/fish/arctic_char = 1,
		/obj/item/fish/pike = 1,
		/obj/item/fish/goldfish/three_eyes = 1,
	)
	fish_counts = list(
		/obj/item/fish/pike = 3,
	)
	fish_count_regen = list(
		/obj/item/fish/pike = 4 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/sand
	catalog_description = "Sand"
	radial_state = "palm_beach"
	fish_table = list(
		FISHING_DUD = 8,
		/obj/item/fish/sand_crab = 10,
		/obj/item/fish/sand_surfer = 10,
		/obj/item/fish/bumpy = 10,
		/obj/item/coin/gold = 3,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/cursed_spring
	catalog_description = null //it's a secret (sorta, I know you're reading this)
	radial_state = "cursed"
	fish_table = list(
		FISHING_DUD = 2,
		/obj/item/fish/soul = 3,
		/obj/item/fish/skin_crab = 3,
		/obj/item/fishing_rod/telescopic/master = 1,
	)
	fish_counts = list(
		/obj/item/fishing_rod/telescopic/master = 1,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 25
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/portal
	fish_table = list(
		FISHING_DUD = 7,
		/obj/item/fish/goldfish = 10,
		/obj/item/fish/guppy = 10,
		/obj/item/fish/angelfish = 10,
		/obj/item/fish/perch = 5,
		/obj/item/fish/goldfish/three_eyes = 3,
	)
	catalog_description = "Aquarium dimension (Fishing portal generator)"
	radial_state = "fish_tank"
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

/datum/fish_source/portal/beach/on_fishing_spot_init(datum/component/fishing_spot/spot)
	ADD_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/beach/on_fishing_spot_del(datum/component/fishing_spot/spot)
	REMOVE_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/chasm
	background = "background_lavaland"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab = 10,
		/obj/item/fish/boned = 5,
		/obj/item/stack/sheet/bone = 5,
	)
	catalog_description = "Chasm dimension (Fishing portal generator)"
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
	radial_name = "Ocean"
	overlay_state = "portal_ocean"
	radial_state = "seaboat"

/datum/fish_source/portal/ocean/on_fishing_spot_init(datum/component/fishing_spot/spot)
	ADD_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/ocean/on_fishing_spot_del(datum/component/fishing_spot/spot)
	REMOVE_TRAIT(spot.parent, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/datum/fish_source/portal/hyperspace
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
	radial_name = "Hyperspace"
	overlay_state = "portal_hyperspace"
	radial_state = "space_rocket"

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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
	overlay_state = "portal_syndicate"
	radial_state = "syndi_snake"

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
/datum/fish_source/portal/random/spawn_reward(reward_path, atom/movable/spawn_location, turf/fishing_spot)
	if(!ispath(reward_path, /obj/item/fish))
		return ..()

	var/static/list/weighted_traits
	if(!weighted_traits)
		weighted_traits = list()
		for(var/trait_type as anything in GLOB.fish_traits)
			var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
			weighted_traits[trait.type] = round(trait.inheritability**2/100)

	var/obj/item/fish/caught_fish = new reward_path(spawn_location, FALSE)
	var/list/new_traits = list()
	for(var/iteration in 1 to rand(1, 4))
		new_traits |= pick_weight(weighted_traits)
	caught_fish.inherit_traits(new_traits)
	caught_fish.randomize_size_and_weight(deviation = 0.3)
	return caught_fish


/datum/fish_source/chasm
	catalog_description = "Chasm depths"
	background = "background_lavaland"
	radial_state = "ground_hole"
	overlay_state = "portal_chasm"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab = 15,
		/datum/chasm_detritus = 30,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5

/datum/fish_source/chasm/on_start_fishing(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	. = ..()
	if(istype(rod.hook, /obj/item/fishing_hook/rescue))
		to_chat(fisherman, span_notice("The rescue hook falls straight down the chasm! Hopefully it catches a corpse."))
		return
	to_chat(fisherman, span_danger("Your fishing hook makes a soft 'thud' noise as it gets stuck on the wall of the chasm. It doesn't look like it's going to catch much of anything, except maybe some detritus."))

/datum/fish_source/chasm/roll_reward(obj/item/fishing_rod/rod, mob/fisherman)
	var/rolled_reward = ..()

	if(!rod.hook || !ispath(rolled_reward, /datum/chasm_detritus))
		return rolled_reward

	return rod.hook.chasm_detritus_type

/datum/fish_source/chasm/spawn_reward_from_explosion(atom/location, severity)
	return //Spawned content would immediately fall back into the chasm, so it wouldn't matter.

/datum/fish_source/lavaland
	catalog_description = "Lava vents"
	background = "background_lavaland"
	radial_state = "lava"
	overlay_state = "portal_lava"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/stack/ore/slag = 20,
		/obj/item/fish/lavaloop = 15,
		/obj/structure/closet/crate/necropolis/tendril = 1,
		/obj/effect/mob_spawn/corpse/human/charredskeleton = 1
	)
	fish_counts = list(
		/obj/structure/closet/crate/necropolis/tendril = 1
	)

	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/lavaland/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	. = ..()
	if(!HAS_TRAIT(rod, TRAIT_ROD_LAVA_USABLE))
		return "You'll need reinforced fishing line to fish in there."

/datum/fish_source/lavaland/icemoon
	catalog_description = "Liquid plasma vents"
	radial_state = "plasma"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab/ice = 30,
		/obj/item/fish/lavaloop/plasma_river = 30,
		/obj/item/coin/plasma = 6,
		/obj/item/stack/ore/plasma = 6,
		/obj/effect/decal/remains/plasma = 2,
		/obj/item/stack/sheet/mineral/runite = 2,
		/obj/item/stack/sheet/mineral/adamantine = 2,
		/mob/living/basic/mining/lobstrosity = 1,
		/mob/living/basic/mining/lobstrosity/juvenile = 1,
	)
	fish_counts = list(
		/obj/item/stack/sheet/mineral/adamantine = 3,
		/obj/item/stack/sheet/mineral/runite = 2,
	)
	overlay_state = "portal_plasma"

/datum/fish_source/moisture_trap
	catalog_description = "Moisture trap basins"
	radial_state = "garbage"
	overlay_state = "portal_river" // placeholder
	fish_table = list(
		FISHING_DUD = 20,
		/obj/item/fish/ratfish = 10,
		/obj/item/fish/slimefish = 4,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10

/datum/fish_source/toilet
	catalog_description = "Station toilets"
	radial_state = "toilet"
	duds = list("ewww... nothing", "it was nothing", "it was toilet paper", "it was flushed away", "the hook is empty", "where's the damn money?!")
	overlay_state = "portal_river" // placeholder
	fish_table = list(
		FISHING_DUD = 18,
		/obj/item/fish/sludgefish = 18,
		/obj/item/fish/slimefish = 4,
		/obj/item/storage/wallet/money = 2,
		/obj/item/survivalcapsule/fishing = 1,
	)
	fish_counts = list(
		/obj/item/storage/wallet/money = 2,
		/obj/item/survivalcapsule/fishing = 1,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY //For beginners

/datum/fish_source/holographic
	catalog_description = "Holographic water"
	fish_table = list(
		/obj/item/fish/holo = 10,
		/obj/item/fish/holo/crab = 10,
		/obj/item/fish/holo/puffer = 10,
		/obj/item/fish/holo/angel = 10,
		/obj/item/fish/holo/clown = 10,
		/obj/item/fish/holo/checkered = 5,
		/obj/item/fish/holo/halffish = 5,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD

/datum/fish_source/holographic/on_fishing_spot_init(datum/component/fishing_spot/spot)
	ADD_TRAIT(spot.parent, TRAIT_UNLINKABLE_FISHING_SPOT, REF(src)) //You would have to be inside the holodeck anyway...

/datum/fish_source/holographic/on_fishing_spot_del(datum/component/fishing_spot/spot)
	REMOVE_TRAIT(spot.parent, TRAIT_UNLINKABLE_FISHING_SPOT, REF(src))

/datum/fish_source/holographic/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/obj/item/fish/prototype = /obj/item/fish/holo/checkered
	return LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Holographic Fish",
		FISH_SOURCE_AUTOWIKI_ICON = FISH_AUTOWIKI_FILENAME(prototype),
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "Holographic fish disappears outside the Holodeck",
	))

/datum/fish_source/holographic/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	. = ..()
	if(!istype(get_area(fisherman), /area/station/holodeck))
		return "You need to be inside the Holodeck to catch holographic fish."

/datum/fish_source/holographic/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_area))

/datum/fish_source/holographic/proc/check_area(mob/user)
	SIGNAL_HANDLER
	if(!istype(get_area(user), /area/station/holodeck))
		interrupt_challenge("exited holodeck")

/datum/fish_source/holographic/on_challenge_completed(datum/fishing_challenge/source, mob/user, success)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/datum/fish_source/oil_well
	catalog_description = "Oil wells"
	radial_state = "oil"
	overlay_state = "portal_chasm" //close enough to pitch black
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/boned = 10,
		/obj/item/stack/sheet/bone = 2,
		/obj/item/clothing/gloves/bracer = 2,
		/obj/effect/decal/remains/human = 2,
		/obj/item/fish/mastodon = 1,
		/obj/item/fishing_rod/telescopic/master = 1,
	)
	fish_counts = list(
		/obj/item/clothing/gloves/bracer = 1,
		/obj/effect/decal/remains/human = 1,
		/obj/item/fish/mastodon = 1,
		/obj/item/fishing_rod/telescopic/master = 1,
	)
	fish_count_regen = list(
		/obj/item/fish/mastodon = 8 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15

/datum/fish_source/hydro_tray
	catalog_description = "Hydroponics trays"
	radial_state = "hydro"
	overlay_state = "portal_tray"
	fish_table = list(
		FISHING_DUD = 25,
		/obj/item/food/grown/grass = 25,
		FISHING_RANDOM_SEED = 16,
		/obj/item/seeds/grass = 6,
		/obj/item/seeds/random = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/axolotl = 1,
	)
	fish_counts = list(
		/obj/item/food/grown/grass = 10,
		/obj/item/seeds/grass = 4,
		FISHING_RANDOM_SEED = 4,
		/obj/item/seeds/random = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/axolotl = 1,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY - 5

/datum/fish_source/hydro_tray/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()
	var/total_weight = 0
	var/critter_weight = 0
	var/seed_weight = 0
	var/other_weight = 0
	var/dud_weight = fish_table[FISHING_DUD]
	for(var/content in fish_table)
		var/weight = fish_table[content]
		total_weight += weight
		if(ispath(content, /mob/living))
			critter_weight += weight
		else if(ispath(content, /obj/item/food/grown) || ispath(content, /obj/item/seeds) || content == FISHING_RANDOM_SEED)
			seed_weight += weight
		else if(content != FISHING_DUD)
			other_weight += weight

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = FISH_SOURCE_AUTOWIKI_DUD,
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(dud_weight/total_weight),
		FISH_SOURCE_AUTOWIKI_WEIGHT_SUFFIX = "WITHOUT A BAIT",
		FISH_SOURCE_AUTOWIKI_NOTES = "",
	))

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Critter",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(critter_weight/total_weight),
		FISH_SOURCE_AUTOWIKI_NOTES = "A small creature, usually a frog or an axolotl",
	))

	if(other_weight)
		data += LIST_VALUE_WRAP_LISTS(list(
			FISH_SOURCE_AUTOWIKI_NAME = "Other Stuff",
			FISH_SOURCE_AUTOWIKI_DUD = "",
			FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(other_weight/total_weight),
			FISH_SOURCE_AUTOWIKI_NOTES = "Other stuff, who knows...",
		))

	return data

/datum/fish_source/hydro_tray/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	if(!istype(parent, /obj/machinery/hydroponics/constructable))
		return ..()

	var/obj/machinery/hydroponics/constructable/basin = parent
	if(basin.waterlevel <= 0)
		return "There's no water in [parent] to fish in."
	if(basin.myseed)
		return "There's a plant growing in [parent]."

	return ..()

/datum/fish_source/hydro_tray/spawn_reward_from_explosion(atom/location, severity)
	if(!istype(location, /obj/machinery/hydroponics/constructable))
		return ..()

	var/obj/machinery/hydroponics/constructable/basin = location
	if(basin.myseed || basin.waterlevel <= 0)
		return
	return ..()

/datum/fish_source/hydro_tray/spawn_reward(reward_path, mob/fisherman, turf/fishing_spot)
	if(reward_path != FISHING_RANDOM_SEED)
		var/mob/living/created_reward = ..()
		if(istype(created_reward))
			created_reward.name = "small [created_reward.name]"
			created_reward.update_transform(0.75)
		return created_reward

	var/static/list/seeds_to_draw_from
	if(isnull(seeds_to_draw_from))
		seeds_to_draw_from = subtypesof(/obj/item/seeds)
		// These two are already covered innately
		seeds_to_draw_from -= /obj/item/seeds/random
		seeds_to_draw_from -= /obj/item/seeds/grass
		// -1 yield are unharvestable plants so we don't care
		// 20 rarirty is where most of the wacky plants are so let's ignore them
		for(var/obj/item/seeds/seed_path as anything in seeds_to_draw_from)
			if(initial(seed_path.yield) == -1 || initial(seed_path.rarity) >= PLANT_MODERATELY_RARE)
				seeds_to_draw_from -= seed_path

	var/picked_path = pick(seeds_to_draw_from)
	return new picked_path(get_turf(fishing_spot))

/datum/fish_source/carp_rift
	catalog_description = "Space Dragon Rifts"
	radial_state = "carp"
	overlay_state = "portal_rift"
	fish_table = list(
		FISHING_DUD = 3,
		/obj/item/fish/baby_carp = 5,
		/mob/living/basic/carp = 1,
		/mob/living/basic/carp/passive = 1,
		/mob/living/basic/carp/mega = 1,
		/obj/item/clothing/head/fedora/carpskin = 1,
		/obj/item/toy/plush/carpplushie = 1,
		/obj/item/toy/plush/carpplushie/dehy_carp/peaceful = 1,
		/obj/item/knife/carp = 1,
	)
	fish_counts = list(
		/mob/living/basic/carp/mega = 2,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 18

/datum/fish_source/deepfryer
	catalog_description = "Deep Fryers"
	radial_state = "fryer"
	overlay_state = "portal_fry" // literally resprited lava. better than nothing
	fish_table = list(
		/obj/item/food/badrecipe = 15,
		/obj/item/food/nugget = 5,
		/obj/item/fish/fryish = 40,
		/obj/item/fish/fryish/fritterish = 4,
		/obj/item/fish/fryish/nessie = 1,
	)
	fish_counts = list(
		/obj/item/fish/fryish = 10,
		/obj/item/fish/fryish/fritterish = 4,
		/obj/item/fish/fryish/nessie = 1,
	)
	fish_count_regen = list(
		/obj/item/fish/fryish = 2 MINUTES,
		/obj/item/fish/fryish/fritterish = 6 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 13

/datum/fish_source/hot_spring
	catalog_description = "Hot Springs"
	radial_state = "onsen"
	overlay_state = "portal_ocean"
	fish_table = list(
		FISHING_DUD = 20,
		/obj/item/fish/bumpy = 10,
		/obj/item/fish/sacabambaspis = 10,
		/mob/living/basic/frog = 2,
		/obj/item/fishing_rod/telescopic/master = 1,
	)
	fish_counts = list(
		/obj/item/fish/sacabambaspis = 5,
		/obj/item/fishing_rod/telescopic/master = 2,
	)
	fish_count_regen = list(
		/obj/item/fish/sacabambaspis = 4 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/tizira
	catalog_description = "Tiziran Sea"
	radial_state = "planet"
	overlay_state = "portal_beach"
	fish_table = list(
		FISHING_DUD = 10,
		/obj/item/fish/needlefish = 5,
		/obj/item/fish/armorfish = 5,
		/obj/item/fish/gunner_jellyfish = 4,
		/obj/item/fish/moonfish/dwarf = 2,
		/obj/item/fish/moonfish = 2,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS
