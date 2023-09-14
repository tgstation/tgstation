/datum/fish_source/ocean
	fish_table = list(
		FISHING_DUD = 15,
		/obj/item/coin/gold = 5,
		/obj/item/fish/clownfish = 15,
		/obj/item/fish/pufferfish = 15,
		/obj/item/fish/cardinal = 15,
		/obj/item/fish/greenchromis = 15,
		/obj/item/fish/lanternfish = 5,
		/obj/item/fish/clownfish/lube = 3,
	)
	fish_counts = list(
		/obj/item/fish/clownfish/lube = 2,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5

/datum/fish_source/ocean/beach
	catalog_description = "Beach shore water"

/datum/fish_source/portal
	fish_table = list(
		FISHING_DUD = 7,
		/obj/item/fish/goldfish = 10,
		/obj/item/fish/guppy = 10,
		/obj/item/fish/angelfish = 10,
	)
	catalog_description = "Aquarium dimension (Fishing portal generator)"
	///The name of this option shown in the radial menu on the fishing portal generator
	var/radial_name = "Aquarium"
	///The icon state shown for this option in the radial menu
	var/radial_state = "fish_tank"
	///The icon state of the overlay shown on the machine when active.
	var/overlay_state = "portal_aquarium"

/datum/fish_source/portal/beach
	fish_table = list(
		FISHING_DUD = 10,
		/obj/item/fish/clownfish = 10,
		/obj/item/fish/pufferfish = 10,
		/obj/item/fish/cardinal = 10,
		/obj/item/fish/greenchromis = 10,
	)
	catalog_description = "Beach dimension (Fishing portal generator)"
	radial_name = "Beach"
	radial_state = "palm_beach"

/datum/fish_source/portal/chasm
	background = "fishing_background_lavaland"
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
		FISHING_DUD = 5,
		/obj/item/fish/lanternfish = 5,
		/obj/item/fish/firefish = 5,
		/obj/item/fish/dwarf_moonfish = 5,
		/obj/item/fish/gunner_jellyfish = 5,
		/obj/item/fish/needlefish = 5,
		/obj/item/fish/armorfish = 5,
	)
	catalog_description = "Ocean dimension (Fishing portal generator)"
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
	radial_name = "Ocean"
	overlay_state = "portal_ocean"
	radial_state = "seaboat"

/datum/fish_source/portal/hyperspace
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/starfish = 6,
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
	background = "fishing_background_lavaland"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/donkfish = 5,
		/obj/item/fish/emulsijack = 5,
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
	var/static/list/all_portal_fish_sources_at_once
	radial_state = "misaligned_question_mark"

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

///In the spirit of randomness, difficulty, fish icon and effects are also affected by this fishing source.
/datum/fish_source/portal/random/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
	challenge.fish_icon_override = pick(
		FA_ICON_QUESTION,
		FA_ICON_LAUGH,
		FA_ICON_MEH,
		FA_ICON_FISH,
		FA_ICON_FIGHTER_JET,
		FA_ICON_GHOST,
		FA_ICON_ENVELOPE,
		FA_ICON_ANCHOR,
		FA_ICON_TRASH_ALT,
		FA_ICON_HOTDOG)
	challenge.difficulty += rand(-10, 15)

	var/list/additional_effects = list(
		FISHING_MINIGAME_RULE_ANTIGRAV,
		FISHING_MINIGAME_RULE_HEAVY_FISH,
		FISHING_MINIGAME_RULE_LUBED,
		FISHING_MINIGAME_RULE_LIMIT_LOSS,
		FISHING_MINIGAME_RULE_WEIGHTED_BAIT,
		FISHING_MINIGAME_RULE_FLIP,
	)
	for(var/iteration in 1 to rand(1, 3))
		challenge.special_effects |= pick_n_take(additional_effects)

