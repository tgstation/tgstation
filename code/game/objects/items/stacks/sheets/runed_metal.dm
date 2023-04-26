// Note, the order these in are deliberate, as it affects
// the order they are shown via radial.
GLOBAL_LIST_INIT(runed_metal_recipes, list( \
	new /datum/stack_recipe/radial( \
		title = "pylon", \
		result_type = /obj/structure/destructible/cult/pylon, \
		req_amount = 4, \
		time = 4 SECONDS, \
		one_per_turf = TRUE, \
		on_solid_ground = TRUE, \
		desc = span_cultbold("Pylon: Heals and regenerates the blood of nearby blood cultists and constructs, and also \
			converts nearby floor tiles into engraved flooring, which allows blood cultists to scribe runes faster."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "altar", \
		result_type = /obj/structure/destructible/cult/item_dispenser/altar, \
		req_amount = 3, \
		time = 4 SECONDS, \
		one_per_turf = TRUE, \
		on_solid_ground = TRUE, \
		desc = span_cultbold("Altar: Can make Eldritch Whetstones, Construct Shells, and Flasks of Unholy Water."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "archives", \
		result_type = /obj/structure/destructible/cult/item_dispenser/archives, \
		req_amount = 3, \
		time = 4 SECONDS, \
		one_per_turf = TRUE, \
		on_solid_ground = TRUE, \
		desc = span_cultbold("Archives: Can make Zealot's Blindfolds, Shuttle Curse Orbs, \
			and Veil Walker equipment. Emits Light."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "daemon forge", \
		result_type = /obj/structure/destructible/cult/item_dispenser/forge, \
		req_amount = 3, \
		time = 4 SECONDS, \
		one_per_turf = TRUE, \
		on_solid_ground = TRUE, \
		desc = span_cultbold("Daemon Forge: Can make Nar'Sien Hardened Armor, Flagellant's Robes, \
			and Eldritch Longswords. Emits Light."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "runed door", \
		result_type = /obj/machinery/door/airlock/cult, \
		time = 5 SECONDS, \
		one_per_turf = TRUE, \
		on_solid_ground = TRUE, \
		desc = span_cultbold("Runed Door: A weak door which stuns non-blood cultists who touch it."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "runed girder", \
		result_type = /obj/structure/girder/cult, \
		time = 5 SECONDS, \
		one_per_turf = TRUE, \
		on_solid_ground = TRUE, \
		desc = span_cultbold("Runed Girder: A weak girder that can be instantly destroyed by ritual daggers. Not a recommended usage of runed metal."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
))

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal sheet"
	icon_state = "sheet-runed"
	inhand_icon_state = "sheet-runed"
	icon = 'icons/obj/stack_objects.dmi'
	mats_per_unit = list(/datum/material/runedmetal = MINERAL_MATERIAL_AMOUNT)
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/blood = 15)
	material_type = /datum/material/runedmetal
	has_unique_girder = TRUE
	use_radial = TRUE

/obj/item/stack/sheet/runed_metal/interact(mob/user)
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("Only one with forbidden knowledge could hope to work this metal..."))
		return FALSE

	var/turf/user_turf = get_turf(user)
	var/area/user_area = get_area(user)

	var/is_valid_turf = user_turf && (is_station_level(user_turf.z) || is_mining_level(user_turf.z))
	var/is_valid_area = user_area && (user_area.area_flags & CULT_PERMITTED)

	if(!is_valid_turf || !is_valid_area)
		to_chat(user, span_warning("The veil is not weak enough here."))
		return FALSE

	return ..()

/obj/item/stack/sheet/runed_metal/radial_check(mob/builder)
	return ..() && IS_CULTIST(builder)

/obj/item/stack/sheet/runed_metal/get_main_recipes()
	. = ..()
	. += GLOB.runed_metal_recipes

/obj/item/stack/sheet/runed_metal/fifty
	amount = 50

/obj/item/stack/sheet/runed_metal/ten
	amount = 10

/obj/item/stack/sheet/runed_metal/five
	amount = 5
