/obj/item/mounted/frame/driver_button
	name = "mass driver button frame"
	desc = "Used for repairing or building mass driver buttons"
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt_frame"
	flags = FPRINT
	mount_reqs = list("simfloor")

/obj/item/mounted/frame/driver_button/do_build(turf/on_wall, mob/user)
	new /obj/machinery/driver_button(get_turf(user), get_dir(user, on_wall))
	qdel(src)
