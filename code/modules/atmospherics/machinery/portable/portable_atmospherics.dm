/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 60, "acid" = 30)
	anchored = FALSE

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
		air_contents.react(src)
	else
		update_icon()

/obj/machinery/portable_atmospherics/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != get_turf(src))
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	var/datum/pipeline/connected_port_parent = connected_port.parents[1]
	connected_port_parent.reconcile_air()

	anchored = TRUE //Prevent movement
	pixel_x = new_port.pixel_x
	pixel_y = new_port.pixel_y
	return TRUE

/obj/machinery/portable_atmospherics/Move()
	. = ..()
	if(.)
		disconnect()

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	pixel_x = 0
	pixel_y = 0
	return TRUE

/obj/machinery/portable_atmospherics/portableConnectorReturnAir()
	return air_contents

/obj/machinery/portable_atmospherics/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, !ismonkey(user)))
		return
	if(holding)
		to_chat(user, "<span class='notice'>You remove [holding] from [src].</span>")
		replace_tank(user, TRUE)

/obj/machinery/portable_atmospherics/examine(mob/user)
	..()
	if(holding)
		to_chat(user, "<span class='notice'>\The [src] contains [holding]. Alt-click [src] to remove it.</span>")
		to_chat(user, "<span class='notice'>Click [src] with another gas tank to hot swap [holding].</span>")

/obj/machinery/portable_atmospherics/proc/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	if(holding)
		holding.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(holding)
	if(new_tank)
		holding = new_tank
	else
		holding = null
	update_icon()
	return TRUE

/obj/machinery/portable_atmospherics/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank))
		if(!(stat & BROKEN))
			var/obj/item/tank/T = W
			if(!user.transferItemToLoc(T, src))
				return
			to_chat(user, "<span class='notice'>[holding ? "In one smooth motion you pop [holding] out of [src]'s connector and replace it with [T]" : "You insert [T] into [src]"].</span>")
			replace_tank(user, FALSE, T)
			update_icon()
	else if(istype(W, /obj/item/wrench))
		if(!(stat & BROKEN))
			if(connected_port)
				disconnect()
				W.play_tool_sound(src)
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
				W.play_tool_sound(src)
				user.visible_message( \
					"[user] connects [src].", \
					"<span class='notice'>You fasten [src] to the port.</span>", \
					"<span class='italics'>You hear a ratchet.</span>")
				update_icon()
	else
		return ..()

/obj/machinery/portable_atmospherics/analyzer_act(mob/living/user, obj/item/I)
	atmosanalyzer_scan(air_contents, user, src)

/obj/machinery/portable_atmospherics/attacked_by(obj/item/I, mob/user)
	if(I.force < 10 && !(stat & BROKEN))
		take_damage(0)
	else
		investigate_log("was smacked with \a [I] by [key_name(user)].", INVESTIGATE_ATMOS)
		add_fingerprint(user)
		..()
