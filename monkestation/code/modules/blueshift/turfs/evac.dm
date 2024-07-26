/turf/open/floor/iron/shuttle/evac
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/evac_shuttle.dmi'
	icon_state = "floor"

/turf/open/floor/iron/shuttle/evac/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/shuttle/arrivals
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/wagon.dmi'
	icon_state = "floor"

/turf/open/floor/iron/shuttle/arrivals/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white/textured_large/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/catwalk_floor/iron/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/catwalk_floor/iron_white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/catwalk_floor/iron_dark/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/catwalk_floor/iron_dark/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/catwalk_floor/flat_white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/catwalk_floor/titanium/Airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/catwalk_floor/iron_smooth/airless
	initial_gas_mix = AIRLESS_ATMOS

/*
/area/shuttle
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
 */

/obj/docking_port/mobile/arrivals

/turf/closed/wall/mineral/titanium/shuttle_wall
	name = "shuttle wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'monkestation/code/modules/blueshift/icons/pod.dmi'
	icon_state = ""
	base_icon_state = ""
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null

/turf/closed/wall/mineral/titanium/shuttle_wall/AfterChange(flags, oldType)
	. = ..()
	// Manually add space underlay, in a way similar to turf_z_transparency,
	// but we actually show the old content of the same z-level, as desired for shuttles

	var/turf/underturf_path

	// Grab previous turf icon
	if(!ispath(oldType, /turf/closed/wall/mineral/titanium/shuttle_wall))
		underturf_path = oldType
	else
		// Else use whatever SSmapping tells us, like transparent open tiles do
		underturf_path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space

	var/mutable_appearance/underlay_appearance = mutable_appearance(
		initial(underturf_path.icon),
		initial(underturf_path.icon_state),
		offset_spokesman = src,
		layer = TURF_LAYER - 0.02,
		plane = initial(underturf_path.plane))
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	underlays += underlay_appearance

/turf/closed/wall/mineral/titanium/shuttle_wall/window
	opacity = FALSE

/*
 *	POD
 */

/turf/closed/wall/mineral/titanium/shuttle_wall/pod
	icon = 'monkestation/code/modules/blueshift/icons/pod.dmi'

/turf/closed/wall/mineral/titanium/shuttle_wall/window/pod
	icon = 'monkestation/code/modules/blueshift/icons/pod.dmi'
	icon_state = "3,1"

/*
 *	FERRY
 */

/turf/closed/wall/mineral/titanium/shuttle_wall/ferry
	icon = 'monkestation/code/modules/blueshift/icons/erokez.dmi'
	icon_state = "18,2"

/turf/closed/wall/mineral/titanium/shuttle_wall/window/ferry
	icon = 'monkestation/code/modules/blueshift/icons/erokez.dmi'
	icon_state = "18,2"

/turf/open/floor/iron/shuttle/ferry
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/erokez.dmi'
	icon_state = "floor1"

/turf/open/floor/iron/shuttle/ferry/airless
	initial_gas_mix = AIRLESS_ATMOS

/*
 *	EVAC
 */

/turf/closed/wall/mineral/titanium/shuttle_wall/evac
	icon = 'monkestation/code/modules/blueshift/icons/evac_shuttle.dmi'
	icon_state = "9,1"

/turf/closed/wall/mineral/titanium/shuttle_wall/window/evac
	icon = 'monkestation/code/modules/blueshift/icons/evac_shuttle.dmi'
	icon_state = "9,1"

/turf/open/floor/iron/shuttle/evac
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/evac_shuttle.dmi'
	icon_state = "floor"

/turf/open/floor/iron/shuttle/evac/airless
	initial_gas_mix = AIRLESS_ATMOS

/*
 *	ARRIVALS
 */

/turf/closed/wall/mineral/titanium/shuttle_wall/arrivals
	icon = 'monkestation/code/modules/blueshift/icons/wagon.dmi'
	icon_state = "3,1"

/turf/closed/wall/mineral/titanium/shuttle_wall/window/arrivals
	icon = 'monkestation/code/modules/blueshift/icons/wagon.dmi'
	icon_state = "3,1"

