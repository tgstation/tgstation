/// Gas tank air sensor.
/// These always hook to monitors, be mindful of them
/obj/machinery/air_sensor
	name = "gas sensor"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	resistance_flags = FIRE_PROOF

	var/on = TRUE

	/// The unique string that represents which atmos chamber to associate with.
	var/chamber_id

	// When turned off it create's an air sensor that drop's content's on welding
	var/drop_contents = FALSE

/obj/machinery/air_sensor/Initialize(mapload)
	id_tag = CHAMBER_SENSOR_FROM_ID(chamber_id)
	var/static/list/multitool_tips = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Link logged injectors/vents",
			SCREENTIP_CONTEXT_RMB = "Reset all I/O ports",
		)
	)
	AddElement(/datum/element/contextual_screentip_tools, multitool_tips)
	return ..()

/obj/machinery/air_sensor/Destroy()
	reset()
	return ..()

/obj/machinery/air_sensor/examine(mob/user)
	. = ..()
	. += span_notice("Use multitool to link it to an injector/vent or reset it's ports")
	. += span_notice("Attack with hand to turn it off.")

/obj/machinery/air_sensor/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	//switched off version of this air sensor but still anchored to the ground
	var/obj/item/air_sensor/sensor = new(drop_location())
	sensor.drop_contents = drop_contents
	sensor.set_anchored(TRUE)
	sensor.balloon_alert(user, "sensor turned off")

	//delete self
	qdel(src)

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()

/obj/machinery/air_sensor/proc/reset()
	var/input_id = CHAMBER_INPUT_FROM_ID(chamber_id)
	if(GLOB.objects_by_id_tag[input_id] != null)
		var/obj/machinery/atmospherics/components/unary/outlet_injector/injector = GLOB.objects_by_id_tag[input_id]
		injector.disconnect_chamber()

	var/output_id = CHAMBER_OUTPUT_FROM_ID(chamber_id)
	if(GLOB.objects_by_id_tag[output_id] != null)
		var/obj/machinery/atmospherics/components/unary/vent_pump/pump  = GLOB.objects_by_id_tag[output_id]
		pump.disconnect_chamber()


///right click with multi tool to disconnect everything
/obj/machinery/air_sensor/multitool_act_secondary(mob/living/user, obj/item/tool)
	balloon_alert(user, "reset ports")
	reset()
	return TRUE

/obj/machinery/air_sensor/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	. = ..()

	if(istype(multi_tool.buffer, /obj/machinery/atmospherics/components/unary/outlet_injector))
		var/obj/machinery/atmospherics/components/unary/outlet_injector/input = multi_tool.buffer
		input.chamber_id = chamber_id
		GLOB.objects_by_id_tag[CHAMBER_INPUT_FROM_ID(chamber_id)] = input
		balloon_alert(user, "connected to input")

	else if(istype(multi_tool.buffer, /obj/machinery/atmospherics/components/unary/vent_pump))
		var/obj/machinery/atmospherics/components/unary/vent_pump/output = multi_tool.buffer
		//so its no longer controlled by air alarm
		output.disconnect_from_area()
		//configuration copied from /obj/machinery/atmospherics/components/unary/vent_pump/siphon
		output.pump_direction = ATMOS_DIRECTION_SIPHONING
		output.pressure_checks = ATMOS_INTERNAL_BOUND
		output.internal_pressure_bound = 4000
		output.external_pressure_bound = 0
		output.chamber_id = chamber_id
		GLOB.objects_by_id_tag[CHAMBER_OUTPUT_FROM_ID(chamber_id)] = output
		balloon_alert(user, "connected to output")

	return TRUE

/obj/item/air_sensor
	name = "Air Sensor"
	desc = "It's an switched off air sensor."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor0"
	//should we drop an gas analyzer & metal sheet on unwelding. FALSE when it's made an RPED to stop free material drops
	var/drop_contents = FALSE

/obj/item/air_sensor/Initialize(mapload)
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

/obj/item/air_sensor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!anchored)
		return

	//Each air sensor has a unique ID so find how many unique ID's we have left.
	var/list/available_sensors = list()
	for(var/chamber_id in GLOB.station_gas_chambers)
		if(GLOB.objects_by_id_tag[CHAMBER_SENSOR_FROM_ID(chamber_id)] != null)
			continue
		available_sensors += GLOB.station_gas_chambers[chamber_id]
	//none left
	if(!available_sensors.len)
		user.balloon_alert(user, "no unique id's for sensors available!")
		return

	//make the choice
	var/chamber_name = tgui_input_list(user, "Select Gas Sensor", "Select Sensor ID", available_sensors)
	if(isnull(chamber_name))
		return

	//map chamber name back to id
	var/target_chamber
	for(var/chamber_id in GLOB.station_gas_chambers)
		if(GLOB.station_gas_chambers[chamber_id] != chamber_name)
			continue
		//id was taken at some point during input list selection
		if(GLOB.objects_by_id_tag[CHAMBER_SENSOR_FROM_ID(chamber_id)] != null)
			user.balloon_alert(user, "sensor already exists in world!")
			return
		target_chamber = chamber_id
		break

	//build the sensor from the subtypes of sensor's available
	var/static/list/chamber_subtypes = null
	if(isnull(chamber_subtypes))
		chamber_subtypes = subtypesof(/obj/machinery/air_sensor)
	for(var/obj/machinery/air_sensor/sensor as anything in chamber_subtypes)
		if(initial(sensor.chamber_id) != target_chamber)
			continue

		//make real air sensor in it's place
		var/obj/machinery/air_sensor/new_sensor = new sensor(get_turf(src))
		new_sensor.drop_contents = drop_contents
		new_sensor.balloon_alert(user, "sensor turned on")

		qdel(src)
		break

/obj/item/air_sensor/wrench_act(mob/living/user, obj/item/tool)
	//when wrenching this via RPED it's instant
	if(default_unfasten_wrench(user, tool, time = istype(tool, /obj/item/pipe_dispenser) ? 0 : 20) == SUCCESSFUL_UNFASTEN)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return

/obj/item/air_sensor/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		return

	loc.balloon_alert(user, "[drop_contents ? "Dismantling" : "Destroying"] Sensor")
	if(!tool.use_tool(src, user, 20, volume = 30, amount = 1))
		return
	loc.balloon_alert(user, "Sensor [drop_contents ? "Dismanteled" : "Destroyed"]")

	deconstruct(TRUE)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/air_sensor/deconstruct(disassembled)
	if(!(flags_1 & NODECONSTRUCT_1) && drop_contents)
		new /obj/item/analyzer(loc)
		new /obj/item/stack/sheet/iron(loc, 1)
	return ..()

// only crafted air sensors can drop stuff on deconstruction and not the ones made by the RPED else player's would get free stuff
/obj/item/air_sensor/crafted
	drop_contents = TRUE
