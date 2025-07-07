//A reference to this list is passed into area sound managers, and it's modified in a manner that preserves that reference in ash_storm.dm
GLOBAL_LIST_EMPTY(ash_storm_sounds)
GLOBAL_LIST_EMPTY(rain_storm_sounds)
GLOBAL_LIST_EMPTY(sand_storm_sounds)
/// Tracks where we should play snowstorm sounds for the area sound listener
GLOBAL_LIST_EMPTY(snowstorm_sounds)
/// The wizard rain event can run multiple times so we use a global reagent whitelist to reuse the same list to boost performance
GLOBAL_LIST_EMPTY(wizard_rain_reagents)

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

/// The amount of reagent units that is applied when an object comes into contact with rain
#define WEATHER_REAGENT_VOLUME 5
/// Weather reagent volume applied to randomly selected turfs/objects is scaled by this multiplier to compensate for reduced processing frequency
#define TURF_REAGENT_VOLUME_MULTIPLIER 3

/// 1 / 400 chance for a turf to get a thunder strike per tick (death and destruction to mobs/equipment in area)
#define THUNDER_CHANCE_INSANE 0.0025
/// 1 / 1,000 chance for a turf to get a thunder strike per tick (damage to mobs/equipment in area)
#define THUNDER_CHANCE_HIGH 0.001
/// 1 / 5,000 chance for a turf to get a thunder strike per tick (sporadic damage to mobs/equipment in area)
#define THUNDER_CHANCE_AVERAGE 0.0002
/// 1 / 20,000 chance for a turf to get a thunder strike per tick (rare damage to mobs/equipment in area)
#define THUNDER_CHANCE_RARE 0.00005
/// 1 / 50,000 chance for a turf to get a thunder strike per tick (almost no damage to mobs/equipment in area)
#define THUNDER_CHANCE_VERY_RARE 0.00002

/// admin verb to control thunder via the run_weather command
GLOBAL_LIST_INIT(thunder_chance_options, list(
	"Relentless - The Sky is Angry, Very Angry" = THUNDER_CHANCE_INSANE,
	"Abundant - A shocking amount of thunder" = THUNDER_CHANCE_HIGH,
	"Regular - Standard Storm Activity" = THUNDER_CHANCE_AVERAGE,
	"Occasional - A polite amount of thunder" = THUNDER_CHANCE_RARE,
	"Rare - Like finding a four-leaf clover, but in the sky" = THUNDER_CHANCE_VERY_RARE,
	"None - Admin Safe Space (Thunder Disabled)" = NONE,
))

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
/// If weather temperature ignores clothing insulation when adjusting bodytemperature
#define WEATHER_TEMPERATURE_BYPASS_CLOTHING (1<<6)

/// Does weather have any type of processing related to mobs, turfs, or thunder?
#define FUNCTIONAL_WEATHER (WEATHER_TURFS|WEATHER_MOBS|WEATHER_THUNDER)
