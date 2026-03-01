//Fish sources that're usually found in ruins or on mining z-levels should go here

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
	associated_safe_turfs = list(/turf/open/water/hot_spring)

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
		/obj/item/stack/ore/slag = 15,
		/obj/item/fish/lavaloop = 15,
		/obj/structure/closet/crate/necropolis/tendril = 1,
		/obj/item/skeleton_key = 1,
		/obj/item/stack/sheet/mineral/runite = 1,
		/obj/effect/mob_spawn/corpse/human/charredskeleton = 1,
	)
	fish_counts = list(
		/obj/structure/closet/crate/necropolis/tendril = 1,
		/obj/item/skeleton_key = 1,
		/obj/item/stack/sheet/mineral/runite = 2,
	)
	fish_count_regen = list(
		/obj/structure/closet/crate/necropolis/tendril = 27 MINUTES,
		/obj/item/skeleton_key = 13 MINUTES,
		/obj/item/stack/sheet/mineral/runite = 15 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 20
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_MALUS
	associated_safe_turfs = list(/turf/open/lava)
	safe_turfs_blacklist = list(/turf/open/lava/plasma)

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
		/obj/item/skeleton_key = 1,
		/obj/structure/closet/crate/necropolis/tendril = 1,
		/mob/living/basic/mining/lobstrosity = 1,
		/mob/living/basic/mining/lobstrosity/juvenile = 1,
	)
	fish_counts = list(
		/obj/item/stack/sheet/mineral/adamantine = 3,
		/obj/item/stack/sheet/mineral/runite = 2,
		/obj/item/skeleton_key = 1,
		/obj/structure/closet/crate/necropolis/tendril = 1,
	)
	fish_count_regen = list(
		/obj/item/stack/sheet/mineral/adamantine = 8 MINUTES,
		/obj/item/stack/sheet/mineral/runite = 10 MINUTES,
		/obj/item/skeleton_key = 15 MINUTES,
		/obj/structure/closet/crate/necropolis/tendril = 30 MINUTES,
	)
	overlay_state = "portal_plasma"
	associated_safe_turfs = list(/turf/open/lava/plasma)

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
