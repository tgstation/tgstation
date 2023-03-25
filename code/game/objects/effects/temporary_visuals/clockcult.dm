//temporary visual effects(/obj/effect/temp_visual) used by clockcult stuff
/obj/effect/temp_visual/ratvar
	name = "ratvar's light"
	icon = 'massmeta/icons/effects/clockwork_effects.dmi'
	duration = 8
	randomdir = 0
	layer = ABOVE_NORMAL_TURF_LAYER

/obj/effect/temp_visual/ratvar/door
	icon_state = "ratvardoorglow"
	layer = CLOSED_DOOR_LAYER //above closed doors

/obj/effect/temp_visual/ratvar/door/window
	icon_state = "ratvarwindoorglow"
	layer = ABOVE_WINDOW_LAYER

/obj/effect/temp_visual/ratvar/beam
	icon_state = "ratvarbeamglow"

/obj/effect/temp_visual/ratvar/beam/door
	layer = CLOSED_DOOR_LAYER

/obj/effect/temp_visual/ratvar/beam/grille
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/itemconsume
	layer = HIGH_OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/falsewall
	layer = OBJ_LAYER

/obj/effect/temp_visual/ratvar/beam/catwalk
	layer = LATTICE_LAYER

/obj/effect/temp_visual/ratvar/wall
	icon_state = "ratvarwallglow"

/obj/effect/temp_visual/ratvar/wall/false
	layer = OBJ_LAYER

/obj/effect/temp_visual/ratvar/floor
	icon_state = "ratvarfloorglow"

/obj/effect/temp_visual/ratvar/floor/catwalk
	layer = LATTICE_LAYER

/obj/effect/temp_visual/ratvar/window
	icon_state = "ratvarwindowglow"
	layer = ABOVE_OBJ_LAYER

/obj/effect/temp_visual/ratvar/window/single
	icon_state = "ratvarwindowglow_s"

/obj/effect/temp_visual/ratvar/gear
	icon_state = "ratvargearglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/grille
	icon_state = "ratvargrilleglow"
	layer = BELOW_OBJ_LAYER

/obj/effect/temp_visual/ratvar/grille/broken
	icon_state = "ratvarbrokengrilleglow"

/obj/effect/temp_visual/ratvar/belligerent
	layer = ABOVE_MOB_LAYER
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	icon_state = "belligerent_eye"
	pixel_y = 20
	duration = 20

/obj/effect/temp_visual/ratvar/belligerent_cast/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

/obj/effect/temp_visual/ratvar/mending_mantra
	layer = ABOVE_MOB_LAYER
	duration = 20
	alpha = 200
	icon_state = "mending_mantra"
	light_range = 1.5
	light_color = "#1E8CE1"

/obj/effect/temp_visual/ratvar/mending_mantra/Initialize(mapload)
	. = ..()
	transform = matrix()*2
	var/matrix/M = transform
	M.Turn(90)
	animate(src, alpha = 20, time = duration, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(src, transform = M, time = duration, flags = ANIMATION_PARALLEL)

/obj/effect/temp_visual/ratvar/ocular_warden
	name = "warden's gaze"
	layer = ABOVE_MOB_LAYER
	icon_state = "warden_gaze"
	duration = 3

/obj/effect/temp_visual/ratvar/ocular_warden/Initialize(mapload)
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-10, 10)
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

/obj/effect/temp_visual/ratvar/prolonging_prism
	icon = 'icons/effects/64x64.dmi'
	icon_state = "prismhex1"
	layer = RIPPLE_LAYER
	pixel_y = -16
	pixel_x = -16
	duration = 30

/obj/effect/temp_visual/ratvar/prolonging_prism/Initialize(mapload, set_appearance)
	. = ..()
	if(set_appearance)
		appearance = set_appearance
	animate(src, alpha = 0, time = duration, easing = BOUNCE_EASING)

/obj/effect/temp_visual/ratvar/spearbreak
	icon = 'icons/effects/64x64.dmi'
	icon_state = "ratvarspearbreak"
	layer = BELOW_MOB_LAYER
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/ratvar/geis_binding
	icon_state = "geisbinding"

/obj/effect/temp_visual/ratvar/geis_binding/top
	icon_state = "geisbinding_top"

/obj/effect/temp_visual/ratvar/component
	icon = 'massmeta/icons/obj/clockwork_objects.dmi'
	icon_state = "belligerent_eye"
	layer = ABOVE_MOB_LAYER
	duration = 10

/obj/effect/temp_visual/ratvar/component/Initialize(mapload)
	. = ..()
	transform = matrix()*0.75
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, -2)
	animate(src, pixel_y = pixel_y + 10, alpha = 50, time = 10, easing = EASE_OUT)

/obj/effect/temp_visual/ratvar/component/cogwheel
	icon_state = "vanguard_cogwheel"

/obj/effect/temp_visual/ratvar/component/capacitor
	icon_state = "geis_capacitor"

/obj/effect/temp_visual/ratvar/component/alloy
	icon_state = "replicant_alloy"

/obj/effect/temp_visual/ratvar/component/ansible
	icon_state = "hierophant_ansible"

/obj/effect/temp_visual/steam
	name = "steam"
	desc = "Steam! It's hot. It also serves as a game distribution platform."
	icon_state = "smoke"
	duration = 15

/obj/effect/temp_visual/steam/Initialize(mapload, steam_direction)
	. = ..()
	setDir(steam_direction)
	var/x_offset = 0
	var/y_offset = 0
	switch(dir)
		if(NORTH)
			y_offset = 8
		if(EAST)
			x_offset = 4
			y_offset = 4
		if(SOUTH)
			y_offset = 2
		if(WEST)
			x_offset = -4
			y_offset = 4
	animate(src, pixel_x = x_offset, pixel_y = y_offset, alpha = 50, time = 15)

/obj/effect/temp_visual/steam_release
	name = "all the steam"

/obj/effect/temp_visual/steam_release/Initialize(mapload)
	..()
	for(var/V in GLOB.cardinals)
		var/turf/T = get_step(src, V)
		new/obj/effect/temp_visual/steam(T, V)
	playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 30)
	return INITIALIZE_HINT_QDEL

/obj/effect/temp_visual/ratvar/warp
	name = "spatial distortion"
	icon_state = "teleport"
	layer = ABOVE_MOB_LAYER
