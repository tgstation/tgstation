// Most of these are lazy instances shared across air alarms so we dont need to instantiate unneeded datums.

/datum/alarm_threshold/universal/no_checks
	warning_min = AIR_ALARM_THRESHOLD_IGNORE
	hazard_min = AIR_ALARM_THRESHOLD_IGNORE
	warning_max = AIR_ALARM_THRESHOLD_IGNORE
	hazard_max = AIR_ALARM_THRESHOLD_IGNORE

/datum/alarm_threshold/universal/oxygen
	warning_min = 19
	hazard_min = 16
	warning_max = 1000
	hazard_max = 1000

/datum/alarm_threshold/universal/normal_gas
	warning_min = AIR_ALARM_THRESHOLD_IGNORE
	hazard_min = AIR_ALARM_THRESHOLD_IGNORE
	warning_max = 1000
	hazard_max = 1000

/datum/alarm_threshold/universal/dangerous_gas
	warning_min = AIR_ALARM_THRESHOLD_IGNORE
	hazard_min = AIR_ALARM_THRESHOLD_IGNORE
	warning_max = MOLES_GAS_VISIBLE - 0.05
	hazard_max = 0.5

/datum/alarm_threshold/universal/pressure
	warning_min = WARNING_LOW_PRESSURE
	hazard_min = HAZARD_LOW_PRESSURE
	warning_max = WARNING_HIGH_PRESSURE
	hazard_max = HAZARD_HIGH_PRESSURE

/datum/alarm_threshold/universal/temperature
	warning_min = BODYTEMP_COLD_WARNING_1
	hazard_min = BODYTEMP_COLD_WARNING_1 + 10
	warning_max = BODYTEMP_HEAT_WARNING_1 - 27
	hazard_max = BODYTEMP_HEAT_WARNING_1

GLOBAL_LIST_INIT(alarm_thresholds, list(
	/datum/alarm_threshold/universal/no_checks = new /datum/alarm_threshold/universal/no_checks,
	/datum/alarm_threshold/universal/oxygen = new /datum/alarm_threshold/universal/oxygen,
	/datum/alarm_threshold/universal/normal_gas = new /datum/alarm_threshold/universal/normal_gas,
	/datum/alarm_threshold/universal/dangerous_gas = new /datum/alarm_threshold/universal/dangerous_gas,
	/datum/alarm_threshold/universal/pressure = new /datum/alarm_threshold/universal/pressure,
	/datum/alarm_threshold/universal/temperature = new /datum/alarm_threshold/universal/temperature,
))

GLOBAL_DATUM_INIT(alarm_threshold_collection, /datum/alarm_threshold_collection/universal, new /datum/alarm_threshold_collection/universal)

// These however, are not shared instances. Just sybtyped for convenience.

/// Non hazardous cold room
/datum/alarm_threshold_collection/cold_room

/datum/alarm_threshold_collection/cold_room/New()
	. = ..()
	/// Pressure in kPa, corresponds to [/datum/gas_mixture/var/pressure].
	thresholds["pressure"] = new /datum/alarm_threshold(TRUE, ONE_ATMOSPHERE * 0.8, ONE_ATMOSPHERE *  0.9, ONE_ATMOSPHERE * 1.1, ONE_ATMOSPHERE * 1.2)
	/// Temperatures in kelvin, corresponds to [/datum/gas_mixture/var/temperature].
	thresholds["temperature"] = new /datum/alarm_threshold(TRUE, COLD_ROOM_TEMP-40, COLD_ROOM_TEMP-20, COLD_ROOM_TEMP+20, COLD_ROOM_TEMP+40)

/datum/alarm_threshold_collection/coldest

/datum/alarm_threshold_collection/coldest/New()
	. = ..()
	thresholds["pressure"].set_value(AIR_ALARM_THRESHOLD_WARNING_MIN & AIR_ALARM_THRESHOLD_HAZARD_MIN, AIR_ALARM_THRESHOLD_IGNORE)
	thresholds["temperature"].set_value(AIR_ALARM_THRESHOLD_WARNING_MIN & AIR_ALARM_THRESHOLD_HAZARD_MIN, AIR_ALARM_THRESHOLD_IGNORE)

/datum/alarm_threshold_collection/hottest

/datum/alarm_threshold_collection/hottest/New()
	. = ..()
	thresholds["pressure"].set_value(AIR_ALARM_THRESHOLD_WARNING_MAX & AIR_ALARM_THRESHOLD_HAZARD_MAX, AIR_ALARM_THRESHOLD_IGNORE)
	thresholds["temperature"].set_value(AIR_ALARM_THRESHOLD_WARNING_MAX & AIR_ALARM_THRESHOLD_HAZARD_MAX, AIR_ALARM_THRESHOLD_IGNORE)

