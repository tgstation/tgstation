/obj/item/mounted/frame/newscaster
	name = "Unhinged Newscaster"
	desc = "The difference between an unhinged newscaster and a journalist is that one of them is actually crazy."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_assembly"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")

/obj/item/mounted/frame/newscaster/do_build(turf/on_wall, mob/user)
	new /obj/machinery/newscaster(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
