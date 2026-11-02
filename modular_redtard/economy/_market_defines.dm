// The market of medieval maps beyond the base trade loop (Ratwood Economy 3): the Burgher Pledge and the levies on contracts,
// the Ordinance of the Baths, the Right of Customs in Excess, economic events and blockades, the pricing engine, the
// merchant's favor and catalogs, kinship, provisions and cultural stock of the ships, crown imports and the Steward's
// petitions. Included right after _treasury_defines.dm, so the treasury files use these too. Defines one file alone uses live
// in that file; tuning numbers are mechanics values (trade_*, treasury_*).

/// The Crown's levy on a contract reward paid into the bearer's account (Ratwood TAX_CATEGORY_CONTRACT_LEVY).
#define ROGUE_TAX_CONTRACT "contract levy"

/// Keys of a ship's provision line the harbor reads, beside ROGUE_LINE_TARGET, ROGUE_LINE_DONE and ROGUE_LINE_PRICE: the name
/// of the dish or bottle, and whether a drink goes by the bottle rather than by the keg.
#define ROGUE_LINE_NAME "name"
#define ROGUE_LINE_BY_BOTTLE "by_bottle"
