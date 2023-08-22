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
	fish_counts = list(
		/obj/item/fish/clownfish/lube = 2,
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
		/obj/item/fish/slimefish = 2,
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

/datum/fish_source/holographic/pre_challenge_started(obj/item/fishing_rod/rod, mob/user)
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
	)
	fish_counts = list(
		/obj/item/clothing/gloves/bracer = 1,
		/obj/effect/decal/remains/human = 1,
		/obj/item/fish/mastodon = 1,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 15
