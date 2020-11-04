/obj/effect/abstract/ripple
	name = "hyperspace ripple"
	desc = "Something is coming through hyperspace, you can see the \
		visual disturbances. It's probably best not to be on top of these \
		when whatever is tunneling comes through."
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	alpha = 0

	/// The mobile docking_port these ripples were created for
	var/obj/docking_port/mobile/incoming_shuttle

	/// Unset by docking to prevent stray gibbings
	var/can_gib = TRUE

/obj/effect/abstract/ripple/Initialize(mapload, obj/docking_port/mobile/incoming_shuttle, time_left)
	. = ..()
	src.incoming_shuttle = incoming_shuttle

	animate(src, alpha=255, time=time_left)
	addtimer(CALLBACK(src, .proc/set_still_icon), 8, TIMER_CLIENT_TIME)
	addtimer(CALLBACK(src, .proc/actualize), time_left, TIMER_CLIENT_TIME)

/// Switch to non-animating icon
/obj/effect/abstract/ripple/proc/set_still_icon()
	icon_state = "medi_holo_no_anim"

/// Make the ripple dense, and act as a crush for the turf it resides on
/obj/effect/abstract/ripple/proc/actualize()
	density = TRUE
	if(can_gib)
		var/turf/T = get_turf(src)
		T.shuttle_gib(incoming_shuttle)
