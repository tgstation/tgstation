#define STYLE_STANDARD 1
#define STYLE_BLUESPACE 2
#define STYLE_CENTCOM 3
#define STYLE_SYNDICATE 4
#define STYLE_BLUE 5
#define STYLE_CULT 6
#define STYLE_MISSILE 7
#define STYLE_RED_MISSILE 8
#define STYLE_BOX 9
#define STYLE_HONK 10
#define STYLE_FRUIT 11
#define STYLE_INVISIBLE 12
#define STYLE_GONDOLA 13
#define STYLE_SEETHROUGH 14
#define STYLE_TELEPORT 15 // BANDASTATION EDIT

#define POD_SHAPE 1
#define POD_BASE 2
#define POD_DOOR 3
#define POD_DECAL 4
#define POD_GLOW 5
#define POD_RUBBLE_TYPE 6
#define POD_NAME 7
#define POD_DESC 8

#define RUBBLE_NONE 1
#define RUBBLE_NORMAL 2
#define RUBBLE_WIDE 3
#define RUBBLE_THIN 4

#define POD_SHAPE_NORML 1
#define POD_SHAPE_OTHER 2

#define POD_TRANSIT "1"
#define POD_FALLING "2"
#define POD_OPENING "3"
#define POD_LEAVING "4"

#define SUPPLYPOD_X_OFFSET -16

/// The baseline unit for cargo crates. Adjusting this will change the cost of all in-game shuttles, crate export values, bounty rewards, and all supply pack import values, as they use this as their unit of measurement.
#define CARGO_CRATE_VALUE 200

/// The highest amount of orders you can have of one thing at any one time
#define CARGO_MAX_ORDER 50

/// Returned by /obj/docking_port/mobile/supply/proc/get_order_count to signify us going over the order limit
#define OVER_ORDER_LIMIT "GO AWAY"

/// Universal Scanner mode for export scanning.
#define SCAN_EXPORTS 1
/// Universal Scanner mode for using the sales tagger.
#define SCAN_SALES_TAG 2
/// Universal Scanner mode for using the price tagger.
#define SCAN_PRICE_TAG 3

///Used by coupons to define that they're cursed
#define COUPON_OMEN "omen"

///Discount categories for coupons. This one is for anything that isn't discountable.
#define SUPPLY_PACK_NOT_DISCOUNTABLE null
///Discount category for the standard stuff, mostly goodies.
#define SUPPLY_PACK_STD_DISCOUNTABLE "standard_discount"
///Discount category for stuff that's mostly niche and/or that might be useful.
#define SUPPLY_PACK_UNCOMMON_DISCOUNTABLE "uncommon_discount"
///Discount category for the silly, overpriced, joke content, sometimes useful or plain bad.
#define SUPPLY_PACK_RARE_DISCOUNTABLE "rare_discount"

///Standard export define for not selling the item.
#define EXPORT_NOT_SOLD 0
///Sell the item
#define EXPORT_SOLD 1
///Sell the item, but for the love of god, don't delete it, we're handling it in a fancier way.
#define EXPORT_SOLD_DONT_DELETE 2
