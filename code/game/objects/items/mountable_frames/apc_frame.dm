/obj/item/mounted/frame/apc_frame
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags = FPRINT
	w_type=RECYK_METAL
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/apc_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/turf_loc = get_turf(user)

		if (areaMaster.get_apc())
			user << "<span class='rose'>This area already has an APC.</span>"
			return //only one APC per area
		for(var/obj/machinery/power/terminal/T in turf_loc)
			if (T.master)
				user << "<span class='rose'>There is another network terminal here.</span>"
				return
			else
				var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(turf_loc)
				C.amount = 10
				user << "You cut the cables and disassemble the unused power terminal."
				qdel(T)
		return 1
	return

/obj/item/mounted/frame/apc_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/power/apc(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)
