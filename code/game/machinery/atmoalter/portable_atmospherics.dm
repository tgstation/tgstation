/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = 0
	allow_malf_AI_verbs = 0
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/New()
	..()

	air_contents.volume = volume
	air_contents.temperature = T20C

	return 1

/obj/machinery/portable_atmospherics/process()
	if(!connected_port) //only react when pipe_network will ont it do it for you
		//Allow for reactions
		air_contents.react()
	else
		update_icon()

/obj/machinery/portable_atmospherics/Destroy()
	del(air_contents)

	..()

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/portables_connector/new_port)
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

/obj/machinery/portable_atmospherics/proc/disconnect()
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
			user << "<span class='notice'>You disconnect [name] from the port.</span>"
			update_icon()
			return
		else
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
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