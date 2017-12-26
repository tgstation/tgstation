// Helpers for checking whether a z-level conforms to a specific requirement

// Basic levels
#define is_centcom_level(z) ((z) == ZLEVEL_CENTCOM)

#define is_station_level(z) ((z) in GLOB.station_z_levels)

#define is_mining_level(z) ((z) == ZLEVEL_MINING)

#define is_reebe(z) ((z) == ZLEVEL_CITYOFCOGS)

#define is_transit_level(z) ((z) == ZLEVEL_TRANSIT)

#define is_away_level(z) ((z) > ZLEVEL_SPACEMAX)

// If true, the singularity cannot strip away asteroid turf on this Z
#define is_planet_level(z) (GLOB.z_is_planet["z"])
