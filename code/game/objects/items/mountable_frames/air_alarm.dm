/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/mounted/frame/alarm_frame
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 2*CC_PER_SHEET_METAL
	melt_temperature = MELTPOINT_STEEL
	w_type = RECYK_METAL

/obj/item/mounted/frame/alarm_frame/try_build(turf/on_wall, mob/user)
	if(..())
		var/turf/turf_loc = get_turf(user)
		var/area/A = turf_loc.loc
		if (!istype(turf_loc, /turf/simulated/floor))
			user << "\red [src] cannot be placed on this spot."
			return
		if (A.requires_power == 0 || A.name == "Space")
			user << "\red [src] cannot be placed in this area."
			return
		return 1

/obj/item/mounted/frame/alarm_frame/do_build(turf/on_wall, mob/user)
	new /obj/machinery/alarm(get_turf(src), get_dir(on_wall, user), 1)
	qdel(src)