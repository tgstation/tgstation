// Ratwood's surgery (code/modules/surgery/) on TG's operations (code/modules/surgery/operations/): the defines its files share.

/// Ratwood's improvised tools (surgery_tools_rogue.dm): the stone blade, the wooden clamp and the wooden retractor.
#define ROGUE_TOOL_IMPROVISED_SCALPEL "improvised_scalpel"
#define ROGUE_TOOL_IMPROVISED_HEMOSTAT "improvised_hemostat"
#define ROGUE_TOOL_IMPROVISED_RETRACTOR "improvised_retractor"

/// Ratwood's implements that are no tool (TOOL_SHARP, TOOL_HOT, TOOL_NONE): anything with an edge or a point, anything hot
/// enough to burn, any item at all.
#define ROGUE_IMPLEMENT_SHARP "rogue_sharp"
#define ROGUE_IMPLEMENT_HOT "rogue_hot"
#define ROGUE_IMPLEMENT_ANY "rogue_any"
/// Ratwood's /obj/item/bodypart implement: a limb for the zone, a severed one or a prosthetic.
#define ROGUE_IMPLEMENT_LIMB "rogue_limb"

/// Keys of an operation's arguments: the chance Ratwood's roll was made against, and that a step of the operation failed.
#define ROGUE_OPERATION_CHANCE "rogue_chance"
#define ROGUE_OPERATION_FAILED "rogue_failed"

/// Source of the free operation a medieval body is given: at Ratwood nobody needs drapes to be operated on.
#define ROGUE_SURGERY_SOURCE "rogue_surgery"

/// One series for each wound surgery leaves, beside the series of the other wounds.
#define ROGUE_WOUND_SERIES_INCISION "rogue_wound_series_incision"
#define ROGUE_WOUND_SERIES_VEIN "rogue_wound_series_vein"
#define ROGUE_WOUND_SERIES_REPLANTATION "rogue_wound_series_replantation"

/// What a prosthetic is made of (Ratwood limb_material and the artificer's contraptions).
#define ROGUE_PROSTHETIC_WOOD "wood"
#define ROGUE_PROSTHETIC_BRONZE "bronze"
#define ROGUE_PROSTHETIC_IRON "iron"
#define ROGUE_PROSTHETIC_STEEL "steel"
#define ROGUE_PROSTHETIC_GOLD "gold"
