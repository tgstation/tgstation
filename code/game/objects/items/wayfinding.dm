/obj/machinery/pinpointer_dispenser
	name = "wayfinding pinpointer dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticketmachine"
	desc = "Having trouble finding your way? This machine dispenses pinpointers that point to common locations."
	density = FALSE
	layer = HIGH_OBJ_LAYER
	pixel_y = 32
	var/list/obj/item/pinpointer/wayfinding/pinpointers = list()

/obj/machinery/pinpointer_dispenser/attack_hand(mob/living/carbon/user)
	if(user.name in pinpointers)
		to_chat(user, "<span class='warning'>There's already a pinpointer registered to [user.name]!</span>")
		return

	to_chat(user, "<span class='notice'>You take a pinpointer from [src].</span>")

	var/obj/item/pinpointer/wayfinding/P = new /obj/item/pinpointer/wayfinding(get_turf(src))
	user.put_in_hands(P)
	P.owner = user.name
	pinpointers[user.name] = P

/obj/item/pinpointer/wayfinding //For new players or new stations to help players find their way around
	name = "wayfinding pinpointer"
	desc = "A handheld tracking device that points to useful places."
	icon_state = "pinpointer_crew"
	var/owner = null
	var/list/beacons = list()

/obj/item/pinpointer/wayfinding/attack_self(mob/living/user)
	if(active)
		toggle_on()
		user.visible_message("<span class='notice'>[user] deactivates [user.p_their()] pinpointer.</span>", "<span class='notice'>You deactivate your pinpointer.</span>")
		return

	if (!owner)
		owner = user.name
	else if(owner != user.name)
		to_chat(user, "<span class='notice'>The pinpointer doesn't respond. It seems to only recognise its owner.</span>")
		return

	if(beacons.len)
		beacons.Cut()
	for(var/obj/machinery/navbeacon/B in GLOB.wayfindingbeacons)
		beacons[B.codes["wayfinding"]] = B

	if(!beacons.len)
		user.visible_message("<span class='notice'>[user]'s pinpointer fails to detect a signal.</span>", "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "", "Pinpoint") in sortNames(beacons)
	if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
		return

	target = beacons[A]
	toggle_on()
	user.visible_message("<span class='notice'>[user] activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You activate your pinpointer.</span>")

/obj/item/pinpointer/wayfinding/examine(mob/user)
	. = ..()
	var/msg = "Its tracking indicator reads "
	if(target)
		var/obj/machinery/navbeacon/wayfinding/B  = target
		msg += "\"[B.codes["wayfinding"]]\"."
	else
		msg = "Its tracking indicator is blank."
	if(owner)
		msg += " It belongs to [owner]."
	. += msg

/obj/item/pinpointer/wayfinding/scan_for_target()
	if(!target) //target can be set to null from above code, or elsewhere
		active = FALSE

/obj/machinery/navbeacon/wayfinding
	name = "wayfinding beacon"
	desc = "A beacon used by wayfinding pinpointers."

/obj/machinery/navbeacon/wayfinding/Initialize()
	if(!location)
		location = get_area(src)
	codes_txt = "wayfinding=[location]"
	..()

/obj/machinery/navbeacon/wayfinding/medical
	location = "Medbay"

/obj/machinery/navbeacon/wayfinding/medical/morgue
	location = "Morgue"

/obj/machinery/navbeacon/wayfinding/science
	location = "Research and Development"

/obj/machinery/navbeacon/wayfinding/command/hop
	location = "Head of Personnel's Office"

/obj/machinery/navbeacon/wayfinding/shuttle/escape
	location = "Escape Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/shuttle/arrival
	location = "Arrival Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/shuttle/publicmining
	location = "Public Mining Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/public/tools
	location = "Primary Tool Storage"

/obj/machinery/navbeacon/wayfinding/public/tools/auxiliary
	location = "Auxiliary Tool Storage"

