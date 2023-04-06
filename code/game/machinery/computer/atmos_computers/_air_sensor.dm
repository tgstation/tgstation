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
	.= ..()

	if (!istype(multi_tool))
		return .

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
