/obj/structure/infection/resource
	name = "resource infection"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	max_integrity = 60
	point_return = 15
	var/resource_delay = 0
	var/produced = 1 // points produced

/obj/structure/infection/resource/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/infection/resource/upgrade_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/resource/show_description()
	return

/obj/structure/infection/resource/scannerreport()
	return "Gradually supplies the infection with resources, increasing the rate of expansion."

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
	resource_delay = world.time + 40
