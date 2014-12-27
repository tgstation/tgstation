/obj/item/mounted/frame/wallmed
	name = "NanoMed frame"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon = 'icons/obj/vending.dmi'
	icon_state = "wallmed_frame0"
	flags = FPRINT | TABLEPASS | CONDUCT

/obj/item/mounted/frame/wallmed/try_build(turf/on_wall, mob/user)
	if(..())
		if (!istype(get_turf(user), /turf/simulated/floor))
			user << "<span class='warning'>[src] cannot be placed on this spot.</span>"
			return
		return 1

/obj/item/mounted/frame/wallmed/do_build(turf/on_wall, mob/user)
	new /obj/machinery/wallmed_frame(get_turf(src), get_dir(user, on_wall))
	qdel(src)