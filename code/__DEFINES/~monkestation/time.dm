#define station_time_in_ticks (GLOB.roundstart_hour HOURS + round_duration_in_ticks)

#define SECOND *10
#define MINUTE *600
#define MINUTES *600

#define HOUR *36000
#define HOURS *36000

#define DAY *864000
#define DAYS *864000

/// The amount of ticks past since round start
#define ROUND_TIME_TICKS (world.time - SSticker.round_start_time)
/// Station time, in ticks
#define STATION_TIME_TICKS (ROUND_TIME_TICKS + SSticker.gametime_offset)
