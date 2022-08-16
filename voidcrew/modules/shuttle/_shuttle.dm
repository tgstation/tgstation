/obj/machinery/power/shuttle
	name = "shuttle component"
	desc = "Something for shuttles."
	density = TRUE
	max_integrity = 250
	icon = 'voidcrew/modules/shuttle/icons/shuttle.dmi'
	icon_state = "burst_plasma"
	circuit = /obj/item/circuitboard/machine/shuttle/engine

	var/icon_state_closed = "burst_plasma"
	var/icon_state_open = "burst_plasma_open"
	var/icon_state_off = "burst_plasma_off"

/obj/machinery/power/shuttle/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, tool))
		return TRUE
	return FALSE

/obj/machinery/power/shuttle/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_pry_open(tool))
		return TRUE

	if(!panel_open)
		user.balloon_alert(user, "open panel first!")
		return FALSE
	if(default_deconstruction_crowbar(tool))
		return TRUE
	return FALSE

/obj/machinery/power/shuttle/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!panel_open)
		user.balloon_alert(user, "open panel first!")
		return FALSE
	if(default_change_direction_wrench(user, tool))
		return TRUE
	return FALSE
