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
	id_tag = chamber_id + "_sensor"
	return ..()

/obj/machinery/air_sensor/Destroy()
	. = ..()
	reset()

/obj/machinery/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"
	return ..()

/obj/machinery/air_sensor/proc/reset()
	if(GLOB.objects_by_id_tag[chamber_id + "_in"] != null)
		var/obj/machinery/atmospherics/components/unary/outlet_injector/injector = GLOB.objects_by_id_tag[chamber_id + "_in"]
		injector.disconnect_chamber()

	if(GLOB.objects_by_id_tag[chamber_id + "_out"] != null)
		var/obj/machinery/atmospherics/components/unary/vent_pump/pump  = GLOB.objects_by_id_tag[chamber_id + "_out"]
		pump.disconnect_chamber()


///right click with multi tool to disconnect everything
/obj/machinery/air_sensor/multitool_act_secondary(mob/living/user, obj/item/tool)
	to_chat(user,"You reset all I/O ports")
	reset()
	return TRUE

/obj/machinery/air_sensor/multitool_act(mob/living/user, obj/item/multitool/I)
	.= ..()

	if (istype(I))
		if(istype(I.buffer, /obj/machinery/atmospherics/components/unary/outlet_injector))
			var/obj/machinery/atmospherics/components/unary/outlet_injector/injector = I.buffer
			injector.chamber_id = chamber_id
			GLOB.objects_by_id_tag[chamber_id + "_in"] = injector
			to_chat(user, "You connect [injector] to the Input Port")

		else if(istype(I.buffer, /obj/machinery/atmospherics/components/unary/vent_pump))
			var/obj/machinery/atmospherics/components/unary/vent_pump/pump = I.buffer

			//so its no longer controlled by air alarm
			pump.disconnect_from_area()
			//configuration copied from /obj/machinery/atmospherics/components/unary/vent_pump/siphon
			pump.pump_direction = ATMOS_DIRECTION_SIPHONING
			pump.pressure_checks = ATMOS_INTERNAL_BOUND
			pump.internal_pressure_bound = 4000
			pump.external_pressure_bound = 0

			pump.chamber_id = chamber_id
			GLOB.objects_by_id_tag[chamber_id + "_out"] = pump
			to_chat(user, "You connect [pump] to the Output Port")

		return TRUE
