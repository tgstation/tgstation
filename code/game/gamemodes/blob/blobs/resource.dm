/obj/effect/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	health = 60
	maxhealth = 60
	point_return = 15
	var/resource_delay = 0

/obj/effect/blob/resource/creation_action()
	if(overmind)
		overmind.resource_blobs += src

/obj/effect/blob/resource/Destroy()
	if(overmind)
		overmind.resource_blobs -= src
	return ..()

/obj/effect/blob/resource/Be_Pulsed()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	if(overmind)
		overmind.add_points(1)
		resource_delay = world.time + 40 + overmind.resource_blobs.len * 2.5 //4 seconds plus a quarter second for each resource blob the overmind has
	else
		resource_delay = world.time + 40
