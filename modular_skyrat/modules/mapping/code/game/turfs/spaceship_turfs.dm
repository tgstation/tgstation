//Re-textures based off the survival pods, without the orange stripe. Now you can re-color them to paint your spaceships!
//(Do faded tones - DONT USE NEON BRIGHT COLORS, I /WILL/ CRY, and your ship will look like literal crap)
//Also make sure you properly var-edit everything hnngh

/turf/closed/wall/mineral/titanium/spaceship
	icon = 'modular_skyrat/modules/mapping/icons/unique/spaceships/shipwalls.dmi'
	icon_state = "ship_walls-0"
	base_icon_state = "ship_walls"
	sheet_type = /obj/item/stack/sheet/spaceship
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SHIPWALLS)
	canSmoothWith = list(SMOOTH_GROUP_SHIPWALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SURVIVAL_TIANIUM_POD, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/wall/mineral/titanium/spaceship/nodiagonal
	icon_state = "map-shuttle_nd"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/mineral/titanium/spaceship/nosmooth
	icon_state = "ship_walls-0"
	smoothing_flags = NONE

/turf/closed/wall/mineral/titanium/spaceship/overspace
	icon_state = "map-overspace"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	fixed_underlay = list("space" = TRUE)

/turf/closed/wall/mineral/titanium/spaceship/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	T.transform = transform
	return T

/turf/closed/wall/mineral/titanium/spaceship/copyTurf(turf/T)
	. = ..()
	T.transform = transform

/obj/structure/window/reinforced/shuttle/spaceship
	name = "spaceship window"
	desc = "A pressure-resistant spaceship window."
	icon = 'modular_skyrat/modules/mapping/icons/unique/spaceships/shipwindows.dmi'
	icon_state = "pod_window-0"
	base_icon_state = "pod_window"
	glass_type = /obj/item/stack/sheet/spaceshipglass
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SHUTTLE_PARTS, SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_SHIPWALLS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE)

/obj/structure/window/reinforced/shuttle/spaceship/tinted
	opacity = TRUE

/obj/structure/window/reinforced/shuttle/spaceship/unanchored
	anchored = FALSE
