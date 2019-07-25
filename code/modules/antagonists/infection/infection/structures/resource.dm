/*
	Creates infectionm points for the overmind
*/

/obj/structure/infection/resource
	name = "resource infection"
	desc = "A thin spire of slightly swaying tendrils."
	icon = 'icons/mob/infection/crystaline_infection_medium.dmi'
	icon_state = "crystalresource-layer"
	pixel_x = -16
	pixel_y = -8
	max_integrity = 60
	point_return = 5
	build_time = 50
	upgrade_subtype = /datum/infection_upgrade/resource
	// delay in resource gain
	var/resource_delay = 0
	// the amount that this resource gains to its point return every time it pulses
	var/point_return_gain = 0

/obj/structure/infection/resource/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/infection/resource/creation_action()
	if(overmind)
		overmind.resource_infection += src

/obj/structure/infection/resource/Destroy()
	if(overmind)
		overmind.resource_infection -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/resource/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/resource_base = mutable_appearance('icons/mob/infection/crystaline_infection_medium.dmi', "crystalresource-base")
	underlays += resource_base

/obj/structure/infection/resource/Be_Pulsed()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("crystalresource-layer-on", src)
	if(overmind)
		overmind.add_points(1)
	point_return = min(point_return + point_return_gain, 100)
	resource_delay = world.time + (overmind ? 40 + overmind.resource_infection.len * 2.5 : 40)
