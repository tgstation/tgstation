/turf/simulated/floor/mech_bay_recharge_floor               //        Whos idea it was
	name = "mech bay recharge station"                      //        Recharging turfs
	icon = 'icons/turf/floors.dmi'                          //		  That are set in stone to check the west turf for recharge port
	icon_state = "recharge_floor"                           //        Some people just want to watch the world burn i guess

/turf/simulated/floor/mech_bay_recharge_floor/break_tile()
	src.ChangeTurf(/turf/simulated/floor/plating)

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
	var/turf/recharging_turf = null

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
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/MC
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		MC += C.rating
	max_charge = MC * 25

/obj/machinery/mech_bay_recharge_port/process()
	if(stat & NOPOWER || !recharge_console)
		return
	if(!recharging_mech)
		recharging_mech = locate(/obj/mecha) in recharging_turf
		if(recharging_mech)
			recharge_console.update_icon()
	if(recharging_mech && recharging_mech.cell)
		if(recharging_mech.cell.charge < recharging_mech.cell.maxcharge)
			var/delta = min(max_charge, recharging_mech.cell.maxcharge - recharging_mech.cell.charge)
			recharging_mech.give_power(delta)
			use_power(delta*150)
		else
			recharge_console.update_icon()
		if(recharging_mech.loc != recharging_turf)
			recharging_mech = null
			recharge_console.update_icon()


/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return

	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	desc = "Used to control mechbay power ports."
	icon_screen = "recharge_comp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/weapon/circuitboard/mech_bay_power_console
	var/obj/machinery/mech_bay_recharge_port/recharge_port

/obj/machinery/computer/mech_bay_power_console/attack_ai(mob/user)
	return interact(user)

/obj/machinery/computer/mech_bay_power_console/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/mech_bay_power_console/interact(mob/user)
	var/data
	if(!recharge_port)
		data += "<div class='statusDisplay'>No recharging port detected.</div><BR>"
		data += "<A href='?src=\ref[src];reconnect=1'>Reconnect</A>"
	else
		data += "<h3>Mech status</h3>"
		if(!recharge_port.recharging_mech)
			data += "<div class='statusDisplay'>No mech detected.</div>"
		else
			data += "<div class='statusDisplay'>Integrity: [recharge_port.recharging_mech.health]<BR>"
			if(recharge_port.recharging_mech.cell.crit_fail)
				data += "<span class='bad'>WARNING : the mech cell seems faulty!</span></div>"
			else
				data += "Power: [recharge_port.recharging_mech.cell.charge]/[recharge_port.recharging_mech.cell.maxcharge]</div>"

	var/datum/browser/popup = new(user, "mech recharger", name, 300, 300)
	popup.set_content(data)
	popup.open()
	return

/obj/machinery/computer/mech_bay_power_console/Topic(href, href_list)
	if(..())
		return
	if(href_list["reconnect"])
		reconnect()
	updateUsrDialog()

/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port )
		for(var/D in cardinal)
			var/turf/A = get_step(src, D)
			A = get_step(A, D)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in A
			if(recharge_port)
				break
	if(recharge_port)
		if(!recharge_port.recharge_console)
			recharge_port.recharge_console = src
		else
			recharge_port = null

/obj/machinery/computer/mech_bay_power_console/process()
	if(recharge_port && recharge_port.recharging_mech && recharge_port.recharging_mech.cell)
		updateDialog()


/obj/machinery/computer/mech_bay_power_console/update_icon()
	..()
	if(!recharge_port || !recharge_port.recharging_mech || !recharge_port.recharging_mech.cell || !(recharge_port.recharging_mech.cell.charge < recharge_port.recharging_mech.cell.maxcharge))
		return
	overlays += "recharge_comp_on"

/obj/machinery/computer/mech_bay_power_console/initialize()
	reconnect()
