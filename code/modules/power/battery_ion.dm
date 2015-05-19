// Generic battery machine
// stores power

/obj/machinery/power/battery/portable
	name = "portable power storage unit"
	desc = "A IOn-model portable storage unit, used to transport charge around the station."
	icon_state = "port_smes"
	density = 1
	anchored = 0
	use_power = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE

	var/obj/machinery/power/battery_port/connected_to

/obj/machinery/power/battery/portable/initialize()
	..()
	if(anchored)
		var/obj/machinery/power/battery_port/port = locate() in src.loc
		if(port)
			port.connect_battery(src)

/obj/machinery/power/battery/portable/get_powernet()
	if(connected_to)
		return connected_to.get_powernet()

/obj/machinery/power/battery/portable/add_avail(var/amount)
	if(connected_to)
		connected_to.add_avail(amount)

/obj/machinery/power/battery/portable/add_load(var/amount)
	if(connected_to)
		connected_to.add_load(amount)

/obj/machinery/power/battery/portable/surplus()
	if(connected_to)
		return connected_to.surplus()
	return 0

/obj/machinery/power/battery/portable/wrenchAnchor(mob/user)
	if(..() == 1)
		if(anchored)
			var/obj/machinery/power/battery_port/port = locate() in src.loc
			if(port)
				port.connect_battery(src)
		else
			if(connected_to)
				connected_to.disconnect_battery()
		return 1
	return -1

/obj/machinery/power/battery/portable/update_icon()
	overlays.len = 0
	if(stat & BROKEN)	return

	overlays += image('icons/obj/power.dmi', "smes-op[online]")

	if(charging)
		overlays += image('icons/obj/power.dmi', "smes-oc1")
	else
		if(chargemode)
			overlays += image('icons/obj/power.dmi', "smes-oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		overlays += image('icons/obj/power.dmi', "smes-og[clevel]")

	if(connected_to)
		connected_to.update_icon()
	return
