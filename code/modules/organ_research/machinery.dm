/obj/machinery/ornd
	icon = 'icons/obj/machines/organResearch.dmi'
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 300
	var/busy = FALSE
	var/hacked = FALSE
	var/disabled = 0
	var/shocked = FALSE

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
		return //todo

/obj/machinery/ornd/proc/locate_computer(type_)
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		var/C = locate(type_, get_step(src, dir))
		if(C)
			return C
	return null

///////////////
//BODYSCANNER//
//////////////
/obj/machinery/ornd/bodyscanner
	name = "\improper ORND body scanner"
	desc = "Scans people to reveal information about all of their organs."
	icon_state = "bodyscanner"
	//todo: add circuit
	density = FALSE //spawn in the open state
	occupant_typecache = list(/mob/living/carbon/human)
	var/scannedOrgans = list()

/obj/machinery/ornd/bodyscanner/Initialize()
	. = ..()
	update_icon()

/obj/machinery/ornd/bodyscanner/relaymove(mob/user as mob)
	open_machine()
	return

/obj/machinery/ornd/bodyscanner/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>The maintenance panel must be closed before use.</span>")
		return

	if(state_open)
		close_machine()
		if(occupant)
			scannedOrgans = null
			for(var/obj/item/organ/O in occupant.contents)
				if(istype(O))
					scannedOrgans += O
		return
	open_machine()

/obj/machinery/ornd/bodyscanner/attack_hand(mob/user)
	..()
	toggle_open(user)

/obj/machinery/ornd/bodyscanner/update_icon()
	cut_overlays()
	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)
		return

	if((stat & MAINT) || panel_open)
		add_overlay("[icon_state]-panel")
		return

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state)+ "-2"
		return

	icon_state = initial(icon_state)+ "[state_open ? "" : "-1"]"

/obj/machinery/ornd/bodyscanner/power_change()
	..()
	update_icon()

