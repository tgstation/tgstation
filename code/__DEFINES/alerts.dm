//Contains alarm/alert defines
ALARM_POWER = 1
ALARM_FIRE = 2
ALARM_ATMOS = 3
ALARM_MOTION = 4
ALARM_BURGLAR = 5

//event types that a listener may want a hook on
//bitflag for conciseness and speed
ALARM_SOURCE_ADDED = 1 << 1
ALARM_SOURCE_REMOVED = 1 << 2
ALARM_CREATED = 1 << 3
ALARM_CANCELLED = 1 << 4

