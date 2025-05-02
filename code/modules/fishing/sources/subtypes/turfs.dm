//Generic fish sources that're usually associated with non-mining turfs

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
	associated_safe_turfs = list(/turf/open/water/deep_beach, /turf/open/water/beach)

/datum/fish_source/ocean/beach
	catalog_description = "Beach shore water"
	radial_state = "palm_beach"
	overlay_state = "portal_beach"
	associated_safe_turfs = list(/turf/open/water/beach)

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
	associated_safe_turfs = list(/turf/open/water)
	safe_turfs_blacklist = list(/turf/open/water/hot_spring, /turf/open/water/beach)

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
	associated_safe_turfs = list(/turf/open/water)
	safe_turfs_blacklist = list(/turf/open/water/hot_spring, /turf/open/water/beach)

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
	associated_safe_turfs = list(/turf/open/water/hot_spring)

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
	associated_safe_turfs = list(/turf/open/water/beach/tizira)
