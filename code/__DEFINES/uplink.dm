// These are used in uplink_devices.dm to determine whether or not an item is purchasable.

/// This item is purchasable to traitors
#define UPLINK_TRAITORS (1 << 0)

/// This item is purchasable to nuke ops
#define UPLINK_NUKE_OPS (1 << 1)

/// This item is purchasable to clown ops
#define UPLINK_CLOWN_OPS (1 << 2)

/// Progression gets turned into a user-friendly form. This is just an abstract equation that makes progression not too large.
#define DISPLAY_PROGRESSION(time) round(time/60, 0.01)

/// Traitor discount size categories
#define TRAITOR_DISCOUNT_BIG "big_discount"
#define TRAITOR_DISCOUNT_AVERAGE "average_discount"
#define TRAITOR_DISCOUNT_SMALL "small_discount"
