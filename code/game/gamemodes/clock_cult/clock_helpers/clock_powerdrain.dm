//horrifying power drain proc made for clockcult's power drain in lieu of six istypes or six for(x in view) loops
/atom/movable/proc/power_drain(clockcult_user)
	var/obj/item/weapon/stock_parts/cell/cell = get_cell()
	if(cell)
		return cell.power_drain(clockcult_user)
	return 0

/obj/item/weapon/melee/baton/power_drain(clockcult_user)	//balance memes
	return 0

/obj/item/weapon/gun/power_drain(clockcult_user)	//balance memes
	return 0

/obj/machinery/power/apc/power_drain(clockcult_user)
	if(cell && cell.charge)
		playsound(src, "sparks", 50, 1)
		flick("apc-spark", src)
		. = min(cell.charge, MIN_CLOCKCULT_POWER*3)
		cell.use(.) //Better than a power sink!
		if(!cell.charge && !shorted)
			shorted = 1
			visible_message("<span class='warning'>The [name]'s screen blurs with static.</span>")
		update()
		update_icon()

/obj/machinery/power/smes/power_drain(clockcult_user)
	if(charge)
		. = min(charge, MIN_CLOCKCULT_POWER*3)
		charge -= . * 50
		if(!charge && !panel_open)
			panel_open = TRUE
			icon_state = "[initial(icon_state)]-o"
			do_sparks(10, FALSE, src)
			visible_message("<span class='warning'>[src]'s panel flies open with a flurry of sparks!</span>")
		update_icon()

/obj/item/weapon/stock_parts/cell/power_drain(clockcult_user)
	if(charge)
		. = min(charge, MIN_CLOCKCULT_POWER*3)
		charge = use(.)
		update_icon()

/mob/living/silicon/robot/power_drain(clockcult_user)
	if((!clockcult_user || !is_servant_of_ratvar(src)) && cell && cell.charge)
		. = min(cell.charge, MIN_CLOCKCULT_POWER*4)
		cell.use(.)
		spark_system.start()

/obj/mecha/power_drain(clockcult_user)
	if((!clockcult_user || (occupant && !is_servant_of_ratvar(occupant))) && cell && cell.charge)
		. = min(cell.charge, MIN_CLOCKCULT_POWER*4)
		cell.use(.)
		spark_system.start()
