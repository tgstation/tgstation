#define is_station_level(z) SSmapping.check_level_trait(z, STATION_LEVEL)

#define is_station_contact(z) SSmapping.check_level_trait(z, STATION_CONTACT)

#define is_teleport_allowed(z) !SSmapping.check_level_trait(z, BLOCK_TELEPORT)

#define is_away_level(z) SSmapping.check_level_trait(z, AWAY_LEVEL)

#define is_mining_level(z) SSmapping.check_level_trait(z, MINING_LEVEL)

#define is_ai_allowed(z) SSmapping.check_level_trait(z, AI_OK)

#define is_reebe(z) SSmapping.check_level_trait(z, REEBE)

#define is_centcom(z) SSmapping.check_level_trait(z, CENTCOM)

#define level_blocks_magic(z) SSmapping.check_level_trait(z, IMPEDES_MAGIC)

#define level_ignores_bombcap(z) SSmapping.check_level_trait(z, IGNORES_BOMBCAP)

#define level_nerfs_bombs(z) SSmapping.check_level_trait(z, NERFS_BOMBS)

// Used for the nuke disk, or for checking if players survived through xenos
#define is_secure_level(z) SSmapping.check_level_has_trait(z, list(STATION_LEVEL, CENTCOM))
