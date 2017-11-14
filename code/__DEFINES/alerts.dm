//Defines for alarms, see (code/datums/alarmlisteners.dm)
//Contains alarm/alert defines
#define ALARM_POWER  1
#define ALARM_FIRE  2
#define ALARM_ATMOS  3
#define ALARM_MOTION  4
#define ALARM_BURGLAR  5

//event types that a listener may want a hook on
//bitflag
#define ALARM_SOURCE_ADDED  1
#define ALARM_SOURCE_REMOVED  2
#define ALARM_CREATED  4
#define ALARM_CANCELLED  8
