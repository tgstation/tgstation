//rcd constants for the design list
#define RCD_DESIGN_MODE "rcd_design_mode"
	#define RCD_TURF (1 << 0)
	#define RCD_WINDOWGRILLE (1 << 1)
	#define RCD_AIRLOCK (1 << 2)
	#define RCD_STRUCTURE (1 << 3)
	#define RCD_WALLFRAME (1 << 4)
	#define RCD_DECONSTRUCT (1 << 5)
#define RCD_DESIGN_PATH "rcd_design_path"

//hologram constants
#define RCD_DESTRUCTIVE_SCAN_RANGE 10
#define RCD_HOLOGRAM_FADE_TIME (15 SECONDS)
#define RCD_DESTRUCTIVE_SCAN_COOLDOWN (RCD_HOLOGRAM_FADE_TIME + 1 SECONDS)

// all available upgrades
#define RCD_UPGRADE_FRAMES (1<<0)
#define RCD_UPGRADE_SIMPLE_CIRCUITS (1<<1)
#define RCD_UPGRADE_SILO_LINK (1<<2)
#define RCD_UPGRADE_FURNISHING (1<<3)
#define RCD_UPGRADE_ANTI_INTERRUPT (1<<4)
#define RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN (1<<5)
#define RCD_ALL_UPGRADES (RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_SILO_LINK | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN)
//upgrades for the rpd
#define RPD_UPGRADE_UNWRENCH (1<<0)

#define RCD_MEMORY_WALL 1
#define RCD_MEMORY_WINDOWGRILLE 2

// How much faster to use the RCD when on a tile with memory
#define RCD_MEMORY_SPEED_BUFF 5

/// How much less resources the RCD uses when reconstructing
#define RCD_MEMORY_COST_BUFF 8

/// If set to TRUE in rcd_vals, will bypass the cooldown on slowing down frequent use
#define RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN "bypass_frequent_use_cooldown"
