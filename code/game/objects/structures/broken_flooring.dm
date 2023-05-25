
/obj/structure/broken_flooring
	name = "broken tiling"
	desc = "A segment of broken flooring."
	icon = 'icons/obj/brokentiling.dmi'
	icon_state = "corner"
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	plane = FLOOR_PLANE
	layer = CATWALK_LAYER

/obj/structure/broken_flooring/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/broken_flooring/LateInitialize()
	. = ..()
	var/turf/turf = get_turf(src)
	if(!istype(turf, /turf/open/floor/plating)) // Render as trash above the current tile
		plane = GAME_PLANE
		layer = LOW_OBJ_LAYER
		return
	for(var/obj/O in turf)
		if(O.flags_1 & INITIALIZED_1)
			SEND_SIGNAL(O, COMSIG_OBJ_HIDE, UNDERFLOOR_VISIBLE)

/obj/structure/broken_flooring/crowbar_act(mob/living/user, obj/item/I)
	I.play_tool_sound(src, 80)
	to_chat(user, span_notice("You reclaim the floor tile."))
	new /obj/item/stack/tile/iron(get_turf(src))
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/singular, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/pile, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/side, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/corner, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/plating, 0)

/obj/structure/broken_flooring/singular
	icon_state = "singular"

/obj/structure/broken_flooring/pile
	icon_state = "pile"

/obj/structure/broken_flooring/side
	icon_state = "side"

/obj/structure/broken_flooring/corner
	icon_state = "corner"

/obj/structure/broken_flooring/plating
	icon_state = "plating"
