/datum/fish_source/ocean
	fish_table = list(
		FISHING_DUD = 15,
		/obj/item/coin/gold = 5,
		/obj/item/fish/clownfish = 15,
		/obj/item/fish/pufferfish = 15,
		/obj/item/fish/cardinal = 15,
		/obj/item/fish/greenchromis = 15,
		/obj/item/fish/lanternfish = 5
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5

/datum/fish_source/ocean/beach
	catalog_description = "Beach shore water"

/datum/fish_source/portal
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/goldfish = 10,
		/obj/item/fish/guppy = 10,
	)
	catalog_description = "Fish dimension (Fishing portal generator)"

/datum/fish_source/chasm
	catalog_description = "Chasm depths"
	background = "fishing_background_lavaland"
	fish_table = list(
		FISHING_DUD = 5,
		/obj/item/fish/chasm_crab = 15,
		/obj/item/chasm_detritus = 30,
	)

	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5


/datum/fish_source/chasm/roll_reward(obj/item/fishing_rod/rod, mob/fisherman)
	var/rolled_reward = ..()

	if(!rod.hook || !ispath(rolled_reward, /obj/item/chasm_detritus))
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


/datum/fish_source/moisture_trap
	catalog_description = "moisture trap basins"
	fish_table = list(
		FISHING_DUD = 20,
		/obj/item/fish/ratfish = 10
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 10
