obj/item/mounted/frame/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	flags = FPRINT
	m_amt=2*CC_PER_SHEET_METAL
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/firealarm/do_build(turf/on_wall, mob/user)
	new /obj/machinery/firealarm(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)
