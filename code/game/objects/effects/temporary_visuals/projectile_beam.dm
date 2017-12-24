/proc/generate_projectile_beam_between_points(datum/point/starting, datum/point/ending, beam_type, color, qdel_in = 5)		//Do not pass z-crossing points as that will not be properly (and likely will never be properly until it's absolutely needed) supported!
	if(!istype(starting) || !istype(ending) || !ispath(beam_type))
		return
	var/datum/point/midpoint = point_midpoint_points(starting, ending)
	var/obj/effect/projectile_beam/PB = new beam_type
	PB.apply_vars(angle_between_points(starting, ending), midpoint.return_px(), midpoint.return_py(), color, pixel_length_between_points(starting, ending) / world.icon_size, midpoint.return_turf(), 0)
	. = PB
	if(qdel_in)
		QDEL_IN(PB, qdel_in)

/obj/effect/projectile_beam
	icon = 'icons/obj/projectiles.dmi'
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	light_power = 1
	light_range = 2
	light_color = "#00ffff"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	flags_1 = ABSTRACT_1
	appearance_flags = 0

/obj/effect/projectile_beam/singularity_pull()
	return

/obj/effect/projectile_beam/singularity_act()
	return

/obj/effect/projectile_beam/proc/scale_to(nx,ny,override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Scale(nx,ny)
	transform = M

/obj/effect/projectile_beam/proc/turn_to(angle,override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Turn(angle)
	transform = M

/obj/effect/projectile_beam/New(angle_override, p_x, p_y, color_override, scaling = 1)
	if(angle_override && p_x && p_y && color_override && scaling)
		apply_vars(angle_override, p_x, p_y, color_override, scaling)
	return ..()

/obj/effect/projectile_beam/proc/apply_vars(angle_override, p_x = 0, p_y = 0, color_override, scaling = 1, new_loc, increment = 0)
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
	appearance = look
	scale_to(1,scaling, FALSE)
	turn_to(angle_override, FALSE)
	if(!isnull(new_loc))	//If you want to null it just delete it...
		forceMove(new_loc)
	for(var/i in 1 to increment)
		pixel_x += round((sin(angle_override)+16*sin(angle_override)*2), 1)
		pixel_y += round((cos(angle_override)+16*cos(angle_override)*2), 1)

/obj/effect/projectile_beam/tracer
	icon_state = "tracer_beam"

/obj/effect/projectile_beam/tracer/aiming
	icon_state = "gbeam"
