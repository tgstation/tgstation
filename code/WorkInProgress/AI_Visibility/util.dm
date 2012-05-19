

#define MINIMAP_UPDATE_DELAY 1200

/turf
	var/image/obscured
	var/image/dim

/turf/proc/visibilityChanged()
	cameranet.updateVisibility(src)

/turf/New()
	..()
	cameranet.updateVisibility(src)

/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..(need_rebuild)
	cameranet.updateVisibility(loc)

/obj/machinery/camera/New()
	..()
	cameranet.addCamera(src)

/obj/machinery/camera/Del()
	cameranet.removeCamera(src)
	..()

/obj/machinery/camera/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	. = ..(W, user)
	if(istype(W, /obj/item/weapon/wirecutters))
		if(status)
			cameranet.addCamera(src)
		else
			cameranet.removeCamera(src)

/proc/checkcameravis(atom/A)
	for(var/obj/machinery/camera/C in view(A,7))
		if(!C.status || C.stat == 2)
			continue
		return 1
	return 0
