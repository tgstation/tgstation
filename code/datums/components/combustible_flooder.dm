/datum/component/combustible_flooder
	// Gas type, molar count, and temperature. All self explanatory.
	var/gas_name
	var/gas_amount
	var/temp_amount

	/// Whether we override the temp_amount or not. Currently implemented on plasma.
	var/override_temperature

/datum/component/combustible_flooder/Initialize(gas_name, gas_amount, temp_amount, override_temperature = FALSE)

	src.gas_name = gas_name
	src.gas_amount = gas_amount
	src.temp_amount = temp_amount
	src.override_temperature = override_temperature

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/flame_react)

/datum/component/combustible_flooder/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_FIRE_ACT)

/// Do the flooding. overriden_temperature is the temperature we are overriding the initialized variable with.
/datum/component/combustible_flooder/proc/flood(mob/user, overriden_temperature = temp_amount)
	var/turf/open/flooded_turf = get_turf(parent)
	if (override_temperature)
		temp_amount = overriden_temperature
	flooded_turf.atmos_spawn_air("[gas_name]=[gas_amount];TEMP=[temp_amount]")
	
	// Logging-related
	var/admin_message = "[parent] ignited in [ADMIN_VERBOSEJMP(flooded_turf)]"
	var/log_message = "[parent] ignited in [AREACOORD(flooded_turf)]"
	if(user)
		admin_message += " by [ADMIN_LOOKUPFLW(user)]"
		log_message += " by [key_name(user)]"
	else
		admin_message += " by fire"
		log_message += " by fire"
	message_admins(admin_message)
	log_game(log_message)
	
	// For floors
	if(isturf(parent))
		var/turf/K = parent
		K.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else
		qdel(parent)

/// Hotspot related flooding reaction.
/datum/component/combustible_flooder/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	if(exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(overriden_temperature = exposed_temperature)

/// Being attacked by something 
/datum/component/combustible_flooder/proc/attackby_react(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(thing.get_temperature() > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(user, thing.get_temperature())
