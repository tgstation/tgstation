/obj/item/mounted/frame/intercom
	name = "Intercom frame"
	desc = "Used for repairing or building intercoms"
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom-frame"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_type=RECYK_METAL

/obj/item/mounted/frame/intercom/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/turf_loc = get_turf(user)
		var/area/A = turf_loc.loc
		if (!istype(turf_loc, /turf/simulated/floor))
			user << "\red Intercom cannot be placed on this spot."
			return
		if (A.requires_power == 0 || A.name == "Space")
			user << "\red Intercom cannot be placed in this area."
			return
		return 1

/obj/item/mounted/frame/intercom/do_build(turf/on_wall, mob/user)
	new /obj/item/device/radio/intercom(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)