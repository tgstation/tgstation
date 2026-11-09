
// Shipping methods

// The BEST way of shipping items: accurate, "undetectable"
#define SHIPPING_METHOD_LTSRBT "LTSRBT"
// Picks a random area to teleport the item to and gives you a minute to get there before it is sent.
#define SHIPPING_METHOD_TELEPORT "Teleport"
// Throws the item from somewhere at the station.
#define SHIPPING_METHOD_LAUNCH "Launch"
// Sends a supply pod to the buyer's location, showy.
#define SHIPPING_METHOD_SUPPLYPOD "Supply Pod"

/// The percentage on gains that's removed when selling an item through the blackmarket with the LTSRBT
#define MARKET_WITHHOLDING_TAX 0.15

//Black Market Uplink categories
#define BLACKMARKET_CATEGORY_CLOTHING "Clothing"
#define BLACKMARKET_CATEGORY_CONSUMABLES "Consumables"
#define BLACKMARKET_CATEGORY_HOSTAGES "Hostages"
#define BLACKMARKET_CATEGORY_LOCAL_GOODS "Local Goods"
#define BLACKMARKET_CATEGORY_MISC "Miscellaneous"
#define BLACKMARKET_CATEGORY_FENCED_GOODS "Fenced Goods"
#define BLACKMARKET_CATEGORY_TOOLS "Tools"
#define BLACKMARKET_CATEGORY_WEAPONS "Weapons"

#define BLACKMARKET_CATEGORIES list(\
	BLACKMARKET_CATEGORY_CLOTHING,\
	BLACKMARKET_CATEGORY_CONSUMABLES,\
	BLACKMARKET_CATEGORY_HOSTAGES,\
	BLACKMARKET_CATEGORY_LOCAL_GOODS,\
	BLACKMARKET_CATEGORY_MISC,\
	BLACKMARKET_CATEGORY_FENCED_GOODS,\
	BLACKMARKET_CATEGORY_TOOLS,\
	BLACKMARKET_CATEGORY_WEAPONS,\
)
