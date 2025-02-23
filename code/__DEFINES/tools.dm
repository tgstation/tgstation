// Tool types, if you add new ones please add them to /obj/item/debug/omnitool in code/game/objects/items/debug_items.dm
#define TOOL_CROWBAR "crowbar"
#define TOOL_MULTITOOL "multitool"
#define TOOL_SCREWDRIVER "screwdriver"
#define TOOL_WIRECUTTER "cutters"
#define TOOL_WRENCH "wrench"
#define TOOL_WELDER "welder"
#define TOOL_ANALYZER "analyzer"
#define TOOL_MINING "mining"
#define TOOL_SHOVEL "shovel"
#define TOOL_RETRACTOR "retractor"
#define TOOL_HEMOSTAT "hemostat"
#define TOOL_CAUTERY "cautery"
#define TOOL_DRILL "drill"
#define TOOL_SCALPEL "scalpel"
#define TOOL_SAW "saw"
#define TOOL_BONESET "bonesetter"
#define TOOL_KNIFE "knife"
#define TOOL_BLOODFILTER "bloodfilter"
#define TOOL_ROLLINGPIN "rolling pin"
/// Can be used to scrape rust off an any atom; which will result in the Rust Component being qdel'd
#define TOOL_RUSTSCRAPER "rustscraper"

// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20
#define MIN_TOOL_OPERATING_DELAY 40 //minimum delay for operating sound. Prevent overlaps and overhand sound.
/// Return when an item interaction is successful.
/// This cancels the rest of the chain entirely and indicates success.
#define ITEM_INTERACT_SUCCESS (1<<0) // Same as TRUE, as most tool (legacy) tool acts return TRUE on success
/// Return to prevent the rest of the attack chain from being executed / preventing the item user from thwacking the target.
/// Similar to [ITEM_INTERACT_SUCCESS], but does not necessarily indicate success.
#define ITEM_INTERACT_BLOCKING (1<<1)
	/// Only for people who get confused by the naming scheme
	#define ITEM_INTERACT_FAILURE ITEM_INTERACT_BLOCKING
/// Return to skip the rest of the interaction chain, going straight to attack.
#define ITEM_INTERACT_SKIP_TO_ATTACK (1<<2)

/// Combination flag for any item interaction that blocks the rest of the attack chain
#define ITEM_INTERACT_ANY_BLOCKER (ITEM_INTERACT_SUCCESS | ITEM_INTERACT_BLOCKING)

/// How many seconds between each fuel depletion tick ("use" proc)
#define TOOL_FUEL_BURN_INTERVAL 5

///This is a number I got by quickly searching up the temperature to melt iron/glass, though not really realistic.
///This is used for places where lighters should not be hot enough to be used as a welding tool on.
#define HIGH_TEMPERATURE_REQUIRED 1500

/**
 * A helper for checking if an item interaction should be skipped.
 * This is only used explicitly because some interactions may not want to ever be skipped.
 */
#define SHOULD_SKIP_INTERACTION(target, item, user) (HAS_TRAIT(target, TRAIT_COMBAT_MODE_SKIP_INTERACTION) && user.combat_mode)