///Cherry on top, fish caught from the randomizer portal also have (almost completely) random traits
/datum/fish_source/portal/random/spawn_reward(reward_path, mob/fisherman, turf/fishing_spot)
	if(!ispath(reward_path, /obj/item/fish))
		return ..()

	var/static/list/weighted_traits
	if(!weighted_traits)
		weighted_traits = list()
		for(var/trait_type as anything in GLOB.fish_traits)
			var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
			weighted_traits[trait.type] = round(trait.inheritability**2/100)

	var/obj/item/fish/caught_fish = new reward_path(get_turf(fisherman), FALSE)
	var/list/fixed_traits = list()
	for(var/trait_type in caught_fish.fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
		if(caught_fish.type in trait.guaranteed_inheritance_types)
			fixed_traits += trait_type
	var/list/new_traits = list()
	for(var/iteration in rand(1, 4))
		new_traits |= pick_weight(weighted_traits)
	caught_fish.inherit_traits(new_traits, fixed_traits = fixed_traits)
	caught_fish.randomize_size_and_weight(deviation = 0.3)
	caught_fish.progenitors = full_capitalize(caught_fish.name)
	return caught_fish

/datum/fish_source/chasm
	catalog_description = "Chasm depths"
	background = "fishing_background_lavaland"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab = 15,
		/datum/chasm_detritus = 30,
	)

	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5

/datum/fish_source/chasm/roll_reward(obj/item/fishing_rod/rod, mob/fisherman)
	var/rolled_reward = ..()

	if(!rod.hook || !ispath(rolled_reward, /datum/chasm_detritus))
		return rolled_reward

	return rod.hook.chasm_detritus_type

/datum/fish_source/lavaland
	catalog_description = "Lava vents"
	background = "fishing_background_lavaland"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/stack/ore/slag = 20,
		/obj/structure/closet/crate/necropolis/tendril = 1,
		/obj/effect/mob_spawn/corpse/human/charredskeleton = 1
	)
	fish_counts = list(
		/obj/structure/closet/crate/necropolis/tendril = 1
	)

	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10

/datum/fish_source/lavaland/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	var/turf/approx = get_turf(fisherman) //todo pass the parent
	if(!SSmapping.level_trait(approx.z, ZTRAIT_MINING))
		return "There doesn't seem to be anything to catch here."
	if(!rod.line || !(rod.line.fishing_line_traits & FISHING_LINE_REINFORCED))
		return "You'll need reinforced fishing line to fish in there"

/datum/fish_source/lavaland/icemoon
	catalog_description = "Liquid plasma vents"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab/ice = 15,
		/obj/item/coin/plasma = 3,
		/obj/item/stack/ore/plasma = 3,
		/mob/living/basic/mining/lobstrosity = 1,
		/obj/effect/decal/remains/plasma = 1,
		/obj/item/stack/sheet/mineral/mythril = 1,
		/obj/item/stack/sheet/mineral/adamantine = 1,
	)
	fish_counts = list(
		/obj/item/stack/sheet/mineral/adamantine = 3,
		/obj/item/stack/sheet/mineral/mythril = 2,
	)

/datum/fish_source/moisture_trap
	catalog_description = "Moisture trap basins"
	fish_table = list(
		FISHING_DUD = 20,
		/obj/item/fish/ratfish = 10,
		/obj/item/fish/slimefish = 4
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10

/datum/fish_source/toilet
	catalog_description = "Station toilets"
	duds = list("ewww... nothing", "it was nothing", "it was toilet paper", "it was flushed away", "the hook is empty", "where's the damn money?!")
	fish_table = list(
		FISHING_DUD = 18,
		/obj/item/fish/sludgefish = 18,
		/obj/item/fish/slimefish = 4,
		/obj/item/storage/wallet/money = 2,
	)
	fish_counts = list(
		/obj/item/storage/wallet/money = 2,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY - 5 //For beginners

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
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY - 5

/datum/fish_source/holographic/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman)
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
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/boned = 10,
		/obj/item/stack/sheet/bone = 2,
		/obj/item/clothing/gloves/bracer = 2,
		/obj/effect/decal/remains/human = 2,
		/obj/item/fish/mastodon = 1,
	)
	fish_counts = list(
		/obj/item/clothing/gloves/bracer = 1,
		/obj/effect/decal/remains/human = 1,
		/obj/item/fish/mastodon = 1,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
