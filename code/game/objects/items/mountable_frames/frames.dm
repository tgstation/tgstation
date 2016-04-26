/obj/item/mounted/frame
	name = "mountable frame"
	desc = "Place it on a wall."
	flags = FPRINT
	w_type=RECYK_METAL
	var/sheets_refunded = 2
	var/list/mount_reqs = list() //can contain simfloor, nospace. Used in try_build to see if conditions are needed, then met
	var/frame_material = /obj/item/stack/sheet/metal

/obj/item/mounted/frame/attackby(obj/item/weapon/W, mob/user)
	..()
	if (iswrench(W) && sheets_refunded)
		//new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
		var/obj/item/stack/sheet/S = getFromPool(frame_material, get_turf(src))
		S.amount = sheets_refunded
		qdel(src)

/obj/item/mounted/frame/try_build(turf/on_wall, mob/user)
	if(..()) //if we pass the parent tests
		var/turf/turf_loc = get_turf(user)

		if (src.mount_reqs.Find("simfloor") && !istype(turf_loc, /turf/simulated/floor))
			to_chat(user, "<span class='rose'>[src] cannot be placed on this spot.</span>")
			return
		if (src.mount_reqs.Find("nospace") && (areaMaster.requires_power == 0 || isspace(areaMaster)))
			to_chat(user, "<span class='rose'>[src] cannot be placed in this area.</span>")
			return
		return 1