/turf/open/floor/iron/shuttle/arrivals
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/wagon.dmi'
	icon_state = "floor"

/turf/open/floor/iron/shuttle/arrivals/airless
	initial_gas_mix = AIRLESS_ATMOS

/*
 *	CARGO
 */

/turf/closed/wall/mineral/titanium/shuttle_wall/cargo
	icon = 'monkestation/code/modules/blueshift/icons/cargo.dmi'
	icon_state = "3,1"

/turf/closed/wall/mineral/titanium/shuttle_wall/window/cargo
	icon = 'monkestation/code/modules/blueshift/icons/cargo.dmi'
	icon_state = "3,1"

/turf/open/floor/iron/shuttle/cargo
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/cargo.dmi'
	icon_state = "floor"

/turf/open/floor/iron/shuttle/cargo/airless
	initial_gas_mix = AIRLESS_ATMOS

/*
 *	MINING
 */

/turf/closed/wall/mineral/titanium/shuttle_wall/mining
	icon = 'monkestation/code/modules/blueshift/icons/mining.dmi'

/turf/closed/wall/mineral/titanium/shuttle_wall/window/mining
	icon = 'monkestation/code/modules/blueshift/icons/mining.dmi'

/turf/closed/wall/mineral/titanium/shuttle_wall/mining_large
	icon = 'monkestation/code/modules/blueshift/icons/mining_large.dmi'
	icon_state = "2,2"
	dir = NORTH

/turf/closed/wall/mineral/titanium/shuttle_wall/window/mining_large
	icon = 'monkestation/code/modules/blueshift/icons/mining_large.dmi'
	icon_state = "6,3"
	dir = NORTH

/turf/closed/wall/mineral/titanium/shuttle_wall/mining_labor
	icon = 'monkestation/code/modules/blueshift/icons/mining_labor.dmi'
	icon_state = "4,6"
	dir = NORTH

/turf/closed/wall/mineral/titanium/shuttle_wall/window/mining_labor
	icon = 'monkestation/code/modules/blueshift/icons/mining_labor.dmi'
	icon_state = "4,4"
	dir = NORTH

/*
 *	MINING/RND/EXPLORATION FLOORS
 */

/turf/open/floor/iron/shuttle/exploration
	name = "shuttle floor"
	icon = 'monkestation/code/modules/blueshift/icons/exploration_floor.dmi'
	icon_state = "oside"

/turf/open/floor/iron/shuttle/exploration/uside
	icon_state = "uside"

/turf/open/floor/iron/shuttle/exploration/corner
	icon_state = "corner"

/turf/open/floor/iron/shuttle/exploration/side
	icon_state = "side"

/turf/open/floor/iron/shuttle/exploration/corner_invcorner
	icon_state = "corner_icorner"

/turf/open/floor/iron/shuttle/exploration/adjinvcorner
	icon_state = "adj_icorner"

/turf/open/floor/iron/shuttle/exploration/oppinvcorner
	icon_state = "opp_icorner"

/turf/open/floor/iron/shuttle/exploration/invertcorner
	icon_state = "icorner"

/turf/open/floor/iron/shuttle/exploration/doubleinvertcorner
	icon_state = "double_icorner"

/turf/open/floor/iron/shuttle/exploration/tripleinvertcorner
	icon_state = "tri_icorner"

/turf/open/floor/iron/shuttle/exploration/doubleside
	icon_state = "double_side"

/turf/open/floor/iron/shuttle/exploration/quadinvertcorner
	icon_state = "4icorner"

/turf/open/floor/iron/shuttle/exploration/doubleinvertcorner_side
	icon_state = "double_icorner_side"

/turf/open/floor/iron/shuttle/exploration/invertcorner_side
	icon_state = "side_icorner"

/turf/open/floor/iron/shuttle/exploration/invertcorner_side_flipped
	icon_state = "side_icorner_f"

/turf/open/floor/iron/shuttle/exploration/blanktile
	icon_state = "blank"

/turf/open/floor/iron/shuttle/exploration/flat
	icon_state = "flat"

