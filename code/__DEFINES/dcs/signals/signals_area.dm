// Area signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of area/proc/power_change(): ()
#define COMSIG_AREA_POWER_CHANGE "area_power_change"
///from base of area/Entered(): (atom/movable/arrived, area/old_area)
#define COMSIG_AREA_ENTERED "area_entered"
///from base of area/Exited(): (atom/movable/gone, direction)
#define COMSIG_AREA_EXITED "area_exited"
///from base of area/Entered(): (area/new_area). Sent to "area-sensitive" movables, see __DEFINES/traits.dm for info.
#define COMSIG_ENTER_AREA "enter_area"
///from base of area/Exited(): (area). Sent to "area-sensitive" movables, see __DEFINES/traits.dm for info.
#define COMSIG_EXIT_AREA "exit_area"

// Alarm listener datum signals
///Sent when an alarm is fired (alarm, area/source_area)
#define COMSIG_ALARM_TRIGGERED "comsig_alarm_triggered"
///Send when an alarm source is cleared (alarm_type, area/source_area)
#define COMSIG_ALARM_CLEARED "comsig_alarm_clear"

// Area fire signals
/// Sent when an area's fire var changes: (fire_value)
#define COMSIG_AREA_FIRE_CHANGED "area_fire_set"
