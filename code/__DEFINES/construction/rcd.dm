//rcd constants for the design list
/// The mode of operation to design an specific type of rcd design
#define RCD_DESIGN_MODE "rcd_design_mode"
	/// For changing turfs
	#define RCD_TURF (1 << 0)
	/// Full tile windows
	#define RCD_WINDOWGRILLE (1 << 1)
	/// Windoors & Airlocks
	#define RCD_AIRLOCK (1 << 2)
	/// Literally anything that is spawned on top of a turf such as tables, machines etc
	#define RCD_STRUCTURE (1 << 3)
	/// For wallmounts like air alarms, fire alarms & apc
	#define RCD_WALLFRAME (1 << 4)
	/// For deconstructing an structure
	#define RCD_DECONSTRUCT (1 << 5)
/// The typepath of the structure the rcd is trying to build
#define RCD_DESIGN_PATH "rcd_design_path"

/// Time taken for an rcd hologram to disappear
#define RCD_HOLOGRAM_FADE_TIME (15 SECONDS)

/// Delay before another rcd scan can be performed in the UI
#define RCD_DESTRUCTIVE_SCAN_COOLDOWN (RCD_HOLOGRAM_FADE_TIME + 1 SECONDS)

//All available upgrades
/// Upgrade for building machines
#define RCD_UPGRADE_FRAMES (1 << 0)
/// Upgrade for installing circuitboards in air alarms, fire alarms, apc & cells in them
#define RCD_UPGRADE_SIMPLE_CIRCUITS (1 << 1)
/// Upgrade for drawing iron from ore silo
#define RCD_UPGRADE_SILO_LINK (1 << 2)
/// Upgrade for building furnishing items
#define RCD_UPGRADE_FURNISHING (1 << 3)
/// Upgrade to stop construction effect from getting attacked
#define RCD_UPGRADE_ANTI_INTERRUPT (1 << 4)
/// Upgrade to disable delay multiplier when building multiple structures
#define RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN (1 << 5)
/// All upgrades packed in 1 flag
#define RCD_ALL_UPGRADES (RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_SILO_LINK | RCD_UPGRADE_FURNISHING | RCD_UPGRADE_ANTI_INTERRUPT | RCD_UPGRADE_NO_FREQUENT_USE_COOLDOWN)
/// Upgrades for the Rapid Pipe Dispenser to unwrench pipes
#define RPD_UPGRADE_UNWRENCH (1 << 0)

//Memory constants for faster construction speeds
/// The memory constant for a wall
#define RCD_MEMORY_WALL 1
/// The memory constant for full tile windows
#define RCD_MEMORY_WINDOWGRILLE 2
// How much faster to use the RCD when on a tile with memory
#define RCD_MEMORY_SPEED_BUFF 5
/// How much less resources the RCD uses when reconstructing
#define RCD_MEMORY_COST_BUFF 8
/// If set to TRUE in rcd_vals, will bypass the cooldown on slowing down frequent use
#define RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN "bypass_frequent_use_cooldown"