/turf/open/floor/iron/shuttle/exploration/flat/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/shuttle/exploration/textured_flat
	icon_state = "flattexture"

/turf/open/floor/iron/shuttle/exploration/textured_flat/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/shuttle/exploration/equipmentrail1
	icon_state = "rail1"

/turf/open/floor/iron/shuttle/exploration/equipmentrail2
	icon_state = "rail2"

/turf/open/floor/iron/shuttle/exploration/equipmentrail3
	icon_state = "rail3"

/turf/open/floor/iron/shuttle/exploration/hazard
	icon_state = "hazard"

/turf/open/floor/iron/shuttle/exploration/hazard/airless
	initial_gas_mix = AIRLESS_ATMOS

//Re-textures based off the survival pods, without the orange stripe. Now you can re-color them to paint your spaceships!
//(Do faded tones - DONT USE NEON BRIGHT COLORS, I /WILL/ CRY, and your ship will look like literal crap)
//Also make sure you properly var-edit everything hnngh

/turf/closed/wall/mineral/titanium/spaceship
	icon = 'monkestation/code/modules/blueshift/icons/unique/spaceships/shipwalls.dmi'
	icon_state = "ship_walls-0"
	base_icon_state = "ship_walls"
	//sheet_type = /obj/item/stack/sheet/spaceship
	smoothing_groups = SMOOTH_GROUP_SHIPWALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_SHIPWALLS + SMOOTH_GROUP_SURVIVAL_TITANIUM_POD

/turf/closed/wall/mineral/titanium/spaceship/nodiagonal
	icon_state = "map-shuttle_nd"
	smoothing_flags = SMOOTH_BITMASK

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
	icon = 'monkestation/code/modules/blueshift/icons/unique/spaceships/shipwindows.dmi'
	icon_state = "pod_window-0"
	base_icon_state = "pod_window"
	//glass_type = /obj/item/stack/sheet/spaceshipglass
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE + SMOOTH_GROUP_SHIPWALLS
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	obj_flags = CAN_BE_HIT

/obj/structure/window/reinforced/shuttle/spaceship/tinted
	opacity = TRUE

/obj/structure/window/reinforced/shuttle/spaceship/unanchored
	anchored = FALSE

// Used for Ringworm near-station asteroids
/turf/open/misc/asteroid/moon/airless
	initial_gas_mix = AIRLESS_ATMOS
	worm_chance = 0

/turf/closed/mineral/random/stationside/moon
	baseturfs = /turf/open/misc/asteroid/moon/airless

/turf/closed/mineral/random/high_chance/moon
	baseturfs = /turf/open/misc/asteroid/moon/airless

/turf/closed/mineral/random/labormineral/moon
	baseturfs = /turf/open/misc/asteroid/moon/airless

/turf/open/misc/asteroid/moon
	name = "lunar surface"
	baseturfs = /turf/open/misc/asteroid/moon
	icon = 'icons/turf/floors.dmi'
	icon_state = "moon"
	base_icon_state = "moon"
	floor_variance = 40
	dig_result = /obj/item/stack/ore/glass/basalt

/turf/open/misc/asteroid/moon/dug //When you want one of these to be already dug.
	dug = TRUE
	floor_variance = 0
	base_icon_state = "moon_dug"
	icon_state = "moon_dug"

// Put tiles here if you want planet ones!

/turf/open/misc/dirt/planet
	baseturfs = /turf/open/misc/dirt/planet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
// We don't want to create chasms upon destruction, as this is too easy to abuse.
// For some reason, the dirt used Lavaland atmos (OPENTURF_LOW_PRESSURE), this would suck whilst on the planet.

/turf/open/misc/grass/planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/sandy_dirt/planet

/turf/open/misc/grass/jungle/planet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/sandy_dirt/planet
// We want planetary atmos, but most importantly, to become dirt upon destruction. Well, dirt, then dirtier dirt.
// Why are we doing this? Grief-proofing. It'd suck if I walked out my house and there was just a space tile and all the air in the city is being sucked in because some smackhead destroyed the ground in the night somehow.

/turf/open/misc/sandy_dirt/planet
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/dirt/planet
