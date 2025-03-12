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
		/obj/structure/mystery_box/fishing = 32 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/ocean/beach
	catalog_description = "Beach shore water"
	radial_state = "palm_beach"
	overlay_state = "portal_beach"

/datum/fish_source/ice_fishing
	background = "background_ice"
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 30

/datum/fish_source/river
	catalog_description = "River water"
	radial_state = "river"
	overlay_state = "portal_river"
	fish_table = list(
		FISHING_DUD = 4,
		/obj/item/fish/goldfish = 5,
		/obj/item/fish/guppy = 5,
		/obj/item/fish/plasmatetra = 4,
		/obj/item/fish/perch = 4,
		/obj/item/fish/angelfish = 4,
		/obj/item/fish/catfish = 4,
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 30
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 35
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

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
	background = "background_chasm"
	radial_state = "ground_hole"
	overlay_state = "portal_chasm"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab = 15,
		/datum/chasm_detritus = 30,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_NONE

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
	fish_count_regen = list(
		/obj/structure/closet/crate/necropolis/tendril = 27 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/lavaland/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	. = ..()
	if(!HAS_TRAIT(rod, TRAIT_ROD_LAVA_USABLE))
		return "You'll need reinforced fishing line to fish in there."

/datum/fish_source/lavaland/icemoon
	background = "background_plasma"
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
	fish_count_regen = list(
		/obj/item/stack/sheet/mineral/adamantine = 8 MINUTES,
		/obj/item/stack/sheet/mineral/runite = 10 MINUTES,
	)
	overlay_state = "portal_plasma"

/datum/fish_source/moisture_trap
	background = "background_dank"
	catalog_description = "Moisture trap basins"
	radial_state = "garbage"
	overlay_state = "portal_river" // placeholder
	fish_table = list(
		FISHING_DUD = 20,
		/obj/item/fish/ratfish = 10,
		/obj/item/fish/slimefish = 4,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20

/datum/fish_source/toilet
	background = "background_dank"
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
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 10

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
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 10
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
	background = "background_oil_well"
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 25

/datum/fish_source/hydro_tray
	background = "background_tray"
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
		/mob/living/basic/turtle = 2,
	)
	fish_counts = list(
		/obj/item/food/grown/grass = 10,
		/obj/item/seeds/grass = 4,
		FISHING_RANDOM_SEED = 4,
		/obj/item/seeds/random = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/axolotl = 1,
	)
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 5

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

/datum/fish_source/hydro_tray/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot, obj/item/fishing_rod/used_rod)
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
	return new picked_path(spawn_location)

/datum/fish_source/carp_rift
	background = "background_carp_rift"
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
	fish_count_regen = list(
		/mob/living/basic/carp/mega = 9 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 28

/datum/fish_source/deepfryer
	background = "background_lavaland"
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
		/obj/item/fish/fryish/nessie = 22 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 23

/datum/fish_source/surgery
	catalog_description = "Surgery"
	radial_state = "innards"
	overlay_state = "portal_syndicate" //Didn't feel like spriting a new overlay. It's just all red anyway.
	background = "background_lavaland" //Kinda red.
	fish_table = list(FISHING_RANDOM_ORGAN = 10)
	//This should get you below zero difficulty and skip the minigame phase, unless you're wearing something that counteracts this.
	fishing_difficulty = -10
	//The range for waiting is also a bit narrower, so it cannot take as few as 3 seconds or as many as 25 to snatch an organ.
	wait_time_range = list(6 SECONDS, 12 SECONDS)

/datum/fish_source/surgery/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot, obj/item/fishing_rod/used_rod)
	if(istype(fishing_spot, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = fishing_spot
		fishing_spot = portal.current_linked_atom
	if(!iscarbon(fishing_spot))
		var/random_type = pick(subtypesof(/obj/item/organ) - GLOB.prototype_organs)
		return new random_type(spawn_location)

	var/mob/living/carbon/carbon = fishing_spot
	var/list/possible_organs = list()
	for(var/datum/surgery/organ_manipulation/operation in carbon.surgeries)
		var/datum/surgery_step/manipulate_organs/manip_step = GLOB.surgery_steps[operation.steps[operation.status]]
		if(!istype(manip_step))
			continue
		for(var/obj/item/organ/organ in operation.operated_bodypart)
			if(organ.organ_flags & ORGAN_UNREMOVABLE || !manip_step.can_use_organ(organ))
				continue
			possible_organs |= organ

	if(!length(possible_organs))
		return null
	var/obj/item/organ/chosen = pick(possible_organs)
	chosen.Remove(chosen.owner)
	chosen.forceMove(spawn_location)
	return chosen

/datum/fish_source/surgery/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Organs",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "A random organ from an ongoing organ manipulation surgery.",
	))

	return data

#define RANDOM_AQUARIUM_FISH "random_aquarium_fish"

/datum/fish_source/aquarium
	catalog_description = "Aquariums"
	radial_state = "fish_tank"
	fish_table = list(
		FISHING_DUD = 10,
	)
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD|FISH_SOURCE_FLAG_IGNORE_HIDDEN_ON_CATALOG|FISH_SOURCE_FLAG_EXPLOSIVE_NONE
	fishing_difficulty = FISHING_EASY_DIFFICULTY + 5

#undef RANDOM_AQUARIUM_FISH

/datum/fish_source/aquarium/get_fish_table(atom/location, from_explosion = FALSE)
	if(istype(location, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = location
		location = portal.current_linked_atom
	var/list/table = list()
	for(var/obj/item/fish/fish in location)
		if(fish.status == FISH_DEAD) //dead fish cannot be caught
			continue
		table[fish] = 10
	if(!length(table))
		return fish_table.Copy()
	return table

/datum/fish_source/aquarium/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Fish",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "Any fish currently inside the aquarium, be they alive or dead.",
	))

	return data

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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 30
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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS

/datum/fish_source/vending
	background = "background_chasm"
	catalog_description = "Vending Machines"
	radial_state = "vending"
	overlay_state = "portal_randomizer"
	fish_table = list(
		FISHING_DUD = 10,
	)
	fish_source_flags = FISH_SOURCE_FLAG_NO_BLUESPACE_ROD|FISH_SOURCE_FLAG_EXPLOSIVE_NONE
	fishing_difficulty = FISHING_EASY_DIFFICULTY //with some equipment and just enough dosh, you should be able to skip the minigame

/datum/fish_source/vending/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()

	data += LIST_VALUE_WRAP_LISTS(list(
		FISH_SOURCE_AUTOWIKI_NAME = "Vending Products",
		FISH_SOURCE_AUTOWIKI_DUD = "",
		FISH_SOURCE_AUTOWIKI_WEIGHT = 100,
		FISH_SOURCE_AUTOWIKI_NOTES = "Use chips, bills or coins as bait to get a semi-random vending product, depending on both its and the bait's monetary values",
	))

	return data

/datum/fish_source/vending/get_modified_fish_table(obj/item/fishing_rod/rod, mob/fisherman, atom/location)
	if(istype(location, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = location
		location = portal.current_linked_atom
	if(!istype(location, /obj/machinery/vending))
		return list()

	return get_vending_table(rod, fisherman, location)

/datum/fish_source/vending/proc/get_vending_table(obj/item/fishing_rod/rod, mob/fisherman, obj/machinery/vending/location)
	var/list/table = list()
	///Create a list of products, ordered by price from highest to lowest
	var/list/products = location.product_records + location.coin_records + location.hidden_records
	sortTim(products, GLOBAL_PROC_REF(cmp_vending_prices))

	var/bait_value = rod.bait?.get_item_credit_value() || 1

	var/highest_record_price = 0
	for(var/datum/data/vending_product/product_record as anything in products)
		if(product_record.amount <= 0)
			products -= product_record
			table[FISHING_DUD] += PAYCHECK_LOWER //it gets harder the emptier the machine is
			continue
		if(!highest_record_price)
			highest_record_price = product_record.price
		var/high = max(highest_record_price, bait_value)
		var/low = min(highest_record_price, bait_value)

		//the smaller the difference between product price and bait value, the more likely you're to get it.
		table[product_record] = low/high * 1000 //multiply the value by 1000 for accuracy. pick_weight() doesn't work with zero decimals yet.

	add_risks(table, bait_value, highest_record_price, length(products) * 0.5)
	return table

/datum/fish_source/vending/proc/add_risks(list/table, bait_value, highest_price, malus_multiplier)
	///Using more than the money needed to buy the most expensive item (why would you do it?!) will remove the dud chance.
	if(bait_value > highest_price)
		table -= FISHING_DUD
	else
		//Makes using 1 cred chips with the minigame skip (negative fishing difficulty) a bit less cheesy.
		var/malus = min(PAYCHECK_LOWER - bait_value, highest_price)
		if(malus > 0)
			table[FISHING_DUD] += malus * malus_multiplier
			table[FISHING_VENDING_CHUCK] += malus * malus_multiplier

#define FISHING_PRODUCT_DIFFICULTY_MULT 1.6

/datum/fish_source/vending/calculate_difficulty(datum/fishing_challenge/challenge, result, obj/item/fishing_rod/rod, mob/fisherman)
	//Using less than a minimum paycheck is going to make the challenge a tad harder.
	var/bait_value = rod.bait?.get_item_credit_value()
	var/base_diff = PAYCHECK_LOWER - bait_value
	return ..() + get_product_difficulty(base_diff, result) * FISHING_PRODUCT_DIFFICULTY_MULT

/datum/fish_source/vending/proc/get_product_difficulty(diff, datum/result)
	if(istype(result, /datum/data/vending_product))
		var/datum/data/vending_product/product = result
		diff = min(diff, product.price) // low priced items are easier to catch anyway
	return diff

#undef FISHING_PRODUCT_DIFFICULTY_MULT

/datum/fish_source/vending/dispense_reward(reward_path, mob/fisherman, atom/fishing_spot, obj/item/fishing_rod/rod)
	var/obj/machinery/vending/vending = fishing_spot
	if(istype(fishing_spot, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = fishing_spot
		vending = portal.current_linked_atom

	if(reward_path == FISHING_VENDING_CHUCK)
		if(fishing_spot != vending) //fishing portals
			vending.forceMove(get_turf(fishing_spot))
		vending.tilt(fisherman, range = 4)
		return null //Don't spawn a reward at all

	var/atom/movable/reward = ..()
	if(reward)
		var/creds_value = rod.bait?.get_item_credit_value()
		if(creds_value)
			vending.credits_contained += round(creds_value * VENDING_CREDITS_COLLECTION_AMOUNT)
			qdel(rod.bait)
	return reward

/datum/fish_source/vending/spawn_reward(reward_path, atom/spawn_location, obj/machinery/vending/fishing_spot, obj/item/fishing_rod/used_rod)
	if(istype(fishing_spot, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = fishing_spot
		fishing_spot = portal.current_linked_atom
	if(!istype(fishing_spot))
		return null
	return spawn_vending_reward(reward_path, spawn_location, fishing_spot)

/datum/fish_source/vending/proc/spawn_vending_reward(reward_path, atom/spawn_location, obj/machinery/vending/fishing_spot)
	var/datum/data/vending_product/product_record = reward_path
	if(!istype(product_record) || product_record.amount <= 0)
		return null
	return fishing_spot.dispense(product_record, spawn_location)

/datum/fish_source/vending/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
	RegisterSignal(rod, COMSIG_FISHING_ROD_CAUGHT_FISH, PROC_REF(on_reward))

/datum/fish_source/vending/on_challenge_completed(mob/user, datum/fishing_challenge/challenge, success)
	. = ..()
	UnregisterSignal(challenge.used_rod, COMSIG_FISHING_ROD_CAUGHT_FISH)

/datum/fish_source/vending/proc/on_reward(obj/item/fishing_rod/rod, atom/movable/reward, mob/user)
	SIGNAL_HANDLER
	if(reward && !QDELETED(rod.bait) && rod.bait.get_item_credit_value()) //you pay for what you get
		qdel(rod.bait) // fishing_rod.Exited() will handle clearing the hard ref.

///subtype of fish_source/vending for custom vending machines
/datum/fish_source/vending/custom
	catalog_description = null //no duplicate entries on autowiki or catalog

/datum/fish_source/vending/custom/get_vending_table(obj/item/fishing_rod/rod, mob/fisherman, obj/machinery/vending/location)
	var/list/table = list()
	///Create a list of products, ordered by price from highest to lowest
	var/list/products = location.vending_machine_input.Copy()
	sortTim(products, GLOBAL_PROC_REF(cmp_item_vending_prices))

	var/bait_value = rod.bait?.get_item_credit_value() || 1

	var/highest_record_price = 0
	for(var/obj/item/stocked as anything in products)
		if(location.vending_machine_input[stocked] <= 0)
			products -= stocked
			table[FISHING_DUD] += PAYCHECK_LOWER //it gets harder the emptier the machine is
			continue
		if(!highest_record_price)
			highest_record_price = stocked.custom_price
		var/high = max(highest_record_price, bait_value)
		var/low = min(highest_record_price, bait_value)

		//the smaller the difference between product price and bait value, the more likely you're to get it.
		table[stocked] = low/high * 1000 //multiply the value by 1000 for accuracy. pick_weight() doesn't work with zero decimals yet.

	add_risks(table, bait_value, highest_record_price, length(products) * 0.5)
	return table

/datum/fish_source/vending/custom/get_product_difficulty(diff, datum/result)
	if(isitem(result))
		var/obj/item/product = result
		diff = min(diff, product.custom_price)
	return diff

/datum/fish_source/vending/custom/spawn_vending_reward(obj/item/reward, atom/spawn_location, obj/machinery/vending/fishing_spot)
	if(!isitem(reward))
		return null
	reward.forceMove(spawn_location)
	return reward

/datum/fish_source/dimensional_rift
	background = "background_mansus"
	catalog_description = null // it's a secret (sorta, I know you're reading this)
	radial_state = "cursed" // placeholder
	overlay_state = "portal_mansus"
	fish_table = list(
		FISHING_INFLUENCE = 6,
		FISHING_RANDOM_ARM = 3,
		/obj/item/fish/starfish/chrystarfish = 7,
		/obj/item/fish/dolphish = 7,
		/obj/item/fish/flumpulus = 7,
		/obj/item/fish/gullion = 7,
		/obj/item/fish/mossglob = 3,
		/obj/item/fish/babbelfish = 1,
		/mob/living/basic/heretic_summon/fire_shark/wild = 3,
		/obj/item/eldritch_potion/crucible_soul = 1,
		/obj/item/eldritch_potion/duskndawn = 1,
		/obj/item/eldritch_potion/wounded = 1,
		/obj/item/reagent_containers/cup/beaker/eldritch = 2,
	)
	fish_counts = list(
		/obj/item/fish/mossglob = 3,
		/obj/item/fish/babbelfish = 1,
		/mob/living/basic/heretic_summon/fire_shark/wild = 3,
		/obj/item/eldritch_potion/crucible_soul = 1,
		/obj/item/eldritch_potion/duskndawn = 1,
		/obj/item/eldritch_potion/wounded = 1,
		/obj/item/reagent_containers/cup/beaker/eldritch = 2,
	)
	fish_count_regen = list(
		/obj/item/fish/mossglob = 3 MINUTES,
		/obj/item/fish/babbelfish = 5 MINUTES,
		/mob/living/basic/heretic_summon/fire_shark/wild = 6 MINUTES,
		/obj/item/eldritch_potion/crucible_soul = 5 MINUTES,
		/obj/item/eldritch_potion/duskndawn = 5 MINUTES,
		/obj/item/eldritch_potion/wounded = 5 MINUTES,
		/obj/item/reagent_containers/cup/beaker/eldritch = 2.5 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 35
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_NONE

/**
 * You can fish up random arms, but you can also fish up arms (or heads, from TK) that were eaten at some point by a rift.
 * No need to check for what the location is, just get its limbs from its contents. It should always be a visible heretic rift. Should.
 */
/datum/fish_source/dimensional_rift/get_fish_table(atom/location, from_explosion = FALSE)
	. = ..()
	if(istype(location, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = location
		location = portal.current_linked_atom

	for(var/obj/item/eaten_thing in location.get_all_contents())
		.[eaten_thing] = 6

/datum/fish_source/dimensional_rift/on_challenge_completed(mob/user, datum/fishing_challenge/challenge, success)
	. = ..()

	if(!success)
		if(IS_HERETIC(user))
			return
		if(!user.get_active_hand())
			return influence_fished(user, challenge)
		on_epic_fail(user, challenge, success)
		return


	if(challenge.reward_path == FISHING_INFLUENCE)
		influence_fished(user, challenge)
		return

	return

/**
 * Override for influences and arms.
 */
/datum/fish_source/dimensional_rift/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot)
	switch(reward_path)
		if(FISHING_INFLUENCE)
			return
		if(FISHING_RANDOM_ARM)
			return arm_fished(spawn_location)
	return ..()

/**
 * This happens when a non-heretic fails the minigame. Their arm is ripped straight off and thrown into the rift.
 */
/datum/fish_source/dimensional_rift/proc/on_epic_fail(mob/user, datum/fishing_challenge/challenge, success)
	challenge.location.visible_message(span_danger("[challenge.location]'s tendrils lash out and pull on [user]'s [user.get_active_hand()], ripping it clean off and throwing it towards itself!"))
	var/obj/item/bodypart/random_arm = user.get_active_hand()
	random_arm.dismember(BRUTE, FALSE)
	random_arm.forceMove(user.drop_location())
	random_arm.throw_at(challenge.location, 7, 1, null, TRUE)
	// Abstract items shouldn't be thrown in!
	if(!(challenge.used_rod.item_flags & ABSTRACT))
		challenge.used_rod.forceMove(user.drop_location())
		challenge.used_rod.throw_at(challenge.location, 7, 1, null, TRUE)
	addtimer(CALLBACK(src, PROC_REF(check_item_location), challenge.location, random_arm, challenge.used_rod), 1 SECONDS)

/datum/fish_source/dimensional_rift/proc/check_item_location(atom/location, obj/item/bodypart/random_arm, obj/item/used_rod)
	for(var/obj/item/thingy in get_turf(location))
		// If it's not in the list and it's not what we know as the used rod, skip.
		// This lets fishing gloves be dragged in as well. I mean honestly if you try fishing in here with those you should just Fucking Die but that's for later.
		if(!is_type_in_list(thingy, list(/obj/item/bodypart, /obj/item/fishing_rod)) && (thingy != used_rod))
			continue
		thingy.forceMove(location)
		location.visible_message(span_danger("Tendrils lash out from [location] and greedily drag [thingy] inwards. You're probably never seeing [thingy] again."))

/datum/fish_source/dimensional_rift/proc/arm_fished(atom/spawn_location)
	var/obj/item/bodypart/arm/random_arm = pick(subtypesof(/obj/item/bodypart/arm))
	random_arm = new random_arm(spawn_location)
	spawn_location.visible_message(span_notice("A [random_arm] is snatched up from beneath the eldritch depths of [spawn_location]!"))
	return random_arm

/datum/fish_source/dimensional_rift/proc/influence_fished(mob/user, datum/fishing_challenge/challenge)
	if(challenge.reward_path != FISHING_INFLUENCE)
		return
	var/mob/living/carbon/human/human_user
	if(ishuman(user))
		human_user = user

	user.visible_message(span_danger("[user] reels [user.p_their()] [challenge.used_rod] in, catching a glimpse into the world beyond!"), span_notice("You catch.. a glimpse into the workings of the Mansus itself!"))
	// Heretics that fish in the rift gain knowledge.
	if(IS_HERETIC(user))
		human_user?.add_mood_event("rift fishing", /datum/mood_event/rift_fishing)
		var/obj/effect/heretic_influence/fishfluence = challenge.location
		// But only if it's an open rift
		if(!istype(fishfluence))
			to_chat(user, span_notice("You glimpse something fairly uninteresting."))
			return
		fishfluence.after_drain(user)
		var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
		if(heretic_datum)
			heretic_datum.knowledge_points++
			to_chat(user, "[span_hear("You hear a whisper...")] [span_hypnophrase("THE HIGHER I RISE, THE MORE I FISH.")]")
			// They can also gain an extra influence point if they infused their rod.
			if(HAS_TRAIT(challenge.used_rod, TRAIT_ROD_MANSUS_INFUSED))
				heretic_datum.knowledge_points++
			to_chat(user, span_boldnotice("Your infused rod improves your knowledge gain!"))
		return

	// Non-heretics instead go crazy
	human_user?.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	human_user?.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
	human_user?.do_jitter_animation(50)
	// Hand fires at them from the location
	fire_curse_hand(user, get_turf(challenge.location))
