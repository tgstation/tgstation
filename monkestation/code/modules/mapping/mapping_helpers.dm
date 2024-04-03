/obj/effect/mapping_helpers
	//used for modular maps, if you find this var not working check if its implimented for the helper type your trying to use
	///If set then what dir should we offset our effect by one tile to, effect must be set for each helper type
	var/offset_dir

//mapping helper to set the base_lighting_alpha and base_lighting_color of an area
/obj/effect/area_lighting_helper
	name = "area lighting helper"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	plane = POINT_PLANE
	///What do we want to set lighting level to
	var/set_alpha = 200
	///What do we want to set the color to
	var/set_color = COLOR_WHITE

/obj/effect/area_lighting_helper/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/area_lighting_helper/LateInitialize()
	var/area/our_area = get_area(src)
	our_area?.set_base_lighting(set_color, set_alpha)
	qdel(src)

/obj/effect/area_lighting_helper/max_alpha
	set_alpha = 255

/obj/effect/area_lighting_helper/max_alpha_blue
	set_color = COLOR_BLUE_LIGHT
	set_alpha = 255

//mapping helper to set the requires_power var of an area
/obj/effect/area_power_helper
	name = "area power helper"
	icon = 'icons/mob/huds/hud.dmi'
	icon_state = "electrified"
	plane = POINT_PLANE
	///what we requires_power to
	var/set_state = FALSE

/obj/effect/area_power_helper/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/area_power_helper/LateInitialize()
	var/area/our_area = get_area(src)
	our_area?.requires_power = set_state
	qdel(src)

/obj/effect/area_power_helper/requires_power
	set_state = TRUE

/obj/effect/mapping_helpers/airlock/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return

	var/turf/spot = (offset_dir ? get_step(src, offset_dir) : loc)
	if(!try_for_airlock(spot) && !try_for_windoor(spot))
		log_mapping("[src] failed to find an airlock at [AREACOORD(src)]")

/obj/effect/mapping_helpers/airlock/proc/try_for_airlock(turf/spot)
	. = FALSE
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in spot
	if(!QDELETED(airlock))
		payload(airlock)
		return TRUE

/obj/effect/mapping_helpers/airlock/proc/try_for_windoor(turf/spot)
	. = FALSE
	var/obj/machinery/door/window/windoor = locate(/obj/machinery/door/window) in spot
	if(!QDELETED(windoor))
		payload_windoor(windoor)
		return TRUE

/obj/effect/mapping_helpers/airlock/proc/payload_windoor(obj/machinery/door/window/windoor)
	return
