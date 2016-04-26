/obj/item/mounted/frame/intercom
	name = "Intercom frame"
	desc = "Used for repairing or building intercoms"
	icon = 'icons/obj/radio.dmi'
	icon_state = "intercom-frame"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")

/obj/item/mounted/frame/intercom/do_build(turf/on_wall, mob/user)
	new /obj/item/device/radio/intercom(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
