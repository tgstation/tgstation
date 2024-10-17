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

/// The heat capacity used by T1 thermomachines
#define THERMOMACHINE_HEAT_CAPACITY (5000)

/// The minimum temperature telecomms equipment can operate in (40K)
#define TCOMMS_EQUIPMENT_TEMP_MIN (TCOMMS_ROOM_TEMP - 40)
/// The maximum temperature telecomms equipment can operate in (120K)
#define TCOMMS_EQUIPMENT_TEMP_MAX (TCOMMS_ROOM_TEMP + 40)
/// The temperature telecomms equipment generates while active (480K)
#define TCOMMS_EQUIPMENT_TEMP_HEAT (TCOMMS_ROOM_TEMP + 400)
/// The heat capacity needed to cause the telecomms turf to overheat
#define TCOMMS_EQUIPMENT_HEAT_CAPACITY_TOTAL (6000)
/// The amount of messsages per minute we can send before TCOMM equipment starts to overheat/clog
#define TCOMM_MESSAGES_PER_MINUTE (150)
/// The heat capacity telecomms equipment generates while active
#define TCOMMS_EQUIPMENT_HEAT_CAPACITY (TCOMMS_EQUIPMENT_HEAT_CAPACITY_TOTAL / TCOMM_MESSAGES_PER_MINUTE)

/**
Factors:
- There are 24 TCOMM machines in a telecomms area used to process signals and data
- Sending one radio message will activate ~5 machines that will generate heat
- There are 20-100 empty turfs in the telecomms room depending on the map
- Empty turfs in TCOMMs area affect how long it takes to heat or cool the equipment since the air gets spread around
- TCOMM machines won't emit heat at the same time (ex. command bus machine needs the :C freq to activate)
- Thermomachine start at 73K but heat exchange pipes slowly reverts temperature to 93K (20K efficency loss)
- The heat exchange pipes at roundstart have room temp air and it takes a few minutes before they reach 73K

TCOMM_MESSAGES_PER_MINUTE is the amount of messages we want TCOMMs to handle before it clogs due to heat.

Radio Frequency Observations:
- Average pop at ~50 players emit rougly 10-20 TCOMM messages a minute, 30 at peak volume from eyeballing logs (+30)
- Poly spams ~5 TCOMM messages a minute (+10)
- Radio spam from air alarms will emit a message about once every ~10 seconds if intercom on and nearby (+10)
- Radio spam from a bunch of machinery cryo tubes, beepsky, medibot, cargo shipments, arrivals announcment, etc. (+30)
- PDA messages are relayed to TCOMMs equipment which also generate heat per message (+10)
- We also want to account for people trying to spam using multiple radios (+10)

So aiming for 100 TCOMM messages a minute gives us wiggle room with redundancies
**/

/// The minimum temperature RD servers can operate in (140K)
#define RD_SERVER_TEMP_MIN (ICEBOX_MIN_TEMPERATURE - 40)
/// The maximum temperature RD servers can operate in (220K)
#define RD_SERVER_TEMP_MAX (ICEBOX_MIN_TEMPERATURE + 40)
/// The temperature RD servers generates while active (260K)
#define RD_SERVER_TEMP_HEAT (RD_SERVER_TEMP_MAX + 40)
/// The heat capacity RD servers generates while active
#define RD_SERVER_HEAT_CAPACITY (5)
