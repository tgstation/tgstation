/obj/item/mounted/frame/light_switch
	name = "Light Switch Frame"
	desc = "Wire it up to a wall to create new light switches"
	icon = 'icons/obj/power.dmi'
	icon_state = "light-p"
	flags = FPRINT
	w_type=2*RECYK_METAL
	mount_reqs = list("nospace", "simfloor")

/obj/item/mounted/frame/light_switch/do_build(turf/on_wall, mob/user)
	new /obj/machinery/light_switch(get_turf(src), get_dir(user, on_wall), 0)
	qdel(src)
