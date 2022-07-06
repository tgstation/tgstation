/// The amount of minutes in an hour
#define HOUR_INCREMENT 60
/// The time at which  we reset to 0
#define MIDNIGHT_RESET 24
/// How many minutes we add to the time every subsystem fire
#define SUBSYSTEM_FIRE_INCREMENT 10

// Day/Night parameters, mostly used for the traits
/// The point at which daytime starts
#define DAYTIME_START 8 // 8 AM
/// The point at which daytime ends
#define DAYTIME_END 20 // 8 PM
/// The point at which nighttime starts
#define NIGHTTIME_START 21 // 9 PM
/// The point at which nighttime ends
#define NIGHTTIME_END 7 // 7 AM

#define MINIMUM_LIGHT_FOR_LUMINOSITY 100

#define AREA_DAY_NIGHT_INDEX_BITFIELD "bitfield"
#define AREA_DAY_NIGHT_INDEX_APPEARANCE "appearance"
