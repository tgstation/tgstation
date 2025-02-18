//A reference to this list is passed into area sound managers, and it's modified in a manner that preserves that reference in ash_storm.dm
GLOBAL_LIST_EMPTY(ash_storm_sounds)
GLOBAL_LIST_EMPTY(rain_storm_sounds)
GLOBAL_LIST_EMPTY(sand_storm_sounds)

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

/// Does weather have any type of processing related to mobs, turfs, or thunder?
#define IS_WEATHER_AESTHETIC(flags) (!(flags & (WEATHER_TURFS|WEATHER_MOBS|WEATHER_THUNDER)))

//WEATHER FLAGS
/// If weather will affect turfs
#define WEATHER_TURFS (1<<0)
/// If weather will affect mobs
#define WEATHER_MOBS (1<<1)
/// If weather will apply thunder strikes to turfs
#define WEATHER_THUNDER (1<<2)
/// If weather will be allowed to affect indoor areas
#define WEATHER_INDOORS (1<<3)
/// If weather is endless and can only be stopped manually
#define WEATHER_ENDLESS (1<<4)
/// If weather will be detected by a barometer
#define WEATHER_BAROMETER (1<<5)
