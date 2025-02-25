//A reference to this list is passed into area sound managers, and it's modified in a manner that preserves that reference in ash_storm.dm
GLOBAL_LIST_EMPTY(ash_storm_sounds)
GLOBAL_LIST_EMPTY(rain_storm_sounds)
GLOBAL_LIST_EMPTY(sand_storm_sounds)
/// Tracks where we should play snowstorm sounds for the area sound listener
GLOBAL_LIST_EMPTY(snowstorm_sounds)

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

/// The amount of reagent units that is applied when an object comes into contact with rain
#define RAIN_REAGENT_VOLUME 5

/// 1 / 400 chance for a turf to get a lighting strike per tick
#define THUNDER_CHANCE_INSANE 0.0025
/// 1 / 1,000 chance for a turf to get a lighting strike per tick
#define THUNDER_CHANCE_HIGH 0.001
/// 1 / 5,000 chance for a turf to get a lighting strike per tick
#define THUNDER_CHANCE_AVERAGE 0.0002
/// 1 / 20,000 chance for a turf to get a lighting strike per tick
#define THUNDER_CHANCE_RARE 0.00005
/// 1 / 50,000 chance for a turf to get a lighting strike per tick
#define THUNDER_CHANCE_VERY_RARE 0.00002

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
/// If weather provides a notification message to mobs
#define WEATHER_NOTIFICATION (1<<6)
