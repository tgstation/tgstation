/// Used when an atmos machine has "external" selected.
/// Found in `pressure_checks` of vents and air alarms.
#define ATMOS_EXTERNAL_BOUND (1 << 0)

/// Used when an atmos machine has "internal" selected.
/// Found in `pressure_checks` of vents and air alarms.
#define ATMOS_INTERNAL_BOUND (1 << 1)

/// The maximum bound of an atmos machine.
/// Found in `pressure_checks` of vents and air alarms.
#define ATMOS_BOUND_MAX (ATMOS_EXTERNAL_BOUND | ATMOS_INTERNAL_BOUND)

/// Used when an atmos machine is siphoning out air.
/// Found in air alarms, vents, and scrubbers.
#define ATMOS_DIRECTION_SIPHONING 0

/// Used when a vent is releasing air.
/// Found in air alarms, vents, and scrubbers.
#define ATMOS_DIRECTION_RELEASING 1

/// Used when a scrubber is scrubbing air.
/// Found in air alarms, vents, and scrubbers.
#define ATMOS_DIRECTION_SCRUBBING 1

/// The max pressure of pumps.
#define ATMOS_PUMP_MAX_PRESSURE (ONE_ATMOSPHERE * 50)

// Value of [/obj/machinery/airalarm/var/danger_level] and retvals of [/datum/tlv/proc/check_value]
/// No TLV exceeded.
#define AIR_ALARM_ALERT_NONE 0
/// TLV warning exceeded but not hazardous.
#define AIR_ALARM_ALERT_WARNING 1
/// TLV hazard exceeded or someone pulled the switch.
#define AIR_ALARM_ALERT_HAZARD 2

// Air alarm buildstage [/obj/machinery/airalarm/buildstage]
/// Air alarm missing circuit
#define AIR_ALARM_BUILD_NO_CIRCUIT 0
/// Air alarm has circuit but is missing wires
#define AIR_ALARM_BUILD_NO_WIRES 1
/// Air alarm has all components but isn't completed
#define AIR_ALARM_BUILD_COMPLETE 2

// Fire alarm buildstage [/obj/machinery/firealarm/buildstage]
/// Fire alarm missing circuit
#define FIRE_ALARM_BUILD_NO_CIRCUIT 0
/// Fire alarm has circuit but is missing wires
#define FIRE_ALARM_BUILD_NO_WIRES 1
/// Fire alarm has all components but isn't completed
#define FIRE_ALARM_BUILD_SECURED 2

// Fault levels for air alarm display
/// Area faults clear
#define AREA_FAULT_NONE 0
/// Fault triggered by manual intervention (ie: fire alarm pull)
#define AREA_FAULT_MANUAL 1
/// Fault triggered automatically (ie: firedoor detection)
#define AREA_FAULT_AUTOMATIC 2

// threshold_type values for [/datum/tlv/proc/set_value]  and [/datum/tlv/proc/reset_value]
/// [/datum/tlv/var/warning_min]
#define TLV_VAR_WARNING_MIN (1 << 0)
/// [/datum/tlv/var/hazard_min]
#define TLV_VAR_HAZARD_MIN (1 << 1)
/// [/datum/tlv/var/warning_max]
#define TLV_VAR_WARNING_MAX (1 << 2)
/// [/datum/tlv/var/hazard_max]
#define TLV_VAR_HAZARD_MAX (1 << 3)
/// All the vars in [/datum/tlv]
#define TLV_VAR_ALL (TLV_VAR_WARNING_MIN | TLV_VAR_HAZARD_MIN | TLV_VAR_WARNING_MAX | TLV_VAR_HAZARD_MAX)

/// TLV datums will ignore variables set to this.
#define TLV_VALUE_IGNORE -1

#define CIRCULATOR_HOT 0
#define CIRCULATOR_COLD 1

///Default pressure, used in the UI to reset the settings
#define PUMP_DEFAULT_PRESSURE (ONE_ATMOSPHERE)
///Maximum settable pressure
#define PUMP_MAX_PRESSURE (PUMP_DEFAULT_PRESSURE * 25)
///Minimum settable pressure
#define PUMP_MIN_PRESSURE (PUMP_DEFAULT_PRESSURE / 10)
///What direction is the machine pumping (into pump/port or out to the tank/area)?
#define PUMP_IN TRUE
#define PUMP_OUT FALSE

///Max allowed pressure for canisters to release air per tick
#define CAN_MAX_RELEASE_PRESSURE (ONE_ATMOSPHERE * 25)
///Min allowed pressure for canisters to release air per tick
#define CAN_MIN_RELEASE_PRESSURE (ONE_ATMOSPHERE * 0.1)
