/// Stairs but they are FAKE and dont have any of the Z-changing behavior. DO NOT MAP THESE NEXT TO REAL STAIRS
/obj/structure/fake_stairs
	name = "stairs"
	icon = 'icons/obj/structures/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE
	move_resist = INFINITY

	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE //one with the floor

MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/fake_stairs)

/obj/structure/fake_stairs/wood
	icon_state = "stairs_wood"

MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/fake_stairs/wood)

/obj/structure/fake_stairs/stone
	icon_state = "stairs_stone"
