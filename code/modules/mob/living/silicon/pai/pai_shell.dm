/*
/mob/living/silicon/pai/proc/fold_out()
	if (!canholo)
		src << "\red Your master has not enabled your external holographic emitters! Ask nicely!"
		return

	if(src.loc != card)
		src << "\red You are already in your holographic form!"
		return

	if(world.time <= last_special)
		src << "\red You must wait before altering your holographic emitters again!"
		return

	last_special = world.time + 200

	canmove = 1
	density = 1

	//I'm not sure how much of this is necessary, but I would rather avoid issues.
	if(istype(card.loc,/mob))
		var/mob/holder = card.loc
		holder.unEquip(card)
	else if(istype(card.loc,/obj/item/device/pda))
		var/obj/item/device/pda/holder = card.loc
		holder.pai = null

	src.client.perspective = EYE_PERSPECTIVE
	src.client.eye = src
	var/turf/T = get_turf(card.loc)
	card.loc = T
	src.loc = T
	src.forceMove(T)

	card.forceMove(src)
	card.screen_loc = null

	src.SetLuminosity(2)
	weather_immunities = list() //remove ash immunity in holoform

	icon_state = "[chassis]"
	if(istype(T)) T.visible_message("With a faint hum, <b>[src]</b> levitates briefly on the spot before adopting its holographic form in a flash of green light.")

/mob/living/silicon/pai/proc/close_up(var/force = 0)

	if (health < 5 && !force)
		src << "<span class='warning'><b>Your holographic emitters are too damaged to function!</b></span>"
		return

	last_special = world.time + 200
	resting = 0
	if(src.loc == card)
		return

	var/turf/T = get_turf(src)
	if(istype(T)) T.visible_message("<b>[src]</b>'s holographic field distorts and collapses, leaving the central card-unit core behind.")

	if (src.client) //god damnit this is going to be irritating to handle for dc'd pais that stay in holoform
		src.stop_pulling()
		src.client.perspective = EYE_PERSPECTIVE
		src.client.eye = card

	//This seems redundant but not including the forced loc setting messes the behavior up.
	card.loc = T
	card.forceMove(T)
	src.loc = card
	src.forceMove(card)
	canmove = 0
	density = 0
	weather_immunities = list("ash")
	src.SetLuminosity(0)
	icon_state = "[chassis]"

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