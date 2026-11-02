// The market of medieval maps beyond the base trade loop (Ratwood Economy 3): the Burgher Pledge and the levies on contracts,
// the Ordinance of the Baths, the Right of Customs in Excess, economic events and blockades, the pricing engine, the
// merchant's favor and catalogs, kinship, provisions and cultural stock of the ships, crown imports and the Steward's
// petitions. Included right after _treasury_defines.dm, so the treasury files use these too. Tuning numbers are mechanics
// values (trade_*, treasury_*).

/// The Crown's levy on a contract reward paid into the bearer's account (Ratwood TAX_CATEGORY_CONTRACT_LEVY).
#define ROGUE_TAX_CONTRACT "contract levy"

/// An economic event raises the price of its goods, or lowers it (Ratwood ECON_EVENT_SHORTAGE, ECON_EVENT_OVERSUPPLY).
#define ROGUE_EVENT_SHORTAGE "shortage"
#define ROGUE_EVENT_OVERSUPPLY "oversupply"

/// Goods the realm trades as finished items or as potions, delivered at the warehouse docks instead of the stockpile
/// (Ratwood TRADE_BEHAVIOR_EQUIPMENT, TRADE_BEHAVIOR_POTION); other goods have no behavior and go through the stockpile.
#define ROGUE_GOOD_EQUIPMENT "equipment"
#define ROGUE_GOOD_POTION "potion"

/// What a condition of a foreign realm does to a cargo line of its ships (Ratwood CONDITION_OP_*).
#define ROGUE_CONDITION_MODIFY "modify"
#define ROGUE_CONDITION_REMOVE "remove"
#define ROGUE_CONDITION_ADD "add"

/// Kinds of provisions a ship takes aboard (Ratwood TRADE_VICTUALLING_TAG_*).
#define ROGUE_PROVISION_FRESH "fresh"
#define ROGUE_PROVISION_PRESERVED "preserved"
#define ROGUE_PROVISION_DRINKS "drinks"

/// Keys of a ship's provision line, beside ROGUE_LINE_TARGET, ROGUE_LINE_DONE and ROGUE_LINE_PRICE: the dish or bottle the
/// captain buys, its name, its kind, and whether a drink goes by the bottle rather than by the keg.
#define ROGUE_LINE_TYPE "type"
#define ROGUE_LINE_NAME "name"
#define ROGUE_LINE_TAG "tag"
#define ROGUE_LINE_BY_BOTTLE "by_bottle"

/// How a captain takes the trade he got when he sails (Ratwood FAVOR_OUTCOME_*).
#define ROGUE_FAVOR_HONORED "honored"
#define ROGUE_FAVOR_PARTIAL "partial"
#define ROGUE_FAVOR_DISHONORED "dishonored"

/// The trading company's services the merchant buys with favor (Ratwood rent_extra_pier(), unlock_auto_hailer(),
/// unlock_gnome_automation()).
#define ROGUE_UPGRADE_PIER "pier"
#define ROGUE_UPGRADE_HAILER "hailer"
#define ROGUE_UPGRADE_GNOMES "gnomes"
