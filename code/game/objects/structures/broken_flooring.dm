/obj/structure/broken_flooring
	name = "broken tiling"
	desc = "A segment of broken flooring."
	icon = 'icons/obj/fluff/brokentiling.dmi'
	icon_state = "corner"
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	plane = FLOOR_PLANE
	layer = CATWALK_LAYER
	/// do we always have FLOOR_PLANE even if we arent on plating?
	var/always_floorplane = FALSE

/obj/structure/broken_flooring/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/broken_flooring/LateInitialize()
	var/turf/turf = get_turf(src)
	if(!isplatingturf(turf) && !always_floorplane) // Render as trash if not on plating
		plane = GAME_PLANE
		layer = LOW_OBJ_LAYER
		return
	for(var/obj/object in turf)
		if(object.flags_1 & INITIALIZED_1)
			SEND_SIGNAL(object, COMSIG_OBJ_HIDE, UNDERFLOOR_VISIBLE)
			CHECK_TICK

/obj/structure/broken_flooring/crowbar_act(mob/living/user, obj/item/I)
	I.play_tool_sound(src, 80)
	balloon_alert(user, "tile reclaimed")
	new /obj/item/stack/tile/iron(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/broken_flooring/singular
	icon_state = "singular"

/obj/structure/broken_flooring/singular/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/pile
	icon_state = "pile"

/obj/structure/broken_flooring/pile/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/side
	icon_state = "side"

/obj/structure/broken_flooring/side/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/corner
	icon_state = "corner"

/obj/structure/broken_flooring/corner/always_floorplane
	always_floorplane = TRUE

/obj/structure/broken_flooring/plating
	icon_state = "plating"

/obj/structure/broken_flooring/plating/always_floorplane
	always_floorplane = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/singular, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/pile, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/side, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/corner, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/plating, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/singular/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/pile/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/side/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/corner/always_floorplane, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/broken_flooring/plating/always_floorplane, 0)
