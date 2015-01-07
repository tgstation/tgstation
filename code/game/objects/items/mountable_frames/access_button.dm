/obj/item/mounted/frame/access_button
	name = "access button frame"
	desc = "Used for repairing or building airlock access buttons"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_build"
	flags = FPRINT
	mount_reqs = list("simfloor")

/obj/item/mounted/frame/access_button/do_build(turf/on_wall, mob/user)
	new /obj/machinery/access_button(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)
