// APC HULL
/obj/item/wallframe/apc
	name = "\improper APC frame"
	desc = "Used for repairing or building APCs."
	icon_state = "apc"
	result_path = /obj/machinery/power/apc/auto_name

/obj/item/wallframe/apc/try_build(turf/on_wall, user)
	var/turf/T = get_turf(on_wall) //the user is not where it needs to be.
	var/area/A = get_area(user)
	if(A.apc)
		to_chat(user, span_warning("This area already has an APC!"))
		return FALSE //only one APC per area
	if(!A.requires_power || A.always_unpowered)
		to_chat(user, span_warning("You cannot place [src] in this area!"))
		return FALSE //can't place apcs in areas with no power requirement
	for(var/obj/machinery/power/terminal/E in T)
		if(E.master)
			to_chat(user, span_warning("There is another network terminal here!"))
			return FALSE
	return ..()

/obj/item/wallframe/apc/after_attach(obj/machinery/power/apc/attached_to)
	for(var/obj/machinery/power/terminal/E in attached_to.loc)
		attached_to.make_terminal()
		return
