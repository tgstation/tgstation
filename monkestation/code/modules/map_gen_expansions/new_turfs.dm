/turf/open/misc/asteroid/forest
	gender = PLURAL
	name = "grass"
	desc = "A patch of grass."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	baseturfs = /turf/open/misc/dirt/forest
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_GRASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_CLOSED_TURFS
	layer = HIGH_TURF_LAYER
	//damaged_dmi = 'icons/turf/damaged.dmi'
	initial_gas_mix = FOREST_DEFAULT_ATMOS
	flags_1 = NONE
	planetary_atmos = TRUE
	dig_result = /obj/item/food/grown/grass
	changes_icon = FALSE
	/// Which icon file to use for turf specific edge smoothing states.
	var/smooth_icon = 'icons/turf/floors/grass.dmi'

/turf/open/misc/asteroid/forest/Initialize(mapload)
	. = ..()
	if(smoothing_flags)
		var/matrix/translation = new
		translation.Translate(-9, -9)
		transform = translation
		icon = smooth_icon

	if(is_station_level(z))
		GLOB.station_turfs += src

/turf/open/misc/asteroid/forest/getDug()
	. = ..()
	AddComponent(/datum/component/simple_farm)
	new /obj/item/stack/ore/glass(src)

/turf/open/misc/asteroid/forest/mushroom
	name = "mushroom floor"
	desc = "A patch of mushrooms."
	icon = 'monkestation/code/modules/map_gen_expansions/icons/floors.dmi'
	icon_state = "mushroom"
	base_icon_state = "mushroom"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_MUSHROOM
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MUSHROOM
	//damaged_dmi = 'icons/turf/damaged.dmi'
	smooth_icon = 'monkestation/code/modules/map_gen_expansions/icons/turfs/floors/mushroom.dmi'
	dig_result = /obj/item/food/grown/ash_flora
	light_outer_range = 2
	light_power = 0.50
	light_color = COLOR_VERY_LIGHT_GRAY
	changes_icon = FALSE

/turf/open/misc/asteroid/forest/mushroom/blue
	icon_state = "mushroom_blue"
	base_icon_state = "mushroom_blue"
	smooth_icon = 'monkestation/code/modules/map_gen_expansions/icons/turfs/floors/mushroom_blue.dmi'

/turf/open/misc/asteroid/forest/mushroom/green
	icon_state = "mushroom_green"
	base_icon_state = "mushroom_green"
	smooth_icon = 'monkestation/code/modules/map_gen_expansions/icons/turfs/floors/mushroom_green.dmi'

/turf/open/openspace/forest
	name = "open forest air"
	baseturfs = /turf/open/openspace/forest
	initial_gas_mix = FOREST_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/misc/dirt/forest
	desc = "Hard-packed dirt - much too hard to plant seeds in."
	initial_gas_mix = FOREST_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/baseturf_bottom

/turf/open/misc/sandy_dirt/forest
	initial_gas_mix = FOREST_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/closed/mineral/random/forest
	name = "forest mountainside"
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
	icon_state = "mountainrock"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS
	defer_change = TRUE
	turf_type = /turf/open/misc/dirt/forest
	baseturfs = /turf/open/misc/dirt/forest
	initial_gas_mix = FOREST_DEFAULT_ATMOS
	weak_turf = TRUE

/turf/closed/mineral/random/forest/Change_Ore(ore_type, random = 0)
	. = ..()
	if(mineralType)
		icon = 'icons/turf/walls/icerock_wall.dmi'
		icon_state = "icerock_wall-0"
		base_icon_state = "icerock_wall"
		smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/closed/mineral/random/forest/mineral_chances()
	return list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/diamond = 1,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/iron = 40,
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/silver = 12,
		/obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/uranium = 5,
	)

/turf/open/floor/engine/hull/reinforced/planetary
	desc = "Sturdy exterior hull plating that separates you from the outside world"
	initial_gas_mix = FOREST_DEFAULT_ATMOS

/turf/open/floor/engine/hull/planetary
	desc = "Sturdy exterior hull plating that separates you from the outside world."
	initial_gas_mix = FOREST_DEFAULT_ATMOS

/turf/open/lava/plasma/forest
	initial_gas_mix = FOREST_DEFAULT_ATMOS
	baseturfs = /turf/open/lava/plasma/forest
	planetary_atmos = TRUE

	icon = 'monkestation/code/modules/map_gen_expansions/icons/turfs/floors/plasma_forest.dmi'
	mask_icon = 'monkestation/code/modules/map_gen_expansions/icons/turfs/floors/plasma_forest_mask.dmi'
	icon_state = "plasma_forest-255"
	mask_state = "plasma_forest-255"
	base_icon_state = "plasma_forest"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_LAVA
	canSmoothWith = SMOOTH_GROUP_FLOOR_LAVA
	underfloor_accessibility = 2 //This avoids strangeness when routing pipes / wires along catwalks over lava

/turf/open/floor/plating/forest
	icon_state = "plating"
	initial_gas_mix = FOREST_DEFAULT_ATMOS
