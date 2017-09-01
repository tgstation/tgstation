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
	var/obj/machinery/computer/orndconsole/linked_console

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

/obj/machinery/ornd/attackby(obj/item/W, mob/user)
	var/obj/item/screwdriver/S = W
	if(istype(S))
		default_deconstruction_screwdriver()
		update_icon()

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
	name = "body scanner"
	desc = "A machine that scans people to reveal all the organs in their body."
	icon_state = "bodyscanner"
	//todo: add circuit
	occupant_typecache = list(/mob/living/carbon/human)
	var/list/scannedOrgans = list()

/obj/machinery/ornd/bodyscanner/Initialize()
	. = ..()
	open_machine()
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
		icon_state = initial(icon_state)+ "_closed_scanning"
		return

	icon_state = initial(icon_state)+ "[state_open ? "" : "_closed_empty"]"

/obj/machinery/ornd/bodyscanner/power_change()
	..()
	update_icon()

/////////////////////
//ORGAN SYNTHESIZER//
/////////////////////
#define ORGANFILE 'icons/obj/surgery.dmi'
/obj/machinery/ornd/orgsynth
	name = "organ synthesizer"
	desc = "A machine that uses synthflesh to create artificial organs."
	icon_state = "orgsynth"
	var/running
	var/obj/item/organ/synth
	//22

/obj/machinery/ornd/orgsynth/Initialize()
	.=..()
	update_icon()

/obj/machinery/ornd/orgsynth/update_icon()
	cut_overlays()

	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)
		return

	if((stat & MAINT) || panel_open)
		add_overlay("[icon_state]-panel")
		return

	if(!running)
		add_overlay("orgsynth_glass_off")
		icon_state = initial(icon_state)+ "_on"
		return

	debugoverlay()
	var/image/organlay = image(ORGANFILE, synth.icon_state)
	var/image/glass = image(icon, "orgsynth_glass_on")
	glass.alpha = 128
	organlay.pixel_x = 6
	organlay.transform /= 2
	add_overlay(organlay)
	add_overlay(glass)
	icon_state = initial(icon_state)+ "_running"

/obj/machinery/ornd/orgsynth/power_change()
	..()
	update_icon()

/obj/machinery/ornd/orgsynth/proc/debugoverlay()
	synth = new /obj/item/organ/liver

#undef ORGANFILE

////////////////////
//ORGAN RESEARCHER//
////////////////////

/obj/machinery/ornd/organres
	name = "organ researcher"
	desc = "A machine used to research organs."
	icon_state = "organres"
	var/running

/obj/machinery/ornd/organres/Initialize()
	.=..()
	update_icon()

/obj/machinery/ornd/organres/power_change()
	..()
	update_icon()

/obj/machinery/ornd/organres/update_icon()
	cut_overlays()

	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)
		return

	if((stat & MAINT) || panel_open)
		add_overlay("organres-panel")
		return

	if(!running)
		icon_state = initial(icon_state)+ "_on"
		return

	icon_state = initial(icon_state)+ "_running"