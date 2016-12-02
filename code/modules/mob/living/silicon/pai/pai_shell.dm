
/mob/living/silicon/pai/proc/fold_out(force = FALSE)
	if(!canholo && !force)
		src << "<span class='warning'>Your master or another force has disabled your holochassis emitters!</span>"
		return FALSE

	if(src.loc != card)
		src << "<span class='warning'>You are already in your mobile holochassis!</span>"
		return FALSE

	if(emittersemicd)
		src << "<span class='warning'>Error: Holochassis emitters recycling. Please try again later.</span>"
		return FALSE

	emittersemicd = TRUE
	addtimer(src, "emittercool", emittercd)
	canmove = 1
	density = 1

	if(istype(card.loc, /mob/living))
		var/mob/living/L = card.loc
		if(!L.unEquip(card))
			src << "<span class='warning'>Error: Unable to expand to mobile form. Chassis is restrained by some device or person.</span>"
			return 0
		else if(istype(card.loc, /obj/item/device/pda))
			var/obj/item/device/pda/P = card.loc
			holder.pai = null

	src.client.perspective = EYE_PERSPECTIVE
	src.client.eye = src

	var/turf/T = get_turf(card.loc)
	card.loc = T
	src.loc = T
	src.forceMove(T)
	card.forceMove(src)
	card.screen_loc = null
	src.SetLuminosity(0)
	icon_state = "[chassis]"
	src.visible_message("<span class='boldnotice'>[src] folds out its holochassis emitter and forms a holoshell around itself!</span>")

/mob/living/silicon/pai/proc/emittercool()
	emittersemicd = FALSE

/mob/living/silicon/pai/proc/fold_in(force = FALSE)
	emittersemicd = 1
	addtimer(src, "emittercool", emittercd)
	resting = 0
	icon_state = "[chassis]"
	if(src.loc == card)
		src << "<span class='warning'>You are already in your card!</span>"
		return 0
	visible_message("<span class='notice'>[src] deactivates its holochassis emitter and folds back into a compact card!</span>")
	stop_pulling()
	if(src.client)
		src.client.perspective = EYE_PERSPECTIVE
		src.client.eye = card
	card.loc = T
	card.forceMove(T)
	src.loc = card
	src.forceMove(card)
	canmove = 0
	density = 0
	src.SetLuminosity(0)


/*
/mob/living/silicon/pai/verb/fold_up()
	set category = "pAI Commands"
	set name = "Return to Card Form"

	if(stat || sleeping || paralysis || weakened)
		return

	if(src.loc == card)
		src << "\red You are already in your card form!"
		return

	if(world.time <= last_special)
		src << "\red You must wait before returning to your card form!"
		return

	if (emitter_OD)
		var/datum/pai/software/beacon_overcharge/S = new /datum/pai/software/beacon_overcharge
		S.take_overload_damage(src)

	close_up()

/mob/living/silicon/pai/proc/choose_chassis()
	set category = "pAI Commands"
	set name = "Choose Holographic Projection"

	if (src.loc == card)
		src << "\red You must be in your holographic form to choose your projection shape!"
		return

	var/choice
	var/finalized = "No"
	while(finalized == "No" && src.client)

		choice = input(usr,"What would you like to use for your holographic mobility icon? This decision can only be made once.") as null|anything in possible_chassis
		if(!choice) return

		icon_state = possible_chassis[choice]
		finalized = alert("Look at your sprite. Is this what you wish to use?",,"No","Yes")

	chassis = possible_chassis[choice]
	if (choice)
		verbs -= /mob/living/silicon/pai/proc/choose_chassis

/mob/living/silicon/pai/proc/rest_protocol()
	set name = "Activate R.E.S.T Protocol"
	set category = "pAI Commands"

	if(src && istype(src.loc,/obj/item/device/paicard))
		resting = 0
		src << "\blue You spool down the clock on your internal processor for a moment. Ahhh. T h a t ' s  t h e  s t u f f."
	else
		resting = !resting
		icon_state = resting ? "[chassis]_rest" : "[chassis]"
		src << "\blue You are now [resting ? "resting" : "getting up"]"

	canmove = !resting

*/