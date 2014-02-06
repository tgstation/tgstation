/turf/simulated/floor/mech_bay_recharge_floor               //        Whos idea it was
	name = "mech bay recharge station"                      //        Recharging turfs
	icon = 'icons/turf/floors.dmi'                          //		  That are set in stone to check the west turf for recharge port
	icon_state = "recharge_floor"                           //        Some people just want to watch the world burn i guess


/turf/simulated/floor/mech_bay_recharge_floor/airless
	icon_state = "recharge_floor_asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB


/obj/machinery/mech_bay_recharge_port
	name = "mech bay power port"
	density = 1
	anchored = 1
	dir = 4
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	var/obj/mecha/recharging_mech
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/max_charge = 50
	var/on = 0
	var/repairability = 0

/obj/machinery/mech_bay_recharge_port/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/mech_recharger(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/MC
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		MC += C.rating
	max_charge = MC - 4 * 50

/obj/machinery/mech_bay_recharge_port/process()
	if(stat & NOPOWER || !recharge_console)
		return
	if(!recharging_mech)
		recharging_mech = locate(/obj/mecha) in get_step(loc, dir)
	if(recharging_mech && recharging_mech.cell && (recharging_mech.loc == get_step(loc, dir)))
		if(recharging_mech.cell.charge < recharging_mech.cell.maxcharge)
			var/delta = min(max_charge, recharging_mech.cell.maxcharge - recharging_mech.cell.charge)
			recharging_mech.give_power(delta)
			use_power(delta*150)


/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return

	if(default_change_direction_wrench(user, I))
		return

	default_deconstruction_crowbar(I)

	if(panel_open)
		if(istype(I, /obj/item/device/multitool))
			var/obj/item/device/multitool/MT = I
			if(istype(MT.buffer, /obj/machinery/computer/mech_bay_power_console))
				recharge_console = MT.buffer
				MT.buffer = 0
				recharge_console.recharge_port = src
				user << "span class='notice'>You upload the data from the buffer to [src.name].</span>"

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	density = 1
	anchored = 1
	icon = 'icons/obj/computer.dmi'
	icon_state = "recharge_comp"
	circuit = /obj/item/weapon/circuitboard/mech_bay_power_console
	var/obj/machinery/mech_bay_recharge_port/recharge_port

/obj/machinery/computer/mech_bay_power_console/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/device/multitool))
		var/obj/item/device/multitool/MT = I
		MT.buffer = src
		user << "<span class='notice'>You download data to the buffer.</span>"


/obj/machinery/computer/mech_bay_power_console/attack_ai(mob/user)
	return interact(user)

/obj/machinery/computer/mech_bay_power_console/attack_hand(mob/user)
	if(!(..()))
		return interact(user)

/obj/machinery/computer/mech_bay_power_console/interact(mob/user as mob)
	var/data
	if(!recharge_port)
		data += "<div class='statusDisplay'>No recharging port detected.</div>"
	else
		data += "<h3>Mech status</h3>"
		if(!recharge_port.recharging_mech)
			data += "<div class='statusDisplay'>No mech detected.</div>"
		else
			data += "<div class='statusDisplay'>Integrity: [recharge_port.recharging_mech.health]<BR>"
			data += "Power: [recharge_port.recharging_mech.cell]</div>"

	var/datum/browser/popup = new(user, "mech recharger", name, 300, 300)
	popup.set_content(data)
	popup.open()
	return

/obj/machinery/computer/mech_bay_power_console/process()
	updateUsrDialog()
	update_icon()

/obj/machinery/computer/mech_bay_power_console/update_icon()
	if(!recharge_port || !recharge_port.recharging_mech || !recharge_port.recharging_mech.cell || !(recharge_port.recharging_mech.cell.charge < recharge_port.recharging_mech.cell.maxcharge))
		icon_state = "recharge_comp"
	else
		icon_state = "recharge_comp_on"