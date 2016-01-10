/obj/effect/blob/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	health = 60
	maxhealth = 60
	point_return = 15
	var/resource_delay = 0

/obj/effect/blob/resource/Be_Pulsed()
	if(resource_delay > world.time)
		return 0
	flick("factory_glow", src)
	resource_delay = world.time + 45 // 4 and a half seconds
	if(overmind)
		overmind.add_points(1)
	. = ..()
