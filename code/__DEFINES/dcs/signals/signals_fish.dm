// Aquarium related signals
#define COMSIG_AQUARIUM_SURFACE_CHANGED "aquarium_surface_changed"
#define COMSIG_AQUARIUM_FLUID_CHANGED "aquarium_fluid_changed"
///Called on aquarium/attackby: (aquarium)
#define COMSIG_TRY_INSERTING_IN_AQUARIUM "item_try_inserting_in_aquarium"
	///The item will be inserted into the aquarium
	#define COMSIG_CAN_INSERT_IN_AQUARIUM (1<<0)
	///The item won't be inserted into the aquarium, but will early return attackby anyway.
	#define COMSIG_CANNOT_INSERT_IN_AQUARIUM (1<<1)

// Fish signals
#define COMSIG_FISH_STATUS_CHANGED "fish_status_changed"
#define COMSIG_FISH_STIRRED "fish_stirred"
///From /obj/item/fish/process: (seconds_per_tick)
#define COMSIG_FISH_LIFE "fish_life"
///From /datum/fish_trait/eat_fish: (predator)
#define COMSIG_FISH_EATEN_BY_OTHER_FISH "fish_eaten_by_other_fish"
///From /obj/item/fish/feed: (fed_reagents, fed_reagent_type)
#define COMSIG_FISH_FED "fish_on_fed"

/// Fishing challenge completed
#define COMSIG_FISHING_CHALLENGE_COMPLETED "fishing_completed"
/// Sent to the fisherman when the reward is dispensed: (reward)
#define COMSIG_FISH_SOURCE_REWARD_DISPENSED "mob_fish_source_reward_dispensed"

/// Called when you try to use fishing rod on anything
#define COMSIG_PRE_FISHING "pre_fishing"

/// Called when an ai-controlled mob interacts with the fishing spot
#define COMSIG_NPC_FISHING "npc_fishing"
	#define NPC_FISHING_SPOT 1

/// Sent by the target of the fishing rod cast
#define COMSIG_FISHING_ROD_CAST "fishing_rod_cast"
	#define FISHING_ROD_CAST_HANDLED (1 << 0)

/// From /datum/fish_source/proc/dispense_reward(), not set if the reward is a dud: (reward, user)
#define COMSIG_FISHING_ROD_CAUGHT_FISH "fishing_rod_caught_fish"
/// From /obj/item/fishing_rod/proc/hook_item(): (reward, user)
#define COMSIG_FISHING_ROD_HOOKED_ITEM "fishing_rod_hooked_item"
/// From /datum/fish_source/proc/use_slot(), sent to the slotted item: (obj/item/fishing_rod/rod)
#define COMSIG_FISHING_EQUIPMENT_SLOTTED "fishing_equipment_slotted"

/// Sent when the challenge is to be interrupted: (reason)
#define COMSIG_FISHING_SOURCE_INTERRUPT_CHALLENGE "fishing_spot_interrupt_challenge"

/// From /obj/item/fish_analyzer/proc/analyze_status: (fish, user)
#define COMSIG_FISH_ANALYZER_ANALYZE_STATUS "fish_analyzer_analyze_status"
