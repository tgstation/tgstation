/// Component that floods gas when ignited by fire.
/datum/component/combustible_flooder
	// Gas type, molar count, and temperature. All self explanatory.
	var/gas_id
	var/gas_amount
	var/temp_amount

/datum/component/combustible_flooder/Initialize(initialize_gas_id, initialize_gas_amount, initialize_temp_amount)

	src.gas_id = initialize_gas_id
	src.gas_amount = initialize_gas_amount
	src.temp_amount = initialize_temp_amount

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby_react)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/flame_react)
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, .proc/projectile_react)
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), .proc/welder_react)
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_TURF_EXPOSE, .proc/hotspots_react)

/datum/component/combustible_flooder/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_FIRE_ACT)
	UnregisterSignal(parent, COMSIG_ATOM_BULLET_ACT)
	UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER))
	if(isturf(parent))
		UnregisterSignal(parent, COMSIG_TURF_EXPOSE)

/// Do the flooding. Trigger temperature is the temperature we will flood at if we dont have a temp set at the start. Trigger referring to whatever triggered it.
/datum/component/combustible_flooder/proc/flood(mob/user, trigger_temperature)
	var/delete_parent = TRUE
	var/turf/open/flooded_turf = get_turf(parent)

	// We do this check early so closed turfs are still be able to flood.
	if(isturf(parent)) // Walls and floors.
		var/turf/parent_turf = parent
		flooded_turf = parent_turf.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
		delete_parent = FALSE

	flooded_turf.atmos_spawn_air("[gas_id]=[gas_amount];TEMP=[temp_amount || trigger_temperature]")
	
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

	if(delete_parent && !QDELETED(parent))
		qdel(parent) // For things with the explodable component like plasma mats this isn't necessary, but there's no harm. 
	qdel(src)

/// fire_act reaction.
/datum/component/combustible_flooder/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	if(exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(null, exposed_temperature)

/// Hotspot reaction.
/datum/component/combustible_flooder/proc/hotspots_react(datum/source, air, exposed_temperature)
	SIGNAL_HANDLER

	if(exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(null, exposed_temperature)

/// Being attacked by something
/datum/component/combustible_flooder/proc/attackby_react(datum/source, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(thing.get_temperature() > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(user, thing.get_temperature())

/// Shot by something
/datum/component/combustible_flooder/proc/projectile_react(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.damage_type == BURN && !projectile.nodamage)
		flood(projectile.firer, 2500)

/// Welder check. Here because tool_act is higher priority than attackby.
/datum/component/combustible_flooder/proc/welder_react(datum/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	if(tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(user, tool.get_temperature())
		return COMPONENT_BLOCK_TOOL_ATTACK
