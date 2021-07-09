/obj/item/reagent_containers/glass/maunamug
	name = "mauna mug"
	desc = "A drink served in a classy mug. Now with built-in heating!"
	icon = 'icons/obj/mauna_mug.dmi'
	icon_state = "maunamug"
	base_icon_state = "maunamug"
	spillable = TRUE
	reagent_flags = OPENCONTAINER
	fill_icon_state = "maunafilling"
	fill_icon_thresholds = list(25)
	var/obj/item/stock_parts/cell/cell
	var/open = FALSE
	var/on = FALSE

/obj/item/reagent_containers/glass/maunamug/Initialize(mapload, vol)
	. = ..()
	cell = new /obj/item/stock_parts/cell(src)

/obj/item/reagent_containers/glass/maunamug/get_cell()
	return cell

/obj/item/reagent_containers/glass/maunamug/examine(mob/user)
	. = ..()
	. += span_notice("The status display reads: Current temperature: <b>[reagents.chem_temp]K</b> Current Charge:[cell ? "[cell.charge / cell.maxcharge * 100]%" : "No cell found"].")
	if(open)
		. += span_notice("The battery case is open.")
	if(cell && cell.charge > 0)
		. += span_notice("<b>Ctrl+Click</b> to toggle the power.")

/obj/item/reagent_containers/glass/maunamug/process(delta_time)
	..()
	if(on && (!cell || cell.charge <= 0)) //Check if we ran out of power
		change_power_status(FALSE)
		return FALSE
	cell.use(5 * delta_time) //Basic cell goes for like 200 seconds, bluespace for 8000
	if(!reagents.total_volume)
		return FALSE
	var/max_temp = min(500 + (500 * (0.2 * cell.rating)), 1000) // 373 to 1000
	reagents.adjust_thermal_energy(0.4 * cell.maxcharge * reagents.total_volume * delta_time, max_temp = max_temp) // 4 kelvin every tick on a basic cell. 160k on bluespace
	reagents.handle_reactions()
	update_appearance()
	if(reagents.chem_temp >= max_temp)
		change_power_status(FALSE)
		audible_message(span_notice("The Mauna Mug lets out a happy beep and turns off!"))
		playsound(src, 'sound/machines/chime.ogg', 50)

/obj/item/reagent_containers/glass/maunamug/Destroy()
	if(cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/reagent_containers/glass/maunamug/CtrlClick(mob/living/user)
	if(on)
		change_power_status(FALSE)
	else
		if(!cell || cell.charge <= 0)
			return FALSE //No power, so don't turn on
		change_power_status(TRUE)

/obj/item/reagent_containers/glass/maunamug/proc/change_power_status(status)
	on = status
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/reagent_containers/glass/maunamug/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	open = !open
	to_chat(user, span_notice("You screw the battery case on [src] [open ? "open" : "closed"] ."))
	update_appearance()

/obj/item/reagent_containers/glass/maunamug/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(!istype(I, /obj/item/stock_parts/cell))
		return ..()
	if(!open)
		to_chat(user, span_warning("The battery case must be open to insert a power cell!"))
		return FALSE
	if(cell)
		to_chat(user, span_warning("There is already a power cell inside!"))
		return FALSE
	else if(!user.transferItemToLoc(I, src))
		return
	cell = I
	user.visible_message(span_notice("[user] inserts a power cell into [src]."), span_notice("You insert the power cell into [src]."))
	update_appearance()

/obj/item/reagent_containers/glass/maunamug/attack_hand(mob/living/user, list/modifiers)
	if(cell && open)
		cell.update_appearance()
		user.put_in_hands(cell)
		cell = null
		to_chat(user, span_notice("You remove the power cell from [src]."))
		on = FALSE
		update_appearance()
		return TRUE
	return ..()

/obj/item/reagent_containers/glass/maunamug/update_icon_state()
	if(open)
		icon_state = "[base_icon_state][cell ? null : "_no"]_bat"
		return ..()
	icon_state = "[base_icon_state][on ? "_on" : null]"
	return ..()

/obj/item/reagent_containers/glass/maunamug/update_overlays()
	. = ..()
	if(!reagents.total_volume || reagents.chem_temp < 400)
		return

	var/intensity = (reagents.chem_temp - 400) * 1 / 600 //Get the opacity of the incandescent overlay. Ranging from 400 to 1000
	var/mutable_appearance/mug_glow = mutable_appearance(icon, "maunamug_incand")
	mug_glow.alpha = 255 * intensity
	. += mug_glow
