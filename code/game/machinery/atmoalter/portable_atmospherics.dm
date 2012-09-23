/obj/machinery/portable_atmospherics
	name = "atmoalter"
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE

	New()
		..()

		air_contents.volume = volume
		air_contents.temperature = T20C

		return 1

	process()
		if(!connected_port) //only react when pipe_network will ont it do it for you
			//Allow for reactions
			air_contents.react()
		else
			update_icon()

	Del()
		del(air_contents)

		..()

	update_icon()
		return null

	proc

		connect(obj/machinery/atmospherics/portables_connector/new_port)
			//Make sure not already connected to something else
			if(connected_port || !new_port || new_port.connected_device)
				return 0

			//Make sure are close enough for a valid connection
			if(new_port.loc != loc)
				return 0

			//Perform the connection
			connected_port = new_port
			connected_port.connected_device = src

			anchored = 1 //Prevent movement

			//Actually enforce the air sharing
			var/datum/pipe_network/network = connected_port.return_network(src)
			if(network && !network.gases.Find(air_contents))
				network.gases += air_contents
				network.update = 1

			return 1

		disconnect()
			if(!connected_port)
				return 0

			var/datum/pipe_network/network = connected_port.return_network(src)
			if(network)
				network.gases -= air_contents

			anchored = 0

			connected_port.connected_device = null
			connected_port = null

			return 1

/obj/machinery/portable_atmospherics/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	var/obj/icon = src
	if ((istype(W, /obj/item/weapon/tank) && !( src.destroyed )))
		if (src.holding)
			return
		var/obj/item/weapon/tank/T = W
		user.drop_item()
		T.loc = src
		src.holding = T
		update_icon()
		return

	else if (istype(W, /obj/item/weapon/wrench))
		if(connected_port)
			disconnect()
			user << "\blue You disconnect [name] from the port."
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					user << "\blue You connect [name] to the port."
					update_icon()
					return
				else
					user << "\blue [name] failed to connect to the port."
					return
			else
				user << "\blue Nothing happens."
				return

	else if ((istype(W, /obj/item/device/analyzer) || (istype(W, /obj/item/device/pda))) && get_dist(user, src) <= 1)
		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used [W] on \icon[icon]"
		if(air_contents)
			var/pressure = air_contents.return_pressure()
			var/total_moles = air_contents.total_moles()

			user << "\blue Results of analysis of \icon[icon]"
			if (total_moles>0)
				var/o2_concentration = air_contents.oxygen/total_moles
				var/n2_concentration = air_contents.nitrogen/total_moles
				var/co2_concentration = air_contents.carbon_dioxide/total_moles
				var/plasma_concentration = air_contents.toxins/total_moles

				var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

				user << "\blue Pressure: [round(pressure,0.1)] kPa"
				user << "\blue Nitrogen: [round(n2_concentration*100)]%"
				user << "\blue Oxygen: [round(o2_concentration*100)]%"
				user << "\blue CO2: [round(co2_concentration*100)]%"
				user << "\blue Plasma: [round(plasma_concentration*100)]%"
				if(unknown_concentration>0.01)
					user << "\red Unknown: [round(unknown_concentration*100)]%"
				user << "\blue Temperature: [round(air_contents.temperature-T0C)]&deg;C"
			else
				user << "\blue Tank is empty!"
		else
			user << "\blue Tank is empty!"
		return

	return