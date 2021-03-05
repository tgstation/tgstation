#define CENTRIFUGE_UPS 0.2 //units per second


/obj/machinery/centrifuge
	name = "\improper Makeshift centrifuge"
	desc = "Centrifuge go brrrrrr!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "centrifuge_off"
	base_icon_state = "centrifuge"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	var/open = TRUE
	var/obj/item/reagent_containers/first_container
	var/obj/item/reagent_containers/second_container
	var/mutable_appearance/beaker1_overlay
	var/mutable_appearance/beaker2_overlay
	var/mutable_appearance/door
	var/busy = FALSE
	var/start_time
	var/offset

/obj/machinery/centrifuge/Initialize()
	create_reagents(100, REFILLABLE | TRANSPARENT)
	door = mutable_appearance(icon, "centrifuge_door")
	door.pixel_y = 0
	door.pixel_x = 0
	beaker1_overlay = mutable_appearance(icon, "disp_beaker")
	beaker1_overlay.pixel_y = -6
	beaker1_overlay.pixel_x = 2
	beaker2_overlay = mutable_appearance(icon, "disp_beaker")
	beaker2_overlay.pixel_y = -6
	beaker2_overlay.pixel_x = 6
	. = ..()

/obj/machinery/centrifuge/proc/separate(uptime)
	if(!length(reagents.reagent_list))
		return FALSE
	var/units_transfered = uptime/1 SECONDS*CENTRIFUGE_UPS
	message_admins("separated [units_transfered] units")
	for(var/datum/reagent/R in reagents.reagent_list)
		if(prob(50))
			reagents.trans_id_to(first_container,R.type,units_transfered)
		else
			reagents.trans_id_to(second_container,R.type,units_transfered)
		
	return TRUE
/obj/machinery/centrifuge/CheckParts(list/parts)
	var/volume_total
	for(var/obj/item/reagent_containers/C in parts)
		volume_total += C.reagents.maximum_volume
		transferItemToLoc(C, src)
	reagents.maximum_volume = volume_total

/obj/machinery/centrifuge/update_icon_state()
	icon_state = "[base_icon_state]_[powered() ? "on" : "off"]"
	return ..()


/obj/machinery/centrifuge/update_overlays()
	. = ..()
	if(first_container)
		. += beaker1_overlay
	if(second_container)
		. += beaker2_overlay
	if(open)
		. += door

/obj/machinery/centrifuge/crowbar_act(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(busy)
		to_chat(user, "<span class='warning'>You can't get a handle on [src]'s lid!</span>")
		return
	open = !open
	to_chat(user, "<span class='notice'>You pry [open ? "open" : "closed"] [src]'s lid.</span>")
	if(open)
		reagents.flags |= (REFILLABLE | TRANSPARENT)
	else
		reagents.flags &= ~(REFILLABLE| TRANSPARENT)
	update_overlays()
	update_icon()

/obj/machinery/centrifuge/CtrlClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || issilicon(user))
		return
	if(open || (!first_container || !second_container))
		to_chat(user, "<span class='warning'>It wouldn't be wise to turn [src] on without [open ? "closing the lid" : "reagent containers for outputs"]!</span>")
		return
	if(!powered())
		to_chat(user, "<span class='warning'>[src] has no power!</span>")
		return
	idle_power_usage = busy ? 1000 : 20
	busy = !busy
	to_chat(user, "<span class='notice'>You power [busy ? "on" : "off"] [src].")
	if(!busy)
		separate(world.time - start_time)
		animate(src)
	else
		playsound(src, 'sound/machines/blender.ogg', 50, TRUE)	
		start_time = world.time
		offset = rand(-5,5)
		animate(src, pixel_x = pixel_x + offset, time=0.2, loop=-1)

/obj/machinery/centrifuge/attackby(obj/item/I, mob/living/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container() && !open)
		var/obj/item/reagent_containers/B = I
		if(!first_container)
			if(!user.transferItemToLoc(B, src))
				return
			first_container = B
			update_overlays()
			update_icon()
			return TRUE
		if(!second_container)
			if(!user.transferItemToLoc(B, src))
				return
			second_container = B
			update_overlays()
			update_icon()
			return TRUE
		return ..()

/obj/machinery/centrifuge/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(busy)
		to_chat(user, "<span class='warning'>You can't get a handle on [src]'s receptacle!</span>")
		return
	if(second_container)
		if(!try_put_in_hand(second_container, user))
			second_container = null
			update_overlays()
			update_icon()
			return
	else if(first_container)
		if(!try_put_in_hand(first_container, user))
			first_container = null
			update_overlays()
			update_icon()
			return
	
	
