/obj/machinery/organdoc
	name = "organdoc"
	desc = "An automatic surgical complex specialized in implantation and transplant operations."
	density = TRUE
	state_open = FALSE
	icon = 'modular_meta/features/not_enough_medical/icons/64x64_autodoc.dmi'
	icon_state = "autodoc_machine"
	circuit = /obj/item/circuitboard/machine/organdoc
	var/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/processing = FALSE
	var/surgerytime = 300

/obj/machinery/organdoc/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/organdoc/RefreshParts()
	. = ..()
/*
	var/max_time = 350
	for(var/obj/item/stock_parts/L in component_parts)
		max_time -= (L.rating*10)
	surgerytime = max(max_time,10)
*/
	//Скорость работы (300 -> 225 -> 150 -> 75 -> 30)
	var/T = -2
	for(var/obj/item/stock_parts/micro_laser/Ml in component_parts)
		T += Ml.rating
	surgerytime = initial(surgerytime) - (initial(surgerytime)*(T))/8
	if(surgerytime <= 30)
		surgerytime = 30

	//Энергопотребление (10к -> 7.5к -> 5к -> 2.5к -> 1к)
	var/P = -1
	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		P += cap.rating
	active_power_usage = initial(active_power_usage) - (initial(active_power_usage)*(P))/4
	if(active_power_usage <= 1000)
		active_power_usage = 1000

/obj/machinery/organdoc/examine(mob/user)
	. = ..()
	if((obj_flags & EMAGGED) && panel_open)
		. += "<hr><span class='warning'>A flashing red light indicates that surgical protocols have been violated!</span>"
	if(processing)
		. += "<hr><span class='notice'>The yellow light signals that the [src.name] is inserting the [storedorgan] into the [occupant].</span>"
	else if(storedorgan)
		. += "<hr><span class='notice'>The green light signals that the [src.name] is ready to insert the [storedorgan].</span>"

/obj/machinery/organdoc/close_machine(mob/user)
	..()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			occupant = null
			return
		to_chat(occupant, span_notice("Close [src.name] door."))

		dosurgery()

/obj/machinery/organdoc/proc/dosurgery()
	if(!storedorgan && !(obj_flags & EMAGGED))
		to_chat(occupant, span_notice("The dashboard on the door shows that the [src.name] has nothing to implant."))
		return

	occupant.visible_message(span_notice("<b>[occupant]</b> presses the [src.name] button.") , span_notice("Feel like sharp things are piercing me and doing something to my organs."))
	playsound(get_turf(occupant), 'sound/items/weapons/circsawhit.ogg', 50, 1)
	processing = TRUE
	update_icon()
	var/mob/living/carbon/C = occupant
	if(obj_flags & EMAGGED)

		for(var/obj/item/bodypart/BP in reverseList(C.bodyparts)) //Chest and head are first in bodyparts, so we invert it to make them suffer more
			C.emote("agony")
			if(!HAS_TRAIT(C, TRAIT_NODISMEMBER))
				BP.dismember()
			else
				C.apply_damage(40, BRUTE, BP)
			sleep(5) //2 seconds to get outta there before dying
			if(!processing)
				return

		src.say(pick("STUPID! STUPID! STUPID!", "I'LL MAKE YOU A CAESAR SALAD!", "YOU'RE FUCKED!", "GET READY TO BECOME A WYCC!", "PREPARE TO GO TO YOUR FOREFATHERS!", "CURSE TWO-TWO-ZERO!"))
		occupant.visible_message(span_warning("[src.name] begins to turn the <b>[occupant]</b> inside out!") , span_warning("My insides are falling apart!"))

	else
		sleep(surgerytime)
		if(!processing)
			return
		var/obj/item/organ/currentorgan = C.get_organ_slot(storedorgan.slot)
		if(currentorgan)
			currentorgan.Remove(C)
			currentorgan.forceMove(get_turf(src))
		storedorgan.Insert(occupant)//insert stored organ into the user
		storedorgan = null
		occupant.visible_message(span_notice("Organdoc is finishing its work.") , span_notice("Organdoc finishes inserting into me."))
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, 0)
	processing = FALSE
	use_energy(active_power_usage)
	open_machine()

/obj/machinery/organdoc/open_machine(mob/user)
	if(processing)
		occupant.visible_message(span_notice("<b>[user]</b> cancels organdoc the inserting procedure.") , span_notice("Organdoc stops inserting into my body."))
		processing = FALSE
	if(occupant)
		occupant.forceMove(drop_location())
		occupant = null
	..(FALSE)

/obj/machinery/organdoc/interact(mob/user)
	if(panel_open)
		to_chat(user, span_notice("Close the technical panel first."))
		return

	if(state_open)
		close_machine()
		return

	open_machine()

/obj/machinery/organdoc/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, span_notice("Organdoc already has an organ or implant to work."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		I.forceMove(src)
		to_chat(user, span_notice("Insert [I.name] in [src.name]."))
	else
		return ..()

/obj/machinery/organdoc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, span_warning("Organdoc is bisy!"))
		return
	if(state_open)
		to_chat(user, span_warning("The open door does not allow the technical panel to be unscrewed!"))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		if(storedorgan)
			storedorgan.forceMove(drop_location())
			storedorgan = null
		update_icon()
		return
	return FALSE

/obj/machinery/organdoc/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE


/obj/machinery/organdoc/update_icon()
	. = ..()
	overlays.Cut()
	if(!state_open)
		if(processing)
			overlays += "[icon_state]_door_on"
			overlays += "[icon_state]_stack"
			overlays += "[icon_state]_smoke"
			overlays += "[icon_state]_green"
		else
			overlays += "[icon_state]_door_off"
			if(occupant)
				if(powered(AREA_USAGE_EQUIP))
					overlays += "[icon_state]_stack"
					overlays += "[icon_state]_yellow"
			else
				overlays += "[icon_state]_red"
	else if(powered(AREA_USAGE_EQUIP))
		overlays += "[icon_state]_red"
	if(panel_open)
		overlays += "[icon_state]_panel"

/obj/machinery/organdoc/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_warning("Loading food creation program. Now the [src.name] is dangerous to use!"))

/obj/item/circuitboard/machine/organdoc
	name = "Organdoc"
	build_path = /obj/machinery/organdoc
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	req_components = list(/obj/item/scalpel/advanced = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/surgicaldrill = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/servo = 1,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 1)

/datum/design/board/organdoc
	name = "Organdoc"
	desc = "An automatic surgical complex specialized in implantation and transplant operations."
	id = "organdoc"
	build_path = /obj/item/circuitboard/machine/organdoc
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
