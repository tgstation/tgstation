/obj/effect/mapping_helpers
	//used for modular maps, if you find this var not working check if its implimented for the helper type your trying to use
	///If set then what dir should we offset our effect by one tile to, effect must be set for each helper type
	var/offset_dir

//mapping helper to set the base_lighting_alpha and base_lighting_color of an area
/obj/effect/area_lighting_helper
	name = "area mapping helper"
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
