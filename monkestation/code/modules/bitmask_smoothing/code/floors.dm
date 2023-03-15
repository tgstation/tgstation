/turf/open/indestructible/hierophant
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/hierophant_floor.dmi'
	smoothing_flags = SMOOTH_CORNERS

/turf/open/chasm
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/chasms.dmi'
	icon_state = "chasms-255"
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)

/turf/open/floor
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_OPEN_FLOOR, SMOOTH_GROUP_TURF_OPEN)

/turf/open/floor/bamboo
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/bamboo_mat.dmi'
	icon_state = "mat-0"
	base_icon_state = "mat"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_BAMBOO_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_BAMBOO_FLOOR)

/turf/open/floor/carpet
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)

/turf/open/floor/carpet/black
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLACK)

/turf/open/floor/carpet/blue
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLUE)

/turf/open/floor/carpet/cyan
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_CYAN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_CYAN)

/turf/open/floor/carpet/green
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_GREEN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GREEN)

/turf/open/floor/carpet/orange
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ORANGE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ORANGE)

/turf/open/floor/carpet/purple
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_PURPLE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_PURPLE)

/turf/open/floor/carpet/red
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_RED)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_RED)

/turf/open/floor/carpet/royalblack
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ROYAL_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLACK)

/turf/open/floor/carpet/royalblue
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ROYAL_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLUE)


/turf/open/floor/carpet/grimy
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet_grimy.dmi'
	icon_state = "carpet_grimy-255"
	base_icon_state = "carpet_grimy"
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GRIMY)

/turf/open/floor/fakepit
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/Chasms.dmi'
	icon_state = "chasms-0"

/turf/open/floor/plating/ashplanet
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/mining.dmi'
	icon_state = "ash"
	base_icon_state = "ash"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/open/floor/plating/ashplanet/ash
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH, SMOOTH_GROUP_CLOSED_TURFS)

/turf/open/floor/plating/ashplanet/wateryrock
	smoothing_flags = NONE

/turf/open/floor/plating/ice/smooth
	icon_state = "ice_turf-255"
	base_icon_state = "ice_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER

/turf/open/floor/plating/snowed/smoothed
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/snow_turf.dmi'
	icon_state = "snow_turf-0"
	base_icon_state = "snow_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_SNOWED)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_SNOWED)

/turf/open/lava/smooth
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/lava.dmi'
	icon_state = "lava-255"
	base_icon_state = "lava"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_LAVA)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_LAVA)

/obj/structure/lattice/clockwork
	icon = 'monkestation/code/modules/bitmask_smoothing/obj/smooth_structures/lattice_clockwork.dmi'
	icon_state = "lattice_clockwork-0"
	base_icon_state = "lattice_clockwork"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_LATTICE, SMOOTH_GROUP_CATWALK, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_CATWALK)

/obj/structure/lattice/catwalk/clockwork
	icon = 'monkestation/code/modules/bitmask_smoothing/obj/smooth_structures/catwalk_clockwork.dmi'
	icon_state = "catwalk_clockwork-0"
	base_icon_state = "catwalk_clockwork"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_LATTICE, SMOOTH_GROUP_CATWALK, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_CATWALK)

/obj/structure/window/reinforced/clockwork/fulltile
	icon = 'monkestation/code/modules/bitmask_smoothing/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE)

/turf/open/floor/holofloor/carpet
	icon = 'monkestation/code/modules/bitmask_smoothing/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)

