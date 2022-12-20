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

/// Value of /obj/machinery/airalarm/var/danger_level
#define AIR_ALARM_ALERT_NONE 0
#define AIR_ALARM_ALERT_MINOR 1
#define AIR_ALARM_ALERT_SEVERE 2
