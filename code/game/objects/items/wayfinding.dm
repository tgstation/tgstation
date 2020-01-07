/obj/machinery/pinpointer_dispenser
	name = "wayfinding pinpointer dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticketmachine"
	desc = "Having trouble finding your way? This machine dispenses pinpointers that point to common locations."
	density = FALSE
	layer = HIGH_OBJ_LAYER
	var/list/obj/item/pinpointer/wayfinding/pinpointers = list()
	var/spawn_cooldown = 1200 //deciseconds per person to spawn another pinpointer

/obj/machinery/pinpointer_dispenser/attack_hand(mob/living/carbon/user)
	if(world.time < pinpointers[user.real_name])
		var/secsleft = (pinpointers[user.real_name] - world.time) / 10
		to_chat(user, "<span class='warning'>You need to wait [secsleft/60 > 1 ? "[round(secsleft/60)] minute\s" : "[round(secsleft)] second\s"].</span>")
		return

	to_chat(user, "<span class='notice'>You take a pinpointer from [src].</span>")

	var/obj/item/pinpointer/wayfinding/P = new /obj/item/pinpointer/wayfinding(get_turf(src))
	user.put_in_hands(P)
	P.owner = user.real_name
	pinpointers[user.real_name] = world.time + spawn_cooldown

/obj/item/pinpointer/wayfinding //For new players or new stations to help players find their way around
	name = "wayfinding pinpointer"
	desc = "A handheld tracking device that points to useful places."
	icon_state = "pinpointer_crew"
	var/owner = null
	var/list/beacons = list()

/obj/item/pinpointer/wayfinding/attack_self(mob/living/user)
	if(active)
		toggle_on()
		to_chat(user, "<span class='notice'>You deactivate your pinpointer.</span>")
		return

	if (!owner)
		owner = user.real_name

	if(beacons.len)
		beacons.Cut()
	for(var/obj/machinery/navbeacon/B in GLOB.wayfindingbeacons)
		beacons[B.codes["wayfinding"]] = B

	if(!beacons.len)
		to_chat(user, "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "", "Pinpoint") as null|anything in sortList(beacons)
	if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
		return

	target = beacons[A]
	toggle_on()
	to_chat(user, "<span class='notice'>You activate your pinpointer.</span>")

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
	wayfinding = TRUE

