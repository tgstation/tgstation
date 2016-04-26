/obj/item/mounted/frame/soundsystem
	name = "sound system frame"
	desc = "Used for repairing or building sound systems"
	icon = 'icons/obj/radio.dmi'
	icon_state = "wallradio"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")

/obj/item/mounted/frame/soundsystem/do_build(turf/on_wall, mob/user)
	new /obj/machinery/media/receiver/boombox/wallmount(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
