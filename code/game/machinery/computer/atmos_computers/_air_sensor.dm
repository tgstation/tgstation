///Indicator for inlet port
#define INLET 1
///Indicator for outlet port
#define OUTLET 2

/// Gas tank air sensor.
/// These always hook to monitors, be mindful of them
/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF
	power_channel = AREA_USAGE_ENVIRON
	active_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.5

	/// The unique string that represents which atmos chamber to associate with.
	var/chamber_id
	/// The inlet[injector] controlled by this sensor
	var/inlet_id
	/// The outlet[vent pump] controlled by this sensor
	var/outlet_id
	/// The air alarm connected to this sensor
	var/obj/machinery/airalarm/connected_airalarm
	///Is this sensor on
	var/on = TRUE

/obj/machinery/air_sensor/Initialize(mapload)
	id_tag = assign_random_name()

	var/static/list/multitool_tips = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Link logged injectors/vents",
			SCREENTIP_CONTEXT_RMB = "Reset all I/O ports",
		)
	)
	AddElement(/datum/element/contextual_screentip_tools, multitool_tips)

	return ..()

/obj/machinery/air_sensor/post_machine_initialize()
	. = ..()

	//auto connect to any inlet & outlet devices within a 4 diameter radius from this sensor
	for(var/obj/machinery/atmospherics/components/unary/device in oview(4, src))
		if(inlet_id && outlet_id)
			break
		configure(device)

/**
 * Connects an injector or an vent pump to this air sensor. Must be on the same z level as sensor
 * return what type of port was configured or NONE for no op
 *
 * Arguments
 * * obj/machinery/atmospherics/components/unary/port - the device we are trying to connect to this sensor
 * * reconfigure - if TRUE it will override existing ports if they are already registered
*/
/obj/machinery/air_sensor/proc/configure(obj/machinery/atmospherics/components/unary/port, reconfigure = FALSE)
	PRIVATE_PROC(TRUE)
	if(!istype(port) || port.z != z)
		return NONE

	if(istype(port, /obj/machinery/atmospherics/components/unary/outlet_injector))
		if(!reconfigure && inlet_id)
			return INLET
		var/obj/machinery/atmospherics/components/unary/outlet_injector/input = port
		//only configure non maploaded injectors cause they already have a preset config
		if(input.type == /obj/machinery/atmospherics/components/unary/outlet_injector)
			input.volume_rate = MAX_TRANSFER_RATE
		inlet_id = input.id_tag
		return INLET

	else if(istype(port, /obj/machinery/atmospherics/components/unary/vent_pump))
		if(!reconfigure && outlet_id)
			return OUTLET
		var/obj/machinery/atmospherics/components/unary/vent_pump/output = port
		//only configure non maploaded vent pumps cause they already have a preset config
		if(output.type == /obj/machinery/atmospherics/components/unary/vent_pump)
			//so its no longer controlled by air alarm
			output.disconnect_from_area()
			//configuration copied from /obj/machinery/atmospherics/components/unary/vent_pump/siphon but with max pressure
			output.pump_direction = ATMOS_DIRECTION_SIPHONING
			output.pressure_checks = ATMOS_INTERNAL_BOUND
			output.internal_pressure_bound = MAX_OUTPUT_PRESSURE
			output.external_pressure_bound = 0
		//finally assign it to this sensor
		outlet_id = output.id_tag
		return OUTLET
	return NONE

/obj/machinery/air_sensor/Destroy()
	reset()
	return ..()

/obj/machinery/air_sensor/return_air()
	if(!on)
		return
	. = ..()
	use_energy(active_power_usage) //use power for analyzing gases

/obj/machinery/air_sensor/process()
	//update appearance according to power state
	if(machine_stat & NOPOWER)
		if(on)
			on = FALSE
			update_appearance()
	else if(!on)
		on = TRUE
		update_appearance()

/obj/machinery/air_sensor/examine(mob/user)
	. = ..()
	. += span_notice("Use a multitool to link it to an injector, vent, or air alarm, or reset its ports.")
	. += span_notice("Click with hand to turn it off.")

/obj/machinery/air_sensor/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	//switched off version of this air sensor but still anchored to the ground
	var/obj/item/air_sensor/sensor = new(drop_location())
	sensor.set_anchored(TRUE)
	sensor.balloon_alert(user, "sensor turned off")

	//delete self
	qdel(src)

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()

