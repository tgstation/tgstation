/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = 0
	var/datum/gas_mixture/air_contents = new

	var/obj/machinery/atmospherics/unary/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0
	var/destroyed = 0

	var/maximum_pressure = 90*ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/New()
	..()
	air_contents.volume = volume
	air_contents.temperature = T20C

	return 1

/obj/machinery/portable_atmospherics/initialize()
	. = ..()
	spawn()
		var/obj/machinery/atmospherics/unary/portables_connector/port = locate() in loc
		if(port)
			connect(port)
			update_icon()

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

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
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

	var/obj/icon = src
	if ((istype(W, /obj/item/weapon/tank) && !( src.destroyed )))
		if (src.holding)
			return 0
		var/obj/item/weapon/tank/T = W
		user.drop_item(T, src)
		src.holding = T
		update_icon()
		return 1

	else if (istype(W, /obj/item/weapon/wrench))
		if(connected_port)
			disconnect()
			to_chat(user, "<span class='notice'>You disconnect [name] from the port.</span>")
			update_icon()
			pixel_x = 0
			pixel_y = 0
			return 1
		else
			var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
			if(possible_port)
				if(connect(possible_port))
					to_chat(user, "<span class='notice'>You connect [name] to the port.</span>")
					var/datum/gas/sleeping_agent/S = locate() in src.air_contents.trace_gases
					if(src.air_contents.toxins > 0 || (istype(S)))
						log_admin("[usr]([ckey(usr.key)]) connected a canister that contains \[[src.air_contents.toxins > 0 ? "Toxins" : ""] [istype(S) ? " N2O" : ""]\] to a connector_port at [loc.x], [loc.y], [loc.z]")
					update_icon()
					pixel_x = possible_port.pixel_x
					pixel_y = possible_port.pixel_y
					return 1
				else
					to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
					return 0
			else
				if(..()) return 1 //Give a chance for the wrench flag if it is wrenchable, it's not snowflake if I say it isn't ya hear!
				to_chat(user, "<span class='notice'>Nothing happens.</span>")
				return 0
	if(..()) //Let the other machine flags have a shot
		return 1

	else if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		user.visible_message("<span class='attack'>[user] has used [W] on \icon[icon] [src]</span>", "<span class='attack'>You use \the [W] on \icon[icon] [src]</span>")
		var/obj/item/device/analyzer/analyzer = W
		user.show_message(analyzer.output_gas_scan(src.air_contents, src, 0), 1)
		src.add_fingerprint(user)
		return
	return
