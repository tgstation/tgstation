/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 60, acid = 30)


	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	var/obj/item/tank/holding

	var/volume = 0

	var/maximum_pressure = 90 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/New()
	..()
	SSair.atmos_machinery += src

	air_contents = new
	air_contents.volume = volume
	air_contents.temperature = T20C

	return 1

/obj/machinery/portable_atmospherics/Destroy()
	SSair.atmos_machinery -= src

	disconnect()
	qdel(air_contents)
	air_contents = null

	return ..()

/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) // Pipe network handles reactions if connected.
		air_contents.react()
	else
		update_icon()

/obj/machinery/portable_atmospherics/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != get_turf(src))
		return 0

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	var/datum/pipeline/connected_port_parent = connected_port.PARENT1
	connected_port_parent.reconcile_air()

	anchored = TRUE //Prevent movement
	return 1

/obj/machinery/portable_atmospherics/Move()
	. = ..()
	if(.)
		disconnect()

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return 0
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	return 1

/obj/machinery/portable_atmospherics/portableConnectorReturnAir()
	return air_contents

/obj/machinery/portable_atmospherics/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank))
		if(!(stat & BROKEN))
			var/obj/item/tank/T = W
			if(holding || !user.drop_item())
				return
			T.loc = src
			holding = T
			update_icon()
	else if(istype(W, /obj/item/wrench))
		if(!(stat & BROKEN))
			if(connected_port)
				disconnect()
				playsound(src.loc, W.usesound, 50, 1)
				user.visible_message( \
					"[user] disconnects [src].", \
					"<span class='notice'>You unfasten [src] from the port.</span>", \
					"<span class='italics'>You hear a ratchet.</span>")
				update_icon()
				return
			else
				var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
				if(!possible_port)
					to_chat(user, "<span class='notice'>Nothing happens.</span>")
					return
				if(!connect(possible_port))
					to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
					return
				playsound(src.loc, W.usesound, 50, 1)
				user.visible_message( \
					"[user] connects [src].", \
					"<span class='notice'>You fasten [src] to the port.</span>", \
					"<span class='italics'>You hear a ratchet.</span>")
				update_icon()
	else if(istype(W, /obj/item/device/analyzer) && Adjacent(user))
		atmosanalyzer_scan(air_contents, user)
	else
		return ..()

/obj/machinery/portable_atmospherics/attacked_by(obj/item/I, mob/user)
	if(I.force < 10 && !(stat & BROKEN))
		take_damage(0)
	else
		investigate_log("was smacked with \a [I] by [key_name(user)].", INVESTIGATE_ATMOS)
		add_fingerprint(user)
		..()