/obj/machinery/air_sensor/proc/reset()
	inlet_id = null
	outlet_id = null
	if(connected_airalarm)
		connected_airalarm.disconnect_sensor()
		// if air alarm and sensor were linked at roundstart we allow them to link to new devices
		connected_airalarm.allow_link_change = TRUE
		connected_airalarm = null

///right click with multi tool to disconnect everything
/obj/machinery/air_sensor/multitool_act_secondary(mob/living/user, obj/item/tool)
	reset()
	balloon_alert(user, "ports reset")
	return TRUE

/obj/machinery/air_sensor/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	. = ..()

	var/type = configure(multi_tool.buffer, TRUE)
	switch(type)
		if(INLET, OUTLET)
			var/port = "[type == INLET ? "input" : "output"] port"
			user.balloon_alert(user, "[port] configured")
			to_chat(user, span_notice("[src] has connected [multi_tool.buffer] to its [port]."))
	to_chat(user, span_notice("[src] has been added to multitool buffer."))
	multi_tool.set_buffer(src)

	return ITEM_INTERACT_SUCCESS

/**
 * A portable version of the /obj/machinery/air_sensor
 * Wrenching it & turning it on will convert it back to /obj/machinery/air_sensor
 * Unwelding /obj/machinery/air_sensor will turn it back to /obj/item/air_sensor
 * The logic is same as meters
 */
/obj/item/air_sensor
	name = "Air Sensor"
	desc = "A device designed to detect gases and their concentration in an area."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "gsensor0"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)

/obj/item/air_sensor/Initialize(mapload, inlet, outlet)
	. = ..()
	register_context()

/obj/item/air_sensor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unwrench" : "Wrench"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WELDER && !anchored)
		context[SCREENTIP_CONTEXT_LMB] = "Dismantle"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/air_sensor/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("It's [EXAMINE_HINT("wrenched")] in place")
	else
		. += span_notice("It should be [EXAMINE_HINT("wrenched")] in place to turn it on.")
	. +=  span_notice("It could be [EXAMINE_HINT("welded")] apart.")
	. +=  span_notice("Click with hand to turn it on.")

/obj/item/air_sensor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!anchored)
		return

	//List of air sensor's by name
	var/list/available_sensors = list()
	for(var/chamber_id in GLOB.station_gas_chambers)
		//don't let it conflict with existing distro & waste moniter meter's
		if(chamber_id == ATMOS_GAS_MONITOR_DISTRO)
			continue
		if(chamber_id == ATMOS_GAS_MONITOR_WASTE)
			continue
		available_sensors += GLOB.station_gas_chambers[chamber_id]

	//make the choice
	var/chamber_name = tgui_input_list(user, "Select Sensor Purpose", "Select Sensor ID", available_sensors)
	if(isnull(chamber_name))
		return

	//map chamber name back to id
	var/target_chamber
	for(var/chamber_id in GLOB.station_gas_chambers)
		if(GLOB.station_gas_chambers[chamber_id] != chamber_name)
			continue
		target_chamber = chamber_id
		break

	//build the sensor from the subtypes of sensor's available
	var/static/list/chamber_subtypes = null
	if(isnull(chamber_subtypes))
		chamber_subtypes = subtypesof(/obj/machinery/air_sensor)
	for(var/obj/machinery/air_sensor/sensor as anything in chamber_subtypes)
		if(initial(sensor.chamber_id) != target_chamber)
			continue

		//make real air sensor in its place
		var/obj/machinery/air_sensor/new_sensor = new sensor(get_turf(src))
		new_sensor.balloon_alert(user, "sensor turned on")
		qdel(src)

		break

/obj/item/air_sensor/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/item/air_sensor/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		return ITEM_INTERACT_BLOCKING

	loc.balloon_alert(user, "dismantling sensor")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 30, amount = 1))
		return ITEM_INTERACT_BLOCKING
	loc.balloon_alert(user, "sensor dismanteled")

	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/air_sensor/atom_deconstruct(disassembled)
	new /obj/item/analyzer(loc)
	new /obj/item/stack/sheet/iron(loc)

#undef INLET
#undef OUTLET
