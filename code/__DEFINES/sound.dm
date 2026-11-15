//max channel is 1024. Only go lower from here, because byond tends to pick the first available channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_ADMIN 1023
#define CHANNEL_VOX 1022
#define CHANNEL_JUKEBOX 1021
#define CHANNEL_HEARTBEAT 1020 //sound channel for heartbeats
#define CHANNEL_BOSS_MUSIC 1019
#define CHANNEL_AMBIENCE 1018
#define CHANNEL_BUZZ 1017
#define CHANNEL_TRAITOR 1016
#define CHANNEL_CHARGED_SPELL 1015
#define CHANNEL_ELEVATOR 1014
#define CHANNEL_ESCAPEMENU 1013
#define CHANNEL_WEATHER 1012
//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED
#define CHANNEL_HIGHEST_AVAILABLE 1011

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

/* Calculates the volume of a sound based on distance
 *
 * https://www.desmos.com/calculator/ing6lxgd0m Update this when changed please
 *
 * Arguments:
 * * volume: The initial volume of the sound being played
 * * distance: How far away the sound is in tiles from the source
 * * falloff_distance: Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * falloff_exponent: Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * Returns: The max distance of a sound based on audible volume range
 */
#define CALCULATE_SOUND_VOLUME_RATIO(volume, distance, max_distance, falloff_distance, falloff_exponent)\
	((max(distance - falloff_distance, 0) / (max(max_distance, distance) - falloff_distance)) ** (1 / falloff_exponent))

///Default range of a sound.
#define SOUND_RANGE 15
#define MEDIUM_RANGE_SOUND_EXTRARANGE -3
///default extra range for sounds considered to be quieter
#define SHORT_RANGE_SOUND_EXTRARANGE -7
///The range deducted from sound range for things that are considered silent / sneaky
#define SILENCED_SOUND_EXTRARANGE -10
///Percentage of sound's range where no falloff is applied
#define SOUND_DEFAULT_FALLOFF_DISTANCE 0 //Disabled because it doesn't actually have a nice effect, it just makes the jump to fall-off more shocking. maybe delete
///The default exponent of sound falloff
#define SOUND_FALLOFF_EXPONENT 2.5

#define SOUND_MINIMUM_PRESSURE 10

#define INTERACTION_SOUND_RANGE_MODIFIER -3
#define LIQUID_SLOSHING_SOUND_VOLUME 10
#define PICKUP_SOUND_VOLUME 15
#define DROP_SOUND_VOLUME 20
#define EQUIP_SOUND_VOLUME 30
#define HALFWAY_SOUND_VOLUME 50
#define BLOCK_SOUND_VOLUME 70
#define YEET_SOUND_VOLUME 90

#define AMBIENCE_GENERIC "generic"
#define AMBIENCE_HOLY "holy"
#define AMBIENCE_DANGER "danger"
#define AMBIENCE_RUINS "ruins"
#define AMBIENCE_ENGI "engi"
#define AMBIENCE_MINING "mining"
#define AMBIENCE_ICEMOON "icemoon"
#define AMBIENCE_MEDICAL "med"
#define AMBIENCE_VIROLOGY "viro"
#define AMBIENCE_SPOOKY "spooky"
#define AMBIENCE_SPACE "space"
#define AMBIENCE_MAINT "maint"
#define AMBIENCE_AWAY "away"
#define AMBIENCE_REEBE "reebe" //unused
#define AMBIENCE_CREEPY "creepy" //not to be confused with spooky

