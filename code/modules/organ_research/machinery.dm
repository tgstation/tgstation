/obj/machinery/ornd
	icon = 'icons/obj/machines/organResearch.dmi'
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/busy = FALSE
	var/hacked = FALSE
	var/disabled = 0
	var/shocked = FALSE
	//var/obj/machinery/computer/ornd/linked_console
	var/obj/item/loaded_item = null
	var/panel_open

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

/obj/machinery/ornd/bodyscanner
	name = "\improper ORND body scanner"
	desc = "Scans people to reveal information about all of their organs."
	icon_state = "bodyscanner"
	//todo: add circuit
	var/isopen
	var/mob/living/carbon/human/occupant

/obj/machinery/ornd/bodyscanner/Initialize()
	.=..()
	update_icon()

/obj/machinery/ornd/bodyscanner/relaymove(mob/user as mob)
	open_machine()
	return

/obj/machinery/ornd/bodyscanner/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>The maintenance panel must be closed before use.</span>")
		return

	if(isopen)
		isopen = FALSE
		close_machine()
		return
	isopen = TRUE
	open_machine()

/obj/machinery/ornd/bodyscanner/attack_hand(mob/user)
	..()
	toggle_open(user)

/obj/machinery/ornd/bodyscanner/update_icon()
	cut_overlays()
	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "-0" : "")
		return

	if((stat & MAINT) || panel_open)
		add_overlay("[icon_state]-panel")
		return

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state)+ "-2"
		return

	//running
	icon_state = initial(icon_state)+ (state_open ? "-1" : "")

