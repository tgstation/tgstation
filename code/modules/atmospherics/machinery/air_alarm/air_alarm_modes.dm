GLOBAL_LIST_INIT(air_alarm_modes, init_air_alarm_modes())

/proc/init_air_alarm_modes()
	var/list/ret = list()
	for(var/mode_path in subtypesof(/datum/air_alarm_mode))
		ret[mode_path] = new mode_path
	return ret

/datum/air_alarm_mode
	var/name
	var/desc
	var/danger
	var/emag = FALSE

/datum/air_alarm_mode/proc/apply(area/applied)
	return

/datum/air_alarm_mode/filtering
	name = "Filtering"
	desc = "Scrubs out contaminants"
	danger = FALSE

/datum/air_alarm_mode/filtering/apply(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = TRUE
		vent.pressure_checks = ATMOS_EXTERNAL_BOUND
		vent.external_pressure_bound = ONE_ATMOSPHERE
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE
		scrubber.filter_types = list(/datum/gas/carbon_dioxide)
		scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
		scrubber.set_widenet(FALSE)

/datum/air_alarm_mode/contaminated
	name = "Contaminated"
	desc = "Scrubs out ALL contaminants quickly"
	danger = FALSE

/datum/air_alarm_mode/contaminated/apply(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = TRUE
		vent.pressure_checks = ATMOS_EXTERNAL_BOUND
		vent.external_pressure_bound = ONE_ATMOSPHERE
		vent.update_appearance(UPDATE_ICON)

	var/list/filtered = subtypesof(/datum/gas)
	filtered -= list(/datum/gas/oxygen, /datum/gas/nitrogen)
	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE
		scrubber.filter_types = filtered.Copy()
		scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
		scrubber.set_widenet(TRUE)

/datum/air_alarm_mode/draught
	name = "Draught"
	desc = "Siphons out air while replacing"
	danger = FALSE

/datum/air_alarm_mode/draught/apply(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = TRUE
		vent.pressure_checks = ATMOS_EXTERNAL_BOUND
		vent.external_pressure_bound = ONE_ATMOSPHERE * 2
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE
		scrubber.set_widenet(FALSE)
		scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)

/datum/air_alarm_mode/refill
	name = "Refill"
	desc = "Triple vent output"
	danger = TRUE

/datum/air_alarm_mode/refill/applied(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = TRUE
		vent.pressure_checks = ATMOS_EXTERNAL_BOUND
		vent.external_pressure_bound = ONE_ATMOSPHERE * 3
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE

		scrubber.filter_types = list(/datum/gas/carbon_dioxide)
		scrubber.set_widenet(FALSE)
		scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)

/datum/air_alarm_mode/cycle
	name = "Cycle"
	desc = "Siphons air before replacing"
	danger = TRUE

/datum/air_alarm_mode/cycle/apply(area/applied) // Same as panic siphon.
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = FALSE
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE
		scrubber.set_widenet(FALSE)
		scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)

/datum/air_alarm_mode/cycle/proc/replace(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = TRUE
		vent.pressure_checks = ATMOS_EXTERNAL_BOUND
		vent.external_pressure_bound = ONE_ATMOSPHERE
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE
		scrubber.filter_types = list(/datum/gas/carbon_dioxide)
		scrubber.set_scrubbing(ATMOS_DIRECTION_SCRUBBING)
		scrubber.set_widenet(FALSE)

/datum/air_alarm_mode/siphon
	name = "Siphon"
	desc = "Siphons air out of the room"
	danger = TRUE

/datum/air_alarm_mode/siphon/apply(area/applied)

/datum/air_alarm_mode/panic_siphon
	name = "Panic Siphon"
	desc = "Siphons air out of the room quickly"
	danger = TRUE

/datum/air_alarm_mode/panic_siphon/apply(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = FALSE
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = TRUE
		scrubber.set_widenet(FALSE)
		scrubber.set_scrubbing(ATMOS_DIRECTION_SIPHONING)

/datum/air_alarm_mode/off
	name = "Off"
	desc = "Shuts off vents and scrubbers"
	danger = FALSE

/datum/air_alarm_mode/off/apply(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = FALSE
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = FALSE
		scrubber.update_appearance(UPDATE_ICON)

/datum/air_alarm_mode/flood
	name = "Flood"
	desc = "Shuts off scrubbers and opens vents"
	danger = TRUE
	emag = TRUE

/datum/air_alarm_mode/flood/apply(area/applied)
	for (var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in applied.air_vents)
		vent.on = TRUE
		vent.pressure_checks = ATMOS_INTERNAL_BOUND
		vent.internal_pressure_bound = 0
		vent.update_appearance(UPDATE_ICON)

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber as anything in applied.air_scrubbers)
		scrubber.on = FALSE
		scrubber.update_appearance(UPDATE_ICON)
