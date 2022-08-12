#define PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT 0

/obj/machinery/portable_atmospherics
	name = "portable_atmospherics"
	icon = 'icons/obj/atmos.dmi'
	use_power = NO_POWER_USE
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 60, ACID = 30)
	anchored = FALSE

	///Stores the gas mixture of the portable component. Don't access this directly, use return_air() so you support the temporary processing it provides
	var/datum/gas_mixture/air_contents
	///Stores the reference of the connecting port
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	///Stores the reference of the tank the machine is holding
	var/obj/item/tank/holding
	///Volume (in L) of the inside of the machine
	var/volume = 0
	///Used to track if anything of note has happen while running process_atmos(). 
	///Treat it as a process_atmos() scope var, we just declare it here to pass it between parent calls.
	///Should be false on start of every process_atmos() proc, since true means we'll process again next tick.
	var/excited = FALSE

	/// Max amount of heat allowed inside the machine before it starts to melt. [PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT] is special value meaning we are immune.
	var/temp_limit = 10000
	/// Max amount of pressure allowed inside of the canister before it starts to break. [PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT] is special value meaning we are immune.
	var/pressure_limit = 500000

/obj/machinery/portable_atmospherics/Initialize(mapload)
	. = ..()
	air_contents = new
	air_contents.volume = volume
	air_contents.temperature = T20C
	SSair.start_processing_machine(src)

/obj/machinery/portable_atmospherics/Destroy()
	disconnect()
	air_contents = null
	SSair.stop_processing_machine(src)

	return ..()

/obj/machinery/portable_atmospherics/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE //Indestructible cans shouldn't release air

	if(severity == EXPLODE_DEVASTATE || target == src)
		//This explosion will destroy the can, release its air.
		var/turf/local_turf = get_turf(src)
		local_turf.assume_air(air_contents)

	return ..()

/obj/machinery/portable_atmospherics/process_atmos()
	excited = (excited | air_contents.react(src))
	if(!excited)
		return PROCESS_KILL
	excited = FALSE

/// Take damage if a variable is exceeded. Damage is equal to temp/limit * heat/limit.
/// The damage multiplier is treated as 1 if something is being ignored while the other one is exceeded.
/// On most cases only one will be exceeded, so the other one is scaled down.
/obj/machinery/portable_atmospherics/proc/take_atmos_damage()
	var/taking_damage = FALSE

	var/temp_damage = 1
	var/pressure_damage = 1

	if(temp_limit != PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT)
		temp_damage = air_contents.temperature / temp_limit
		taking_damage = temp_damage > 1

	if(pressure_limit != PORTABLE_ATMOS_IGNORE_ATMOS_LIMIT)
		pressure_damage = air_contents.return_pressure() / pressure_limit
		taking_damage = taking_damage || pressure_damage > 1

	if(!taking_damage)
		return FALSE

	take_damage(clamp(temp_damage * pressure_damage, 5, 50), BURN, 0)
	return TRUE

/obj/machinery/portable_atmospherics/return_air()
	SSair.start_processing_machine(src)
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

	set_anchored(TRUE) //Prevent movement
	pixel_x = new_port.pixel_x
	pixel_y = new_port.pixel_y

	SSair.start_processing_machine(src)
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
	set_anchored(FALSE)
	connected_port.connected_device = null
	connected_port = null
	pixel_x = 0
	pixel_y = 0

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)) || !can_interact(user))
		return
	if(!holding)
		return
	to_chat(user, span_notice("You remove [holding] from [src]."))
	replace_tank(user, TRUE)

/obj/machinery/portable_atmospherics/examine(mob/user)
	. = ..()
	if(!holding)
		return
	. += span_notice("\The [src] contains [holding]. Alt-click [src] to remove it.")+\
		span_notice("Click [src] with another gas tank to hot swap [holding].")

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
		UnregisterSignal(holding, COMSIG_PARENT_QDELETING)
		holding = null
	if(new_tank)
		holding = new_tank
		RegisterSignal(holding, COMSIG_PARENT_QDELETING, .proc/unregister_holding)

	SSair.start_processing_machine(src)
	update_appearance()
	return TRUE

/obj/machinery/portable_atmospherics/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/tank))
		return ..()
	if(machine_stat & BROKEN)
		return FALSE
	var/obj/item/tank/insert_tank = item
	if(!user.transferItemToLoc(insert_tank, src))
		return FALSE
	to_chat(user, span_notice("[holding ? "In one smooth motion you pop [holding] out of [src]'s connector and replace it with [insert_tank]" : "You insert [insert_tank] into [src]"]."))
	investigate_log("had its internal [holding] swapped with [insert_tank] by [key_name(user)].", INVESTIGATE_ATMOS)
	replace_tank(user, FALSE, insert_tank)
	update_appearance()

/obj/machinery/portable_atmospherics/wrench_act(mob/living/user, obj/item/wrench)
	if(machine_stat & BROKEN)
		return FALSE
	if(connected_port)
		investigate_log("was disconnected from [connected_port] by [key_name(user)].", INVESTIGATE_ATMOS)
		disconnect()
		wrench.play_tool_sound(src)
		user.visible_message( \
			"[user] disconnects [src].", \
			span_notice("You unfasten [src] from the port."), \
			span_hear("You hear a ratchet."))
		update_appearance()
		return TRUE
	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
	if(!possible_port)
		to_chat(user, span_notice("Nothing happens."))
		return FALSE
	if(!connect(possible_port))
		to_chat(user, span_notice("[name] failed to connect to the port."))
		return FALSE
	wrench.play_tool_sound(src)
	user.visible_message( \
		"[user] connects [src].", \
		span_notice("You fasten [src] to the port."), \
		span_hear("You hear a ratchet."))
	update_appearance()
	investigate_log("was connected to [possible_port] by [key_name(user)].", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/portable_atmospherics/attacked_by(obj/item/item, mob/user)
	if(item.force < 10 && !(machine_stat & BROKEN))
		take_damage(0)
		return
	investigate_log("was smacked with \a [item] by [key_name(user)].", INVESTIGATE_ATMOS)
	add_fingerprint(user)
	return ..()

/// Holding tanks can get to zero integrity and be destroyed without other warnings due to pressure change.
/// This checks for that case and removes our reference to it.
/obj/machinery/portable_atmospherics/proc/unregister_holding()
	SIGNAL_HANDLER

	UnregisterSignal(holding, COMSIG_PARENT_QDELETING)
	holding = null
