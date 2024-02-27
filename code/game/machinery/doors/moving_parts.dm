/obj/effect/overlay/airlock_part
	anchored = TRUE
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER - 1
	vis_flags = VIS_INHERIT_ID
	var/side_id
	var/open_pixel_x = 0
	var/open_pixel_y = 0
	var/move_start_time = 0 // for opening; closing uses reversed.
	var/move_end_time = 0.5 SECONDS
	var/aperture_angle = 0
	/// The airlock this is a part of
	var/obj/machinery/door/airlock/parent

/obj/effect/overlay/airlock_part/Initialize(mapload, obj/machinery/door/airlock/source_airlock)
	if(isnull(source_airlock))
		return INITIALIZE_HINT_NORMAL
	source_airlock.vis_contents += src
	source_airlock.part_overlays += src
	icon = source_airlock.icon
	icon_state = side_id
	parent = source_airlock
	name = source_airlock.name
	return ..()

/obj/effect/overlay/airlock_part/standard/left
	side_id = "left"
	open_pixel_x = -14

/obj/effect/overlay/airlock_part/standard/right
	side_id = "right"
	open_pixel_x = 13

/obj/effect/overlay/airlock_part/external/top
	side_id = "top"
	open_pixel_y = 16

/obj/effect/overlay/airlock_part/external/bottom
	side_id = "bottom"
	open_pixel_y = -16

/obj/effect/overlay/airlock_part/shuttle/left
	side_id = "left"
	open_pixel_x = -12

/obj/effect/overlay/airlock_part/shuttle/right
	side_id = "right"
	open_pixel_x = 11

/obj/effect/overlay/airlock_part/shuttle/rightu
	side_id = "rightu"
	open_pixel_x = 11

/obj/effect/overlay/airlock_part/pinion/left
	side_id = "left"
	open_pixel_x = -13

/obj/effect/overlay/airlock_part/pinion/right
	side_id = "right"
	open_pixel_x = 13

/obj/effect/overlay/airlock_part/vault/left
	side_id = "left"
	open_pixel_x = -15

/obj/effect/overlay/airlock_part/vault/leftpins
	side_id = "leftpins"
	open_pixel_x = -17

/obj/effect/overlay/airlock_part/vault/right
	side_id = "right"
	open_pixel_x = 13

/obj/effect/overlay/airlock_part/vault/rightpins
	side_id = "rightpins"
	open_pixel_x = 15

/obj/effect/overlay/airlock_part/vault/rightu
	side_id = "rightu"
	open_pixel_x = 13

/obj/effect/overlay/airlock_part/hatch
	aperture_angle = -90

/obj/effect/overlay/airlock_part/hatch/ul
	side_id = "ul"
	open_pixel_x = -15

/obj/effect/overlay/airlock_part/hatch/ur
	side_id = "ur"
	open_pixel_y = 15

/obj/effect/overlay/airlock_part/hatch/dl
	side_id = "dl"
	open_pixel_y = -15

/obj/effect/overlay/airlock_part/hatch/dr
	side_id = "dr"
	open_pixel_x = 15

/obj/effect/overlay/airlock_part/high_security/rightu
	side_id = "rightu"
	open_pixel_x = 14

/obj/effect/overlay/airlock_part/high_security/left
	side_id = "left"
	open_pixel_x = -14

/obj/effect/overlay/airlock_part/high_security/right
	side_id = "right"
	open_pixel_x = 14

/obj/effect/overlay/airlock_part/abductor/p1
	side_id = "p1"
	open_pixel_y = 40

/obj/effect/overlay/airlock_part/abductor/p2
	side_id = "p2"
	open_pixel_y = 24
	move_start_time = 0.2 SECONDS

/obj/effect/overlay/airlock_part/abductor/p3
	side_id = "p3"
	open_pixel_y = -36
	move_start_time = 0.05 SECONDS

/obj/effect/overlay/airlock_part/abductor/p4
	side_id = "p4"
	open_pixel_y = 16
	move_start_time = 0.3 SECONDS

/obj/effect/overlay/airlock_part/abductor/p5
	side_id = "p5"
	open_pixel_y = -40

/obj/effect/overlay/airlock_part/abductor/p6
	side_id = "p6"
	open_pixel_y = 32
	move_start_time = 0.1 SECONDS

/obj/effect/overlay/airlock_part/abductor/p7
	side_id = "p7"
	open_pixel_y = -24
	move_start_time = 0.2 SECONDS

/obj/effect/overlay/airlock_part/multi_tile/left
	side_id = "left"
	open_pixel_x = -21

/obj/effect/overlay/airlock_part/multi_tile/right
	side_id = "right"
	open_pixel_x = 21

/obj/effect/overlay/airlock_part/multi_tile/top
	side_id = "top"
	open_pixel_y = 29

/obj/effect/overlay/airlock_part/tram/rightu
	side_id = "rightu"
	open_pixel_x = 27

/obj/effect/overlay/airlock_part/tram/left
	side_id = "left"
	open_pixel_x = -28

/obj/effect/overlay/airlock_part/tram/right
	side_id = "right"
	open_pixel_x = 27
