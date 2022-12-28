/obj/machinery/airalarm/proc/get_mode_name(mode_value)
	switch(mode_value)
		if(AALARM_MODE_SCRUBBING)
			return "Filtering"
		if(AALARM_MODE_CONTAMINATED)
			return "Contaminated"
		if(AALARM_MODE_VENTING)
			return "Draught"
		if(AALARM_MODE_REFILL)
			return "Refill"
		if(AALARM_MODE_PANIC)
			return "Panic Siphon"
		if(AALARM_MODE_REPLACEMENT)
			return "Cycle"
		if(AALARM_MODE_SIPHON)
			return "Siphon"
		if(AALARM_MODE_OFF)
			return "Off"
		if(AALARM_MODE_FLOOD)
			return "Flood"

/obj/machinery/airalarm/proc/apply_mode(atom/source)
	switch (mode)
		if (AALARM_MODE_SCRUBBING)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.filter_types = list(/datum/gas/carbon_dioxide)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
				scrubber.set_widenet(FALSE)
		if (AALARM_MODE_CONTAMINATED)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.filter_types = list(
					/datum/gas/carbon_dioxide,
					/datum/gas/miasma,
					/datum/gas/plasma,
					/datum/gas/water_vapor,
					/datum/gas/hypernoblium,
					/datum/gas/nitrous_oxide,
					/datum/gas/nitrium,
					/datum/gas/tritium,
					/datum/gas/bz,
					/datum/gas/pluoxium,
					/datum/gas/freon,
					/datum/gas/hydrogen,
					/datum/gas/healium,
					/datum/gas/proto_nitrate,
					/datum/gas/zauker,
					/datum/gas/helium,
					/datum/gas/antinoblium,
					/datum/gas/halon,
				)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
				scrubber.set_widenet(TRUE)
		if (AALARM_MODE_VENTING)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE * 2
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.set_widenet(FALSE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)
		if (AALARM_MODE_REFILL)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_EXTERNAL_BOUND
				vent.external_pressure_bound = ONE_ATMOSPHERE * 3
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE

				scrubber.filter_types = list(/datum/gas/carbon_dioxide)
				scrubber.set_widenet(FALSE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
		if (AALARM_MODE_PANIC, AALARM_MODE_REPLACEMENT)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = FALSE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.set_widenet(TRUE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)
		if (AALARM_MODE_SIPHON)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = FALSE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = TRUE
				scrubber.set_widenet(FALSE)
				scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)
		if (AALARM_MODE_OFF)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = FALSE
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = FALSE
				scrubber.update_appearance(UPDATE_ICON)
		if (AALARM_MODE_FLOOD)
			for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in my_area.air_vents)
				vent.on = TRUE
				vent.pressure_checks = ATMOS_INTERNAL_BOUND
				vent.internal_pressure_bound = 0
				vent.update_appearance(UPDATE_ICON)

			for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in my_area.air_scrubbers)
				scrubber.on = FALSE
				scrubber.update_appearance(UPDATE_ICON)

	SEND_SIGNAL(src, COMSIG_AIRALARM_UPDATE_MODE, source)
