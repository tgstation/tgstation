/obj/structure/infection/resource
	name = "resource infection"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	max_integrity = 60
	point_return = 5
	var/resource_delay = 0
	var/set_delay = 40
	var/produced = 1 // points produced
	upgrade_types = list(/datum/component/infection/upgrade/structure/resource/production_rate,
						 /datum/component/infection/upgrade/structure/resource/storage_unit)

/obj/structure/infection/resource/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/infection/resource/creation_action()
	if(overmind)
		overmind.resource_infection += src

/obj/structure/infection/resource/Destroy()
	if(overmind)
		overmind.resource_infection -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/resource/Life()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	if(overmind)
		overmind.add_points(produced)
	resource_delay = world.time + set_delay
	SEND_SIGNAL(src, COMSIG_INFECTION_LIFE_TICK)
