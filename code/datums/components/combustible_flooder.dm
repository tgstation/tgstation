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

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby_react))
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, PROC_REF(flame_react))
	RegisterSignal(parent, COMSIG_ATOM_TOUCHED_SPARKS, PROC_REF(sparks_react))
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, PROC_REF(projectile_react))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(welder_react))
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_TURF_EXPOSE, PROC_REF(hotspots_react))

/datum/component/combustible_flooder/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
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

	flooded_turf.atmos_spawn_air("[gas_id]=[gas_amount];[TURF_TEMPERATURE((temp_amount || trigger_temperature))]")

	// Logging-related
	var/admin_message = "[flooded_turf] ignited in [ADMIN_VERBOSEJMP(flooded_turf)]"
	var/log_message = "ignited [flooded_turf]"
	if(user)
		admin_message += " by [ADMIN_LOOKUPFLW(user)]"
		user.log_message(log_message, LOG_ATTACK, log_globally = FALSE)//only individual log
	else
		log_message = "[key_name(user)] " + log_message + " by fire"
		admin_message += " by fire"
		log_attack(log_message)
	message_admins(admin_message)

	if(delete_parent && !QDELETED(parent))
		qdel(parent) // For things with the explodable component like plasma mats this isn't necessary, but there's no harm.
	qdel(src)

/// fire_act reaction.
/datum/component/combustible_flooder/proc/flame_react(datum/source, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER

	if(exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(null, exposed_temperature)

/// sparks_touched reaction.
/datum/component/combustible_flooder/proc/sparks_react(datum/source, obj/effect/particle_effect/sparks/sparks)
	SIGNAL_HANDLER

	if(sparks) // this shouldn't ever be false but existence is mysterious
		flood(null, FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)

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
/datum/component/combustible_flooder/proc/projectile_react(datum/source, obj/projectile/shot)
	SIGNAL_HANDLER

	if(shot.damage_type == BURN && shot.damage > 0)
		flood(shot.firer, 2500)

/// Welder check. Here because tool_act is higher priority than attackby.
/datum/component/combustible_flooder/proc/welder_react(datum/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	if(tool.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		flood(user, tool.get_temperature())
		return ITEM_INTERACT_BLOCKING
