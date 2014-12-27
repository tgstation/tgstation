/obj/item/mounted/frame/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_type=RECYK_METAL


/obj/item/mounted/frame/apc_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/turf_loc = get_turf(user)
		var/area/area_loc = turf_loc.loc
		if (!istype(turf_loc, /turf/simulated/floor))
			user << "\red APC cannot be placed on this spot."
			return
		if (area_loc.requires_power == 0 || area_loc.name == "Space")
			user << "\red APC cannot be placed in this area."
			return
		if (area_loc.get_apc())
			user << "\red This area already has an APC."
			return //only one APC per area
		for(var/obj/machinery/power/terminal/T in turf_loc)
			if (T.master)
				user << "\red There is another network terminal here."
				return
			else
				var/obj/item/weapon/cable_coil/C = new /obj/item/weapon/cable_coil(turf_loc)
				C.amount = 10
				user << "You cut the cables and disassemble the unused power terminal."
				qdel(T)
		return 1
	return

/obj/item/mounted/frame/apc_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/power/apc(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)
