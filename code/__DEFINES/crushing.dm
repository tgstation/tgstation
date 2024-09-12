// from _vending.dm

/// Set if the tipped object successfully crushed a subtype of /mob/living.
#define SUCCESSFULLY_CRUSHED_MOB (1<<0)
/// Set if the tipped object successfully crushed a subtype of /atom.
#define SUCCESSFULLY_CRUSHED_ATOM (1<<1)
/// Set if the tipped object successfully actually fell over, which can fail if it couldn't enter the turf it tried to fall into.
#define SUCCESSFULLY_FELL_OVER (1<<2)

#define CRUSH_CRIT_SHATTER_LEGS "crush_crit_shatter_legs"
#define CRUSH_CRIT_PARAPLEGIC "crush_crit_paraplegic"
#define CRUSH_CRIT_SQUISH_LIMB "crush_crit_pin"
#define CRUSH_CRIT_HEADGIB "crush_crit_headgib"
#define VENDOR_CRUSH_CRIT_PIN "vendor_crush_crit_pin"
#define VENDOR_CRUSH_CRIT_GLASSCANDY "vendor_crush_crit_glasscandy"
