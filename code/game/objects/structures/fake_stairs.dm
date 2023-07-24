/// Stairs but they are FAKE and dont have any of the Z-changing behavior. DO NOT MAP THESE NEXT TO REAL STAIRS
/obj/structure/fake_stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE
	move_resist = INFINITY

	plane = FLOOR_PLANE //one with the floor

/obj/structure/fake_stairs/north
	dir = NORTH

/obj/structure/fake_stairs/south
	dir = SOUTH

/obj/structure/fake_stairs/east
	dir = EAST

/obj/structure/fake_stairs/west
	dir = WEST

/obj/structure/fake_stairs/wood
	icon_state = "stairs_wood"

/obj/structure/fake_stairs/wood/north
	dir = NORTH

/obj/structure/fake_stairs/wood/south
	dir = SOUTH

/obj/structure/fake_stairs/wood/east
	dir = EAST

/obj/structure/fake_stairs/wood/west
	dir = WEST

/obj/structure/fake_stairs/stone
	icon_state = "stairs_stone"
