#define SNAIL_MOVEMENT_DISTANCE 5
#define SNAIL_MOVEMENT_TIME 10 SECONDS

/obj/effect/overlay/vis_effect/snail
	name = "snail"
	vis_flags = VIS_INHERIT_PLANE
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "snail_hydrotray"
	///are we currently walking?
	var/is_waddling = FALSE

/obj/effect/overlay/vis_effect/snail/proc/handle_animation()
	if(is_waddling)
		return
	is_waddling = TRUE
	var/movement_direction = pixel_x >= 0 ? -1 : 1
	transform = transform.Scale(-1, 1) //face the other direction
	animate(src, pixel_x = movement_direction * SNAIL_MOVEMENT_DISTANCE, time = SNAIL_MOVEMENT_TIME)
	addtimer(VARSET_CALLBACK(src, is_waddling, FALSE), SNAIL_MOVEMENT_TIME)

#undef SNAIL_MOVEMENT_DISTANCE
#undef SNAIL_MOVEMENT_TIME
