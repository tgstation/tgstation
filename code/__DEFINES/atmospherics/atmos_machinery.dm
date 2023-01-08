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
