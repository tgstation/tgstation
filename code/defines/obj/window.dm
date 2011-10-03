/obj/structure/window
	name = "window"
	icon = 'structures.dmi'
	desc = "A window."
	density = 1
	layer = 3.2//Just above doors
	var/health = 14.0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	var/silicate = 0 // number of units of silicate
	var/icon/silicateIcon = null // the silicated icon
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER

// Prefab windows to make it easy...



// Basic

/obj/structure/window/basic
	icon_state = "window"

/obj/structure/window/basic/north
	dir = NORTH

/obj/structure/window/basic/east
	dir = EAST

/obj/structure/window/basic/west
	dir = WEST

/obj/structure/window/basic/south
	dir = SOUTH

/obj/structure/window/basic/northwest
	dir = NORTHWEST

/obj/structure/window/basic/northeast
	dir = NORTHEAST

/obj/structure/window/basic/southwest
	dir = SOUTHWEST

/obj/structure/window/basic/southeast
	dir = SOUTHEAST

// Reinforced

/obj/structure/window/reinforced
	reinf = 1
	icon_state = "rwindow"
	name = "reinforced window"

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	icon_state = "fwindow"
	name = "frosted window"