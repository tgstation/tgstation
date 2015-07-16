/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = 0
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE
	var/lastupdate = 0

/obj/machinery/portable_atmospherics/New()
	..()
	SSair.atmos_machinery += src
	air_contents.volume = volume
	air_contents.temperature = T20C
	return 1

/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) //only react when pipe_network will not it do it for you
		//Allow for reactions
		air_contents.react()
	else
		update_icon()
/obj/machinery/portable_atmospherics/process()
	return
/obj/machinery/portable_atmospherics/Destroy()
	qdel(air_contents)
	SSair.atmos_machinery -= src
	..()

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	var/datum/pipeline/connected_port_parent = connected_port.parents["p1"]
	connected_port_parent.reconcile_air()

	anchored = 1 //Prevent movement
	return 1

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return 0
	anchored = 0
	connected_port.connected_device = null
	connected_port = null
	return 1

/obj/machinery/portable_atmospherics/portableConnectorReturnAir()
	return air_contents

/obj/machinery/portable_atmospherics/attackby(obj/item/weapon/W, mob/user, params)
	if ((istype(W, /obj/item/weapon/tank) && !( src.destroyed )))
		if (src.holding)
			return
		if(!user.drop_item())
			return

		var/obj/item/weapon/tank/T = W
		T.loc = src
		src.holding = T
		update_icon()
		return

	else if (istype(W, /obj/item/weapon/wrench))
		if(connected_port)
			disconnect()
			user << "<span class='notice'>You disconnect [name] from the port.</span>"
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
			if(possible_port)
				if(connect(possible_port))
					user << "<span class='notice'>You connect [name] to the port.</span>"
					update_icon()
					return
				else
					user << "<span class='notice'>[name] failed to connect to the port.</span>"
					return
			else
				user << "<span class='notice'>Nothing happens.</span>"
				return

	else if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)

	return