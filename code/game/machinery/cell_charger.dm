/obj/machinery/cell_charger
	name = "cell charger"
	desc = "Charges power cells, drains power."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	icon_state_open = "ccharger_open"
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10 //Power is already drained to charge batteries
	power_channel = EQUIP
	var/obj/item/weapon/cell/charging = null
	var/transfer_rate = 200 //How much power do we output every process tick ?
	var/transfer_efficiency = 0.7 //How much power ends up in the battery in percentage ?
	var/transfer_rate_coeff = 1 //What is the quality of the parts that transfer energy (capacitators) ?
	var/transfer_efficiency_bonus = 0 //What is the efficiency "bonus" (additive to percentage) from the parts used (scanning module) ?
	var/chargelevel = -1

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EMAGGABLE

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

/obj/machinery/cell_charger/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/cell_charger,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/cell_charger/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T = (SM.rating - 1)*0.1 //There is one scanning module. Level 1 changes nothing (70 %), level 2 transfers 80 % of power, level 3 90 %
	transfer_efficiency_bonus = T
	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/CA in component_parts)
		T += CA.rating //Two capacitors, every upgrade rank acts as a direct multiplier (up to 3 times base for two Level 3 Capacitors)
	transfer_rate_coeff = T/2
	T = 0


/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER)) )
		var/newlevel = 	round(charging.percent() * 4.0 / 99)
//		to_chat(world, "nl: [newlevel]")

		if(chargelevel != newlevel)
			overlays.len = 0
			overlays += "ccharger-o[newlevel]"
			chargelevel = newlevel
	else
		overlays.len = 0

/obj/machinery/cell_charger/examine(mob/user)
	..()
	to_chat(user, "There's [charging ? "a" : "no"] cell in the charger.")
	if(charging)
		to_chat(user, "Current charge: [charging.charge]")

/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	if(..())
		return 1
	if(istype(W, /obj/item/weapon/cell) && anchored)
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in [src].</span>")
			return
		else
			if(areaMaster.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>[src] blinks red as you try to insert the cell!</span>")
				return

			user.drop_item(W, src)
			charging = W
			user.visible_message("<span class='notice'>[user] inserts a cell into [src].</span>", "<span class='notice'>You insert a cell into [src].</span>")
			chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/emag(mob/user)
	if(!emagged)
		emagged = 1 //Congratulations, you've done it
		user.visible_message("<span class='warning'>[user] swipes a card into \the [src]'s charging port.</span>", \
		"<span class='warning'>You hear fizzling coming from \the [src] and a wire turns red hot as you swipe the electromagnetic card. Better not use it anymore.</span>")
		return

/obj/machinery/cell_charger/attack_robot(mob/user as mob)
	if(isMoMMI(user) && Adjacent(user)) //To be able to remove cells from the charger
		return attack_hand(user)

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(charging)
		if(emagged) //Oh shit nigger what are you doing
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			spawn(15)
				explosion(src.loc, -1, 1, 3, adminlog = 0) //Overload
				Destroy(src) //It exploded, rip
			return
		usr.put_in_hands(charging)
		charging.add_fingerprint(user)
		charging.updateicon()
		src.charging = null
		user.visible_message("<span class='notice'>[user] removes the cell from [src].</span>", "<span class='notice'>You remove the cell from [src].</span>")
		chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/wrenchAnchor(mob/user)
	if(charging)
		to_chat(user, "<span class='warning'>Remove the cell first!</span>")
		return
	..()

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(charging)
		charging.emp_act(severity)
	..(severity)


/obj/machinery/cell_charger/process()
//	to_chat(world, "ccpt [charging] [stat]")
	if(!charging || (stat & (BROKEN|NOPOWER)) || !anchored)
		return

	if(emagged) //Did someone fuck with the charger ?
		use_power(transfer_rate*transfer_rate_coeff*10) //Drain all the power
		charging.give(transfer_rate*transfer_rate_coeff*(transfer_efficiency+transfer_efficiency_bonus)*0.25) //Lose most of it
	else
		use_power(transfer_rate*transfer_rate_coeff) //Snatch some power
		charging.give(transfer_rate*transfer_rate_coeff*(transfer_efficiency+transfer_efficiency_bonus)) //Inefficiency (Joule effect + other shenanigans)

	updateicon()