//default byond sound environments
#define SOUND_ENVIRONMENT_NONE -1
#define SOUND_ENVIRONMENT_GENERIC 0
#define SOUND_ENVIRONMENT_PADDED_CELL 1
#define SOUND_ENVIRONMENT_ROOM 2
#define SOUND_ENVIRONMENT_BATHROOM 3
#define SOUND_ENVIRONMENT_LIVINGROOM 4
#define SOUND_ENVIRONMENT_STONEROOM 5
#define SOUND_ENVIRONMENT_AUDITORIUM 6
#define SOUND_ENVIRONMENT_CONCERT_HALL 7
#define SOUND_ENVIRONMENT_CAVE 8
#define SOUND_ENVIRONMENT_ARENA 9
#define SOUND_ENVIRONMENT_HANGAR 10
#define SOUND_ENVIRONMENT_CARPETED_HALLWAY 11
#define SOUND_ENVIRONMENT_HALLWAY 12
#define SOUND_ENVIRONMENT_STONE_CORRIDOR 13
#define SOUND_ENVIRONMENT_ALLEY 14
#define SOUND_ENVIRONMENT_FOREST 15
#define SOUND_ENVIRONMENT_CITY 16
#define SOUND_ENVIRONMENT_MOUNTAINS 17
#define SOUND_ENVIRONMENT_QUARRY 18
#define SOUND_ENVIRONMENT_PLAIN 19
#define SOUND_ENVIRONMENT_PARKING_LOT 20
#define SOUND_ENVIRONMENT_SEWER_PIPE 21
#define SOUND_ENVIRONMENT_UNDERWATER 22
#define SOUND_ENVIRONMENT_DRUGGED 23
#define SOUND_ENVIRONMENT_DIZZY 24
#define SOUND_ENVIRONMENT_PSYCHOTIC 25
//If we ever make custom ones add them here
#define SOUND_ENVIROMENT_PHASED list(1.8, 0.5, -1000, -4000, 0, 5, 0.1, 1, -15500, 0.007, 2000, 0.05, 0.25, 1, 1.18, 0.348, -5, 2000, 250, 0, 3, 100, 63)

//"sound areas": easy way of keeping different types of areas consistent.
#define SOUND_AREA_STANDARD_STATION SOUND_ENVIRONMENT_PARKING_LOT
#define SOUND_AREA_LARGE_ENCLOSED SOUND_ENVIRONMENT_QUARRY
#define SOUND_AREA_SMALL_ENCLOSED SOUND_ENVIRONMENT_BATHROOM
#define SOUND_AREA_TUNNEL_ENCLOSED SOUND_ENVIRONMENT_STONEROOM
#define SOUND_AREA_LARGE_SOFTFLOOR SOUND_ENVIRONMENT_CARPETED_HALLWAY
#define SOUND_AREA_MEDIUM_SOFTFLOOR SOUND_ENVIRONMENT_LIVINGROOM
#define SOUND_AREA_SMALL_SOFTFLOOR SOUND_ENVIRONMENT_ROOM
#define SOUND_AREA_ASTEROID SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_SPACE SOUND_ENVIRONMENT_UNDERWATER
#define SOUND_AREA_LAVALAND SOUND_ENVIRONMENT_MOUNTAINS
#define SOUND_AREA_ICEMOON SOUND_ENVIRONMENT_CAVE
#define SOUND_AREA_WOODFLOOR SOUND_ENVIRONMENT_CITY


