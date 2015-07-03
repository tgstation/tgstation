/obj/machinery/portable_atmospherics/pump
	name = "portable air pump"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "psiphon:0"
	density = 1

	var/on = 0
	var/direction_out = 0 //0 = siphoning, 1 = releasing
	var/target_pressure = 100

	volume = 1000

/obj/machinery/portable_atmospherics/pump/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "psiphon:1"
	else
		icon_state = "psiphon:0"

	if(holding)
		overlays += "siphon-open"

	if(connected_port)
		overlays += "siphon-connector"

	return

/obj/machinery/portable_atmospherics/pump/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on

	if(prob(100/severity))
		direction_out = !direction_out

	target_pressure = rand(0,1300)
	update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/pump/process_atmos()
	..()
	if(on)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()
		if(direction_out)
			var/pressure_delta = target_pressure - environment.return_pressure()
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(air_contents.temperature > 0)
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				if(holding)
					environment.merge(removed)
				else
					loc.assume_air(removed)
					air_update_turf()
		else
			var/pressure_delta = target_pressure - air_contents.return_pressure()
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(environment.temperature > 0)
				transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed
				if(holding)
					removed = environment.remove(transfer_moles)
				else
					removed = loc.remove_air(transfer_moles)
					air_update_turf()

				air_contents.merge(removed)
		//src.update_icon()
/obj/machinery/portable_atmospherics/pump/process()
	..()
	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/pump/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/pump/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_hand(var/mob/user as mob)
	return src.ui_interact(user)


/obj/machinery/portable_atmospherics/pump/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "portapump.tmpl", "Portable Air Pump", 480, 400, 10)

/obj/machinery/portable_atmospherics/pump/get_ui_data()
	var/data = list()
	data["name"] = src.name
	data["portConnected"] = src.connected_port ? 1 : 0
	data["pumpPressure"] = round(src.air_contents.return_pressure() ? src.air_contents.return_pressure() : 0)
	data["targetPressure"] = round(src.target_pressure ? src.target_pressure : 0)
	data["minTargetPressure"] = round(ONE_ATMOSPHERE/10)
	data["maxTargetPressure"] = round(10*ONE_ATMOSPHERE)
	data["direction"] = src.direction_out ? 1 : 0
	data["status"] = src.on ? 1 : 0

	data["hasHoldingTank"] = src.holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = src.holding.name, "tankPressure" = round(src.holding.air_contents.return_pressure()))

	return data

/obj/machinery/portable_atmospherics/pump/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.set_machine(src)

		if(href_list["power"])
			on = !on

		if(href_list["direction"])
			direction_out = !direction_out

		if (href_list["remove_tank"])
			if(holding)
				holding.loc = loc
				holding = null

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			target_pressure = min(10*ONE_ATMOSPHERE, max(0, target_pressure+diff))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=pump")
		return
	return