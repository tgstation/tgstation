/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 60, ACID = 30)
	anchored = FALSE

	///Stores the gas mixture of the portable component
	var/datum/gas_mixture/air_contents
	///Stores the reference of the connecting port
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	///Stores the reference of the tank the machine is holding
	var/obj/item/tank/holding
	///Volume (in L) of the inside of the machine
	var/volume = 0

/obj/machinery/portable_atmospherics/Initialize()
	. = ..()
	air_contents = new
	air_contents.volume = volume
	air_contents.temperature = T20C
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/Destroy()
	SSair.stop_processing_machine(src)

	disconnect()
	qdel(air_contents)
	air_contents = null

	return ..()

/obj/machinery/portable_atmospherics/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return //Indestructable cans shouldn't release air
	if(severity == 1 || target == src)
		//This explosion will destroy the can, release its air.
		var/turf/T = get_turf(src)
		T.assume_air(air_contents)
		T.air_update_turf(FALSE, FALSE)

	return ..()

/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) // Pipe network handles reactions if connected.
		air_contents.react(src)

/obj/machinery/portable_atmospherics/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/return_analyzable_air()
	return air_contents

/**
 * Allow the portable machine to be connected to a connector
 * Arguments:
 * * new_port - the connector that we trying to connect to
 */
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
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/Move()
	. = ..()
	if(.)
		disconnect()

/**
 * Allow the portable machine to be disconnected from the connector
 */
/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	pixel_x = 0
	pixel_y = 0
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)) || !can_interact(user))
		return
	if(!holding)
		return
	to_chat(user, "<span class='notice'>You remove [holding] from [src].</span>")
	replace_tank(user, TRUE)

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	if(!holding)
		return
	. += "<span class='notice'>\The [src] contains [holding]. Alt-click [src] to remove it.</span>"+\
		"<span class='notice'>Click [src] with another gas tank to hot swap [holding].</span>"

/**
 * Allow the player to place a tank inside the machine.
 * Arguments:
 * * User: the player doing the act
 * * close_valve: used in the canister.dm file, check if the valve is open or not
 * * new_tank: the tank we are trying to put in the machine
 */
/obj/machinery/portable_atmospherics/proc/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	if(!user)
		return FALSE
	if(holding)
		user.put_in_hands(holding)
		holding = null
	if(new_tank)
		holding = new_tank
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(!istype(W, /obj/item/tank))
		return FALSE
	if(machine_stat & BROKEN)
		return FALSE
	var/obj/item/tank/T = W
	if(!user.transferItemToLoc(T, src))
		return FALSE
	to_chat(user, "<span class='notice'>[holding ? "In one smooth motion you pop [holding] out of [src]'s connector and replace it with [T]" : "You insert [T] into [src]"].</span>")
	investigate_log("had its internal [holding] swapped with [T] by [key_name(user)].", INVESTIGATE_ATMOS)
	replace_tank(user, FALSE, T)
	update_appearance()

/obj/machinery/portable_atmospherics/wrench_act(mob/living/user, obj/item/W)
	if(machine_stat & BROKEN)
		return FALSE
	if(connected_port)
		investigate_log("was disconnected from [connected_port] by [key_name(user)].", INVESTIGATE_ATMOS)
		disconnect()
		W.play_tool_sound(src)
		user.visible_message( \
			"[user] disconnects [src].", \
			"<span class='notice'>You unfasten [src] from the port.</span>", \
			"<span class='hear'>You hear a ratchet.</span>")
		update_appearance()
		return TRUE
	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(!possible_port)
		to_chat(user, "<span class='notice'>Nothing happens.</span>")
		return FALSE
	if(!connect(possible_port))
		to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
		return FALSE
	W.play_tool_sound(src)
	user.visible_message( \
		"[user] connects [src].", \
		"<span class='notice'>You fasten [src] to the port.</span>", \
		"<span class='hear'>You hear a ratchet.</span>")
	update_appearance()
	investigate_log("was connected to [possible_port] by [key_name(user)].", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/portable_atmospherics/attacked_by(obj/item/I, mob/user)
	if(I.force < 10 && !(machine_stat & BROKEN))
		take_damage(0)
	else
		investigate_log("was smacked with \a [I] by [key_name(user)].", INVESTIGATE_ATMOS)
		add_fingerprint(user)
		..()

/obj/machinery/portable_atmospherics/rad_act(strength)
	. = ..()
	var/gas_change = FALSE
	var/list/cached_gases = air_contents.gases
	if(cached_gases[/datum/gas/oxygen] && cached_gases[/datum/gas/carbon_dioxide])
		gas_change = TRUE
		var/pulse_strength = min(strength, cached_gases[/datum/gas/oxygen][MOLES] * 1000, cached_gases[/datum/gas/carbon_dioxide][MOLES] * 2000)
		cached_gases[/datum/gas/carbon_dioxide][MOLES] -= pulse_strength / 2000
		cached_gases[/datum/gas/oxygen][MOLES] -= pulse_strength / 1000
		ASSERT_GAS(/datum/gas/pluoxium, air_contents)
		cached_gases[/datum/gas/pluoxium][MOLES] += pulse_strength / 4000
		strength -= pulse_strength

	if(cached_gases[/datum/gas/hydrogen])
		gas_change = TRUE
		var/pulse_strength = min(strength, cached_gases[/datum/gas/hydrogen][MOLES] * 1000)
		cached_gases[/datum/gas/hydrogen][MOLES] -= pulse_strength / 1000
		ASSERT_GAS(/datum/gas/tritium, air_contents)
		cached_gases[/datum/gas/tritium][MOLES] += pulse_strength / 1000
		strength -= pulse_strength

	if(gas_change)
		air_contents.garbage_collect()