///Announcer audio keys
#define ANNOUNCER_AIMALF "announcer_aimalf"
#define ANNOUNCER_ALIENS "announcer_aliens"
#define ANNOUNCER_ANIMES "announcer_animes"
#define ANNOUNCER_GRANOMALIES "announcer_granomalies"
#define ANNOUNCER_INTERCEPT "announcer_intercept"
#define ANNOUNCER_IONSTORM "announcer_ionstorm"
#define ANNOUNCER_METEORS "announcer_meteors"
#define ANNOUNCER_OUTBREAK5 "announcer_outbreak5"
#define ANNOUNCER_OUTBREAK7 "announcer_outbreak7"
#define ANNOUNCER_POWEROFF "announcer_poweroff"
#define ANNOUNCER_POWERON "announcer_poweron"
#define ANNOUNCER_RADIATION "announcer_radiation"
#define ANNOUNCER_SHUTTLECALLED "announcer_shuttlecalled"
#define ANNOUNCER_SHUTTLEDOCK "announcer_shuttledock"
#define ANNOUNCER_SHUTTLERECALLED "announcer_shuttlerecalled"
#define ANNOUNCER_SPANOMALIES "announcer_spanomalies"
#define ANNOUNCER_LINE_ANOMALY_ENERGETIC_FLUX "announcer_line_anomaly_energetic_flux"
#define ANNOUNCER_LINE_ANOMALY_BLUESPACE "announcer_line_anomaly_bluespace"
#define ANNOUNCER_LINE_ANOMALY_DIMENSIONAL "announcer_line_anomaly_dimensional"
#define ANNOUNCER_LINE_ANOMALY_BIOSCRAMBLER "announcer_line_anomaly_bioscrambler"
#define ANNOUNCER_LINE_ANOMALY_HALLUCINATION "announcer_line_anomaly_hallucination"
#define ANNOUNCER_LINE_ANOMALY_PYROCLASTIC "announcer_line_anomaly_pyroclastic"
#define ANNOUNCER_LINE_ANOMALY_HYPER_FLUX "announcer_line_anomaly_hyper_flux"
#define ANNOUNCER_LINE_ANOMALY_VORTEX "announcer_line_anomaly_vortex"
#define ANNOUNCER_LINE_ANOMALY_ECTOPLASMIC "announcer_line_anomaly_ectoplasmic"
#define ANNOUNCER_LINE_ANOMALY_BAROMETRIC "announcer_line_anomaly_barometric"
#define ANNOUNCER_LINE_ANOMALY_BAROMETRIC_SEVERE "announcer_line_anomaly_barometric_severe"
#define ANNOUNCER_LINE_ANOMALY_GRAVITATIONAL "announcer_line_anomaly_gravitational"
#define ANNOUNCER_LINE_ANOMALY_TRANSLOCATION "announcer_line_anomaly_translocation"
#define ANNOUNCER_LINE_ANOMALY_DIMENSIONAL_RELOCATED "announcer_line_anomaly_dimensional_relocated"
#define ANNOUNCER_LINE_ANOMALY_ECTOPLASM_CRITICAL "announcer_line_anomaly_ectoplasm_critical"
#define ANNOUNCER_LINE_EVENT_PORTAL_STORM "announcer_line_event_portal_storm"
#define ANNOUNCER_LINE_EVENT_CARP_BIOLOGICAL "announcer_line_event_carp_biological"
#define ANNOUNCER_LINE_EVENT_CARP_MAGICAL "announcer_line_event_carp_magical"
#define ANNOUNCER_LINE_EVENT_ORGANIC_FLUX "announcer_line_event_organic_flux"
#define ANNOUNCER_LINE_EVENT_ELECTRICAL_STORM "announcer_line_event_electrical_storm"
#define ANNOUNCER_LINE_EVENT_RADIATION_LEAK "announcer_line_event_radiation_leak"
#define ANNOUNCER_LINE_EVENT_RADIATION_CLEARED "announcer_line_event_radiation_cleared"
#define ANNOUNCER_LINE_EVENT_SCRUBBER_OVERFLOW "announcer_line_event_scrubber_overflow"
#define ANNOUNCER_LINE_EVENT_GREY_TIDE "announcer_line_event_grey_tide"
#define ANNOUNCER_LINE_EVENT_BRAND_INTELLIGENCE "announcer_line_event_brand_intelligence"
#define ANNOUNCER_LINE_EVENT_BUREAUCRATIC_ERROR "announcer_line_event_bureaucratic_error"
#define ANNOUNCER_LINE_EVENT_MARKET_PRICES_UP "announcer_line_event_market_prices_up"
#define ANNOUNCER_LINE_EVENT_MARKET_PRICES_STABLE "announcer_line_event_market_prices_stable"
#define ANNOUNCER_LINE_EVENT_SANDSTORM "announcer_line_event_sandstorm"
#define ANNOUNCER_LINE_EVENT_STRAY_CARGO "announcer_line_event_stray_cargo"
#define ANNOUNCER_LINE_EVENT_STRAY_METEOR "announcer_line_event_stray_meteor"
#define ANNOUNCER_LINE_EVENT_EARTHQUAKE "announcer_line_event_earthquake"
#define ANNOUNCER_LINE_EVENT_VENT_MINOR "announcer_line_event_vent_minor"
#define ANNOUNCER_LINE_EVENT_VENT_MOVED "announcer_line_event_vent_moved"
#define ANNOUNCER_LINE_EVENT_VENT_MAJOR "announcer_line_event_vent_major"
#define ANNOUNCER_LINE_EVENT_VENT_HAZARDOUS "announcer_line_event_vent_hazardous"
#define ANNOUNCER_LINE_EVENT_VENT_UNUSUAL "announcer_line_event_vent_unusual"
#define ANNOUNCER_LINE_EVENT_SUPERMATTER_CLEARED "announcer_line_event_supermatter_cleared"
#define ANNOUNCER_LINE_EVENT_SENTIENCE "announcer_line_event_sentience"
#define ANNOUNCER_LINE_EVENT_WISDOM_COW "announcer_line_event_wisdom_cow"
#define ANNOUNCER_LINE_EVENT_IMMOVABLE_ROD "announcer_line_event_immovable_rod"
#define ANNOUNCER_LINE_EVENT_NIGHTSHIFT_EVENING "announcer_line_event_nightshift_evening"
#define ANNOUNCER_LINE_EVENT_NIGHTSHIFT_MORNING "announcer_line_event_nightshift_morning"
#define ANNOUNCER_LINE_EVENT_NIGHTSHIFT_RESTORE "announcer_line_event_nightshift_restore"
#define ANNOUNCER_LINE_EVENT_NIGHTSHIFT_EMERGENCY "announcer_line_event_nightshift_emergency"
#define ANNOUNCER_LINE_SHUTTLE_UPLINK_INTERFERENCE "announcer_line_shuttle_uplink_interference"
#define ANNOUNCER_LINE_SHUTTLE_UPLINK_RESTORED "announcer_line_shuttle_uplink_restored"
#define ANNOUNCER_LINE_SHUTTLE_DEPARTURE_POSTPONED "announcer_line_shuttle_departure_postponed"
#define ANNOUNCER_LINE_SHUTTLE_BOARDING_TIME "announcer_line_shuttle_boarding_time"
#define ANNOUNCER_LINE_SHUTTLE_DEPARTURE "announcer_line_shuttle_departure"
#define ANNOUNCER_LINE_SHUTTLE_DIRECT_JUMP "announcer_line_shuttle_direct_jump"
#define ANNOUNCER_LINE_SHUTTLE_AUTH_NEEDED "announcer_line_shuttle_auth_needed"
#define ANNOUNCER_LINE_SHUTTLE_AUTH_REVOKED "announcer_line_shuttle_auth_revoked"
#define ANNOUNCER_LINE_SHUTTLE_BLACK_HOLE "announcer_line_shuttle_black_hole"
#define ANNOUNCER_LINE_SHUTTLE_CATASTROPHE_INSURED "announcer_line_shuttle_catastrophe_insured"
#define ANNOUNCER_LINE_SHUTTLE_CATASTROPHE_REPLACEMENT "announcer_line_shuttle_catastrophe_replacement"
#define ANNOUNCER_LINE_THREAT_BLOB_CRITICAL "announcer_line_threat_blob_critical"
#define ANNOUNCER_LINE_THREAT_BLOB_COUNTERMEASURES "announcer_line_threat_blob_countermeasures"
#define ANNOUNCER_LINE_THREAT_DRAGON_LIFEFORMS "announcer_line_threat_dragon_lifeforms"
#define ANNOUNCER_LINE_THREAT_RIFT_PEAK_CHARGE "announcer_line_threat_rift_peak_charge"
#define ANNOUNCER_LINE_THREAT_RIFT_ENERGY_FLUX "announcer_line_threat_rift_energy_flux"
#define ANNOUNCER_LINE_THREAT_DATA_THEFT "announcer_line_threat_data_theft"
#define ANNOUNCER_LINE_THREAT_ARMED_SHIP "announcer_line_threat_armed_ship"
#define ANNOUNCER_LINE_THREAT_REVOLUTION_QUELLED "announcer_line_threat_revolution_quelled"
#define ANNOUNCER_LINE_THREAT_RUNE_SPACETIME "announcer_line_threat_rune_spacetime"
#define ANNOUNCER_LINE_THREAT_RUNE_ENERGY "announcer_line_threat_rune_energy"
#define ANNOUNCER_LINE_THREAT_RUNE_SPIKE "announcer_line_threat_rune_spike"
#define ANNOUNCER_LINE_THREAT_RUNE_CAUSALITY "announcer_line_threat_rune_causality"
#define ANNOUNCER_LINE_THREAT_RUNE_REALITY "announcer_line_threat_rune_reality"
#define ANNOUNCER_LINE_THREAT_NUKE_SYNDICATE_BASE "announcer_line_threat_nuke_syndicate_base"
#define ANNOUNCER_LINE_THREAT_NUKE_OFFSTATION "announcer_line_threat_nuke_offstation"
#define ANNOUNCER_LINE_THREAT_METEOR_SHIELD "announcer_line_threat_meteor_shield"
#define ANNOUNCER_LINE_THREAT_CASCADE_RESONANCE "announcer_line_threat_cascade_resonance"
#define ANNOUNCER_LINE_THREAT_HFR_MELTDOWN "announcer_line_threat_hfr_meltdown"
#define ANNOUNCER_LINE_TRAIT_BIRTHDAY "announcer_line_trait_birthday"
#define ANNOUNCER_LINE_TRAIT_NEBULA_BRIEFING "announcer_line_trait_nebula_briefing"
#define ANNOUNCER_LINE_TRAIT_SLOT_JACKPOT "announcer_line_trait_slot_jackpot"
#define ANNOUNCER_LINE_THREAT_CRAB_DEPOSIT_DESTROYED "announcer_line_threat_crab_deposit_destroyed"
#define ANNOUNCER_LINE_THREAT_SPACECOIN_POPPED "announcer_line_threat_spacecoin_popped"

