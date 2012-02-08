/obj/machinery/portable_atmospherics/pump
	name = "Portable Air Pump"

	icon = 'atmos.dmi'
	icon_state = "psiphon:0"
	density = 1

	var/on = 0
	var/direction_out = 0 //0 = siphoning, 1 = releasing
	var/target_pressure = 100

	volume = 2500

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

/obj/machinery/portable_atmospherics/pump/process()
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

				air_contents.merge(removed)
		//src.update_icon()

	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/pump/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/pump/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/pump/attack_hand(var/mob/user as mob)

	user.machine = src
	var/holding_text

	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Pump Direction: <A href='?src=\ref[src];direction=1'>[direction_out?("Out"):("In")]</A><BR>
Target Pressure: <A href='?src=\ref[src];pressure_adj=-1000'>-</A> <A href='?src=\ref[src];pressure_adj=-100'>-</A> <A href='?src=\ref[src];pressure_adj=-10'>-</A> <A href='?src=\ref[src];pressure_adj=-1'>-</A> [target_pressure] <A href='?src=\ref[src];pressure_adj=1'>+</A> <A href='?src=\ref[src];pressure_adj=10'>+</A> <A href='?src=\ref[src];pressure_adj=100'>+</A> <A href='?src=\ref[src];pressure_adj=1000'>+</A><BR>
<HR>
<A href='?src=\ref[user];mach_close=pump'>Close</A><BR>
"}

	user << browse(output_text, "window=pump;size=600x300")
	onclose(user, "pump")

	return

/obj/machinery/portable_atmospherics/pump/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src

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