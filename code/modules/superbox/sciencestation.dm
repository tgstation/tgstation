// Stable vortex, used for labor camp egress.
/obj/effect/stable_vortex
	name = "teleporter hub"
	desc = "A stabilized fixed-function vortex used for specialized personnel transport situations."
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "tele1"
	density = TRUE
	anchored = TRUE
	light_range = 2
	opacity = 0
	var/dest_x
	var/dest_y

/obj/effect/stable_vortex/singularity_act()
	return

/obj/effect/stable_vortex/singularity_pull()
	return

/obj/effect/stable_vortex/CollidedWith(atom/movable/AM)
	if(!ismob(AM) || !dest_x || !dest_y)
		return
	var/turf/T = locate(dest_x, dest_y, z)
	if (T)
		do_teleport(AM, T, 0)
