/*
	Items, Structures, Machines
*/


//
// Items
//

/obj/item/melee/energy/sword/holographic
	name = "holographic energy sword"
	desc = "May the force be with you. Sorta."
	damtype = STAMINA
	throw_speed = 2
	block_chance = 0
	throwforce = 0
	embed_type = null
	sword_color_icon = null

	active_throwforce = 0
	active_sharpness = NONE
	active_heat = 0

/obj/item/melee/energy/sword/holographic/Initialize(mapload)
	. = ..()
	if(!sword_color_icon)
		sword_color_icon = pick("red", "blue", "green", "purple")

/obj/item/melee/energy/sword/holographic/green
	sword_color_icon = "green"

/obj/item/melee/energy/sword/holographic/red
	sword_color_icon = "red"

/obj/item/toy/cards/deck/syndicate/holographic
	desc = "A deck of holographic playing cards."

/obj/item/toy/cards/deck/syndicate/holographic/Initialize(mapload, obj/machinery/computer/holodeck/holodeck)
	src.holodeck = holodeck
	RegisterSignal(src, COMSIG_QDELETING, PROC_REF(handle_card_delete))
	. = ..()

/obj/item/toy/cards/deck/syndicate/holographic/proc/handle_card_delete(datum/source)
	SIGNAL_HANDLER

	//if any REAL cards have been inserted into the deck they are moved outside before destroying it
	for(var/obj/item/toy/singlecard/card in card_atoms)
		if(card.flags_1 & HOLOGRAM_1)
			continue
		card_atoms -= card
		card.forceMove(drop_location())

/obj/item/toy/dodgeball
	name = "dodgeball"
	icon = 'icons/obj/toys/balls.dmi'
	icon_state = "dodgeball"
	inhand_icon_state = "dodgeball"
	desc = "Used for playing the most violent and degrading of childhood games."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/toy/dodgeball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/M = hit_atom
		playsound(src, 'sound/items/dodgeball.ogg', 50, TRUE)
		M.apply_damage(10, STAMINA)
		if(prob(5))
			M.Paralyze(60)
			visible_message(span_danger("[M] is knocked right off [M.p_their()] feet!"))

//
// Machines
//

/obj/machinery/readybutton
	name = "ready declaration device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = FALSE

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.006
	power_channel = AREA_USAGE_ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user)
	to_chat(user, span_warning("The station AI is not to interact with these devices!"))
	return

/obj/machinery/readybutton/attack_paw(mob/user, list/modifiers)
	to_chat(user, span_warning("You are too primitive to use this device!"))
	return

/obj/machinery/readybutton/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	to_chat(user, span_warning("The device is a solid button, there's nothing you can do with it!"))

/obj/machinery/readybutton/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("This device is not powered!"))
		return

	currentarea = get_area(src)
	if(isnull(currentarea))
		qdel(src)
		return

	if(eventstarted)
		to_chat(usr, span_warning("The event has already begun!"))
		return

	ready = !ready

	update_appearance()

	var/numbuttons = 0
	var/numready = 0
	for (var/list/zlevel_turfs as anything in currentarea.get_zlevel_turf_lists())
		for (var/turf/area_turf as anything in zlevel_turfs)
			for(var/obj/machinery/readybutton/button in area_turf)
				numbuttons++
				if(button.ready)
					numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon_state()
	icon_state = "auth_[ready ? "on" : "off"]"
	return ..()

/obj/machinery/readybutton/proc/begin_event()

	eventstarted = TRUE

	for (var/list/zlevel_turfs as anything in currentarea.get_zlevel_turf_lists())
		for(var/turf/area_turf as anything in zlevel_turfs)
			for(var/obj/structure/window/barrier in area_turf)
				if(barrier.flags_1 & HOLOGRAM_1)// Just in case: only holo-windows
					qdel(barrier)

			for(var/mob/contestant in area_turf)
				to_chat(contestant, span_userdanger("FIGHT!"))

/obj/machinery/conveyor/holodeck

/obj/machinery/conveyor/holodeck/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!user.transferItemToLoc(I, drop_location()))
		return ..()

/obj/item/paper/fluff/holodeck/trek_diploma
	name = "paper - Starfleet Academy Diploma"
	default_raw_text = {"<h2>Starfleet Academy</h2></br><p>Official Diploma</p></br>"}

/obj/item/paper/fluff/holodeck/disclaimer
	name = "Holodeck Disclaimer"
	default_raw_text = "Bruises sustained in the holodeck can be healed simply by sleeping."

/obj/vehicle/ridden/scooter/skateboard/pro/holodeck
	name = "holographic skateboard"
	desc = "A holographic copy of the EightO brand professional skateboard."
	instability = 6

/obj/vehicle/ridden/scooter/skateboard/pro/holodeck/pick_up_board() //picking up normal skateboards spawned in the holodeck gets rid of the holo flag, now you cant pick them up.
	return
