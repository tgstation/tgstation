// Defines related to the mining rework circa June 2023
/// Durability of a large size boulder from a large size vent.
#define BOULDER_SIZE_LARGE 15
/// Durability of a medium size boulder from a medium size vent.
#define BOULDER_SIZE_MEDIUM 10
/// Durability of a small size boulder from a small size vent.
#define BOULDER_SIZE_SMALL 5
/// How many boulders can a single ore vent have on its tile before it stops producing more?
#define MAX_BOULDERS_PER_VENT 10
/// Time multiplier
#define INATE_BOULDER_SPEED_MULTIPLIER 3

// Vent type
/// Large vents, giving large boulders.
#define LARGE_VENT_TYPE "large"
/// Medium vents, giving medium boulders.
#define MEDIUM_VENT_TYPE "medium"
/// Small vents, giving small boulders.
#define SMALL_VENT_TYPE "small"

//gibtonite strength
/// Gibtonite was deactivated right before it could explode
#define GIBTONITE_QUALITY_HIGH 3
/// Gibtonite was deactivated a few seconds before it could explode
#define GIBTONITE_QUALITY_MEDIUM 2
/// Gibtonite was deactivated right after it was struck.
#define GIBTONITE_QUALITY_LOW 1

// Timers for the ore vents to perform wave defense.
/// Duration for wave defense for a small vent.
#define WAVE_DURATION_SMALL 60 SECONDS
/// Duration for wave defense for a medium vent.
#define WAVE_DURATION_MEDIUM 90 SECONDS
/// Duration for wave defense for a large vent.
#define WAVE_DURATION_LARGE 150 SECONDS

/// Lifetime of a boulder platform in seconds when spawned in lava/plasma.
#define PLATFORM_LIFE_DEFAULT 10 SECONDS

#define PLATFORM_LIFE_GULAG 1 SECONDS
#define PLATFORM_LIFE_SMALL 20 SECONDS
#define PLATFORM_LIFE_MEDIUM 45 SECONDS
#define PLATFORM_LIFE_LARGE 90 SECONDS

/// The number of points a miner gets for discovering a vent, multiplied by BOULDER_SIZE when completing a wave defense minus the discovery bonus.
#define MINER_POINT_MULTIPLIER 100
/// The multiplier that gets applied for automatically generated mining points.
#define MINING_POINT_MACHINE_MULTIPLIER 0.5

// String defines to use with CaveGenerator presets for what ore breakdown to use.
#define OREGEN_PRESET_LAVALAND "lavaland"
#define OREGEN_PRESET_TRIPLE_Z "triple_z"

// Ore vein types
/// Round ore cluster
#define ORE_VEIN_CLUSTER "cluster"
/// Randomly scattered ore
#define ORE_VEIN_SCATTER "scatter"
/// A straight or slightly bent uneven line
#define ORE_VEIN_PLAIN "plain"
/// A branching tree-like vein
#define ORE_VEIN_BRANCH "branch"

/// Maximum precision for ore spawn probabilities
#define ORE_CHANCE_PRECISION 5

/// Permanent style multiplier modifier earned from tapping vents, modified by vent size.
#define ACTION_MULTIPLIER_PER_VENT_VALUE 0.1
/// Permanent style multiplier modifier earned from killing a megafauna.
#define ACTION_MULTIPLIER_MAJOR_KILL 0.1
