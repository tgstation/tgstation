/obj/structure/blob/special/resource
	name = "resource blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	max_integrity = BLOB_RESOURCE_MAX_HP
	point_return = BLOB_REFUND_RESOURCE_COST
	resistance_flags = LAVA_PROOF
	var/resource_delay = 0

/obj/structure/blob/special/resource/scannerreport()
	return "Gradually supplies the blob with resources, increasing the rate of expansion."

/obj/structure/blob/special/resource/creation_action()
	if(overmind)
		overmind.resource_blobs += src

/obj/structure/blob/special/resource/Destroy()
	if(overmind)
		overmind.resource_blobs -= src
	return ..()

/obj/structure/blob/special/resource/Be_Pulsed()
	. = ..()
	if(resource_delay > world.time)
		return
	flick("blob_resource_glow", src)
	if(overmind)
		overmind.add_points(BLOB_RESOURCE_GATHER_AMOUNT)
		resource_delay = world.time + BLOB_RESOURCE_GATHER_DELAY + overmind.resource_blobs.len * BLOB_RESOURCE_GATHER_ADDED_DELAY //4 seconds plus a quarter second for each resource blob the overmind has
	else
		resource_delay = world.time + BLOB_RESOURCE_GATHER_DELAY
