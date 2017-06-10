//horrifying power drain proc made for clockcult's power drain in lieu of six istypes or six for(x in view) loops
/atom/movable/proc/power_drain(clockcult_user)
	return 0

/obj/machinery/power/apc/power_drain(clockcult_user)
	if(cell && cell.charge)
		playsound(src, "sparks", 50, 1)
		flick("apc-spark", src)
		. = min(cell.charge, 250)
		cell.use(.) //Better than a power sink!
		if(!cell.charge && !shorted)
			shorted = 1
			visible_message("<span class='warning'>The [name]'s screen blurs with static.</span>")
		update()
		update_icon()

/obj/machinery/power/smes/power_drain(clockcult_user)
	if(charge)
		. = min(charge, 250)
		charge -= . * 50
		if(!charge && !panel_open)
			panel_open = TRUE
			icon_state = "[initial(icon_state)]-o"
			do_sparks(10, FALSE, src)
			visible_message("<span class='warning'>[src]'s panel flies open with a flurry of sparks!</span>")
		update_icon()

/obj/item/weapon/stock_parts/cell/power_drain(clockcult_user)
	if(charge)
		. = min(charge, 250)
		charge = use(.)
		update_icon()

/obj/machinery/light/power_drain(clockcult_user)
	if(on)
		playsound(src, 'sound/effects/light_flicker.ogg', 50, 1)
		. = 250
		if(prob(50))
			burn_out()

/mob/living/silicon/robot/power_drain(clockcult_user)
	if((!clockcult_user || !is_servant_of_ratvar(src)) && cell && cell.charge)
		. = min(cell.charge, 250)
		cell.use(.)
		if(prob(20))
			to_chat(src, "<span class='userdanger'>ERROR: Power loss detected!</span>")
		spark_system.start()

/obj/mecha/power_drain(clockcult_user)
	if((!clockcult_user || !occupant || occupant && !is_servant_of_ratvar(occupant)) && cell && cell.charge)
		. = min(cell.charge, 250)
		cell.use(.)
		if(prob(20))
			occupant_message("<span class='userdanger'>Power loss detected!</span>")
		spark_system.start()