/// Global list of all of our announcer keys.
GLOBAL_LIST_INIT(announcer_keys, list(
	ANNOUNCER_AIMALF,
	ANNOUNCER_ALIENS,
	ANNOUNCER_ANIMES,
	ANNOUNCER_GRANOMALIES,
	ANNOUNCER_INTERCEPT,
	ANNOUNCER_IONSTORM,
	ANNOUNCER_METEORS,
	ANNOUNCER_OUTBREAK5,
	ANNOUNCER_OUTBREAK7,
	ANNOUNCER_POWEROFF,
	ANNOUNCER_POWERON,
	ANNOUNCER_RADIATION,
	ANNOUNCER_SHUTTLECALLED,
	ANNOUNCER_SHUTTLEDOCK,
	ANNOUNCER_SHUTTLERECALLED,
	ANNOUNCER_SPANOMALIES,
	ANNOUNCER_LINE_ANOMALY_ENERGETIC_FLUX,
	ANNOUNCER_LINE_ANOMALY_BLUESPACE,
	ANNOUNCER_LINE_ANOMALY_DIMENSIONAL,
	ANNOUNCER_LINE_ANOMALY_BIOSCRAMBLER,
	ANNOUNCER_LINE_ANOMALY_HALLUCINATION,
	ANNOUNCER_LINE_ANOMALY_PYROCLASTIC,
	ANNOUNCER_LINE_ANOMALY_HYPER_FLUX,
	ANNOUNCER_LINE_ANOMALY_VORTEX,
	ANNOUNCER_LINE_ANOMALY_ECTOPLASMIC,
	ANNOUNCER_LINE_ANOMALY_BAROMETRIC,
	ANNOUNCER_LINE_ANOMALY_BAROMETRIC_SEVERE,
	ANNOUNCER_LINE_ANOMALY_GRAVITATIONAL,
	ANNOUNCER_LINE_ANOMALY_TRANSLOCATION,
	ANNOUNCER_LINE_ANOMALY_DIMENSIONAL_RELOCATED,
	ANNOUNCER_LINE_ANOMALY_ECTOPLASM_CRITICAL,
	ANNOUNCER_LINE_EVENT_PORTAL_STORM,
	ANNOUNCER_LINE_EVENT_CARP_BIOLOGICAL,
	ANNOUNCER_LINE_EVENT_CARP_MAGICAL,
	ANNOUNCER_LINE_EVENT_ORGANIC_FLUX,
	ANNOUNCER_LINE_EVENT_ELECTRICAL_STORM,
	ANNOUNCER_LINE_EVENT_RADIATION_LEAK,
	ANNOUNCER_LINE_EVENT_RADIATION_CLEARED,
	ANNOUNCER_LINE_EVENT_SCRUBBER_OVERFLOW,
	ANNOUNCER_LINE_EVENT_GREY_TIDE,
	ANNOUNCER_LINE_EVENT_BRAND_INTELLIGENCE,
	ANNOUNCER_LINE_EVENT_BUREAUCRATIC_ERROR,
	ANNOUNCER_LINE_EVENT_MARKET_PRICES_UP,
	ANNOUNCER_LINE_EVENT_MARKET_PRICES_STABLE,
	ANNOUNCER_LINE_EVENT_SANDSTORM,
	ANNOUNCER_LINE_EVENT_STRAY_CARGO,
	ANNOUNCER_LINE_EVENT_STRAY_METEOR,
	ANNOUNCER_LINE_EVENT_EARTHQUAKE,
	ANNOUNCER_LINE_EVENT_VENT_MINOR,
	ANNOUNCER_LINE_EVENT_VENT_MOVED,
	ANNOUNCER_LINE_EVENT_VENT_MAJOR,
	ANNOUNCER_LINE_EVENT_VENT_HAZARDOUS,
	ANNOUNCER_LINE_EVENT_VENT_UNUSUAL,
	ANNOUNCER_LINE_EVENT_SUPERMATTER_CLEARED,
	ANNOUNCER_LINE_EVENT_SENTIENCE,
	ANNOUNCER_LINE_EVENT_WISDOM_COW,
	ANNOUNCER_LINE_EVENT_IMMOVABLE_ROD,
	ANNOUNCER_LINE_EVENT_NIGHTSHIFT_EVENING,
	ANNOUNCER_LINE_EVENT_NIGHTSHIFT_MORNING,
	ANNOUNCER_LINE_EVENT_NIGHTSHIFT_RESTORE,
	ANNOUNCER_LINE_EVENT_NIGHTSHIFT_EMERGENCY,
	ANNOUNCER_LINE_SHUTTLE_UPLINK_INTERFERENCE,
	ANNOUNCER_LINE_SHUTTLE_UPLINK_RESTORED,
	ANNOUNCER_LINE_SHUTTLE_DEPARTURE_POSTPONED,
	ANNOUNCER_LINE_SHUTTLE_BOARDING_TIME,
	ANNOUNCER_LINE_SHUTTLE_DEPARTURE,
	ANNOUNCER_LINE_SHUTTLE_DIRECT_JUMP,
	ANNOUNCER_LINE_SHUTTLE_AUTH_NEEDED,
	ANNOUNCER_LINE_SHUTTLE_AUTH_REVOKED,
	ANNOUNCER_LINE_SHUTTLE_BLACK_HOLE,
	ANNOUNCER_LINE_SHUTTLE_CATASTROPHE_INSURED,
	ANNOUNCER_LINE_SHUTTLE_CATASTROPHE_REPLACEMENT,
	ANNOUNCER_LINE_THREAT_BLOB_CRITICAL,
	ANNOUNCER_LINE_THREAT_BLOB_COUNTERMEASURES,
	ANNOUNCER_LINE_THREAT_DRAGON_LIFEFORMS,
	ANNOUNCER_LINE_THREAT_RIFT_PEAK_CHARGE,
	ANNOUNCER_LINE_THREAT_RIFT_ENERGY_FLUX,
	ANNOUNCER_LINE_THREAT_DATA_THEFT,
	ANNOUNCER_LINE_THREAT_ARMED_SHIP,
	ANNOUNCER_LINE_THREAT_REVOLUTION_QUELLED,
	ANNOUNCER_LINE_THREAT_RUNE_SPACETIME,
	ANNOUNCER_LINE_THREAT_RUNE_ENERGY,
	ANNOUNCER_LINE_THREAT_RUNE_SPIKE,
	ANNOUNCER_LINE_THREAT_RUNE_CAUSALITY,
	ANNOUNCER_LINE_THREAT_RUNE_REALITY,
	ANNOUNCER_LINE_THREAT_NUKE_SYNDICATE_BASE,
	ANNOUNCER_LINE_THREAT_NUKE_OFFSTATION,
	ANNOUNCER_LINE_THREAT_METEOR_SHIELD,
	ANNOUNCER_LINE_THREAT_CASCADE_RESONANCE,
	ANNOUNCER_LINE_THREAT_HFR_MELTDOWN,
	ANNOUNCER_LINE_TRAIT_BIRTHDAY,
	ANNOUNCER_LINE_TRAIT_NEBULA_BRIEFING,
	ANNOUNCER_LINE_TRAIT_SLOT_JACKPOT,
	ANNOUNCER_LINE_THREAT_CRAB_DEPOSIT_DESTROYED,
	ANNOUNCER_LINE_THREAT_SPACECOIN_POPPED,
))

// Standard is 44.1khz
#define MIN_EMOTE_PITCH 40000
#define MAX_EMOTE_PITCH 48000
// ~0.6 - 1.4 at 0.12
#define EMOTE_TTS_PITCH_MULTIPLIER 0.12
