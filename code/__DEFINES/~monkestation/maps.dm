// traits
// boolean - marks a level as having that property if present
#define ZTRAIT_REEBE "Reebe"

/// Marks a level as being "safe", even if it is a station z level.
/// Nukes will not kill players on such levels.
#define ZTRAIT_FORCED_SAFETY "Forced Safety"

///List of ztraits the reebe Z level has
#define ZTRAITS_REEBE list(ZTRAIT_REEBE = TRUE, ZTRAIT_NOPHASE = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0.5, ZTRAIT_RESERVED = TRUE)

#define is_safe_level(z) SSmapping.level_trait(z, ZTRAIT_FORCED_SAFETY)
