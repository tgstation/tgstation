// APC HULL
/obj/item/wallframe/apc
	name = "\improper APC frame"
	desc = "Used for repairing or building APCs."
	icon_state = "apc"
	result_path = /obj/machinery/power/apc/auto_name

/obj/item/wallframe/apc/try_build(turf/on_wall, user)
	if(!..())
		return
	var/turf/T = get_turf(on_wall) //the user is not where it needs to be.
	var/area/A = get_area(user)
	if(A.apc)
		to_chat(user, span_warning("This area already has an APC!"))
		return //only one APC per area
	if(!A.requires_power)
		to_chat(user, span_warning("You cannot place [src] in this area!"))
		return //can't place apcs in areas with no power requirement
	for(var/obj/machinery/power/terminal/E in T)
		if(E.master)
			to_chat(user, span_warning("There is another network terminal here!"))
			return
		else
			new /obj/item/stack/cable_coil(T, 10)
			to_chat(user, span_notice("You cut the cables and disassemble the unused power terminal."))
			qdel(E)
	return TRUE

/obj/item/wallframe/apc/screwdriver_act(mob/living/user, obj/item/tool)
	//overriding the wallframe parent screwdriver act with this one which allows applying to existing apc frames.

	var/turf/turf = get_step(get_turf(user), user.dir)
	if(iswallturf(turf))
		if(locate(/obj/machinery/power/apc) in get_turf(user))
			var/obj/machinery/power/apc/mounted_apc = locate(/obj/machinery/power/apc) in get_turf(user)
			mounted_apc.wallframe_act(user, src)
			return ITEM_INTERACT_SUCCESS
		turf.item_interaction(user, src)
	return ITEM_INTERACT_SUCCESS
