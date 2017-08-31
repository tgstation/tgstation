/obj/machinery/ornd
	icon_state = "icons/obj/machines/organResearch.dmi"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/busy = FALSE
	var/hacked = FALSE
	var/disabled = 0
	var/shocked = FALSE
	//var/obj/machinery/computer/ornd/linked_console
	var/obj/item/loaded_item = null

/obj/machinery/ornd/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	do_sparks(5, TRUE, src)
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return 1
	else
		return 0

/obj/machinery/ornd/attack_hand(mob/user)
	if(shocked)
		if(shock(user,50))
			return
	if(panel_open)
		wires.interact(user)


/obj/machinery/ornd/bodyscanner
	name = "\improper ORND body scanner"
	desc = "Scans people to reveal information about all of their organs."
	icon_state = "bodyscanner-0"
	//todo: add circuit

