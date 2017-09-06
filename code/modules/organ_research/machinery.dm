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
	var/datum/ornd/refDatum

/obj/machinery/ornd/Initialize()
	.=..()
	refDatum = new /datum/ornd

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

	if(Insert_Item(W, user))
		return 1
	else
		return ..()

/obj/machinery/ornd/proc/Insert_Item(obj/item/I, mob/user)
	return

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
	var/prodcoeff = 1
	var/canBuild = TRUE

	//22

/obj/machinery/ornd/orgsynth/Initialize()
	.=..()
	create_reagents(0)
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

/obj/machinery/ornd/orgsynth/proc/build_organ(var/datum/ornd/target)
	if(istype(target))
		synth = target
		//if(reagents.has_reagent("synthflesh")
		running = TRUE

	update_icon()

/obj/machinery/ornd/orgsynth/process()
	if(running && reagents.has_reagent("synthflesh"))
		reagents.remove_reagent("synthflesh", 1*prodcoeff)

#undef ORGANFILE

////////////////////
//ORGAN RESEARCHER//
////////////////////

/obj/machinery/ornd/organres
	name = "organ researcher"
	desc = "A machine used to research organs."
	icon_state = "organres"
	var/running
	var/obj/item/organ/scanning
	var/obj/item/organ/heldorgan
	var/datum/ornd/scandatum
	var/scan_coeff = 1

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

/obj/machinery/ornd/organres/proc/donescan()
	running = FALSE
	update_icon()
	scanning.forceMove(get_turf(src))

/obj/machinery/ornd/organres/proc/scan()
	running = TRUE
	for(var/obj/item/organ/O in contents)
		for(var/datum/organ/DO in refDatum.datumOrgans)//is this organ referenced as a product of any datum organ?
			if(istype(DO))
				if(istype(O, DO.product))
					scanning = O
					return scanning
	update_icon()
	addtimer(CALLBACK(src, .proc/donescan),32*scan_coeff)

/obj/machinery/ornd/organres/Insert_Item(obj/item/W, mob/user)
	if(user.a_intent != INTENT_HARM)
		. = 1

	if(!user.drop_item())
		to_chat(user, "<span class='warning'>\The [W] is stuck to your hand, you cannot put it in the [src.name]!</span>")
		return

	var/obj/item/organ/O = W
	if(!istype(O))
		return
	if(running)
		return

	heldorgan = O
	O.forceMove(src)

/obj/machinery/ornd/organres/attack_hand(mob/user)
	if(heldorgan)
		heldorgan.forceMove(get_turf(loc))
		running = FALSE