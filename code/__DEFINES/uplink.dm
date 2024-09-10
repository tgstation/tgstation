// These are used in uplink_devices.dm to determine whether or not an item is purchasable.

/// This item is purchasable to traitors
#define UPLINK_TRAITORS (1 << 0)

/// This item is purchasable to nuke ops
#define UPLINK_NUKE_OPS (1 << 1)

/// This item is purchasable to clown ops
#define UPLINK_CLOWN_OPS (1 << 2)

/// This item is purchasable to infiltrators (midround traitors)
#define UPLINK_INFILTRATORS (1 << 3)

/// Can be randomly given to spies for their bounties
#define UPLINK_SPY (1 << 4)

#define UPLINK_LONE_OP (1 << 5)

/// A blanket define for an item being purchasable by all types of nukie
#define UPLINK_ALL_SYNDIE_OPS (UPLINK_NUKE_OPS | UPLINK_LONE_OP | UPLINK_CLOWN_OPS)

/// A blanket define for an item being purchasable by all operatives that spawn at the nukie firebase
#define UPLINK_FIREBASE_OPS (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/// A define that excludes clown ops from the regular nukeop gear lineup
#define UPLINK_SERIOUS_OPS (UPLINK_NUKE_OPS | UPLINK_LONE_OP)

/// Progression gets turned into a user-friendly form. This is just an abstract equation that makes progression not too large.
#define DISPLAY_PROGRESSION(time) round(time/60, 0.01)

/// Traitor discount size categories
#define TRAITOR_DISCOUNT_BIG "big_discount"
#define TRAITOR_DISCOUNT_AVERAGE "average_discount"
#define TRAITOR_DISCOUNT_SMALL "small_discount"

/// Typepath used for uplink items which don't actually produce an item (essentially just a placeholder)
/// Future todo: Make this not necessary / make uplink items support item-less items natively
#define ABSTRACT_UPLINK_ITEM /obj/item/loot_table_maker

/// Lower threshold for which an uplink items's TC cost is considered "low" for spy bounties picking rewards
#define SPY_LOWER_COST_THRESHOLD 5
/// Upper threshold for which an uplink items's TC cost is considered "high" for spy bounties picking rewards
#define SPY_UPPER_COST_THRESHOLD 12

/// Minimal cost for an item to be eligible for a discount
#define TRAITOR_DISCOUNT_MIN_PRICE 4
