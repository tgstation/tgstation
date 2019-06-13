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
	var/resource_delay = 0
	var/set_delay = 40
	var/produced = 1 // points produced
	var/point_return_gain = 0
	upgrade_subtype = /datum/infection_upgrade/resource

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

/obj/structure/infection/resource/Life()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	if(overmind)
		overmind.add_points(produced)
	point_return = min(point_return + point_return_gain, 100)
	resource_delay = world.time + set_delay
