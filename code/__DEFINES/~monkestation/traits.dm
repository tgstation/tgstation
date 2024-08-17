/// Given to Clockwork Golems, gives them a reduction on invoke time for certain scriptures
#define TRAIT_FASTER_SLAB_INVOKE "faster_slab_invoke"
/// Trait source for the vanguard scripture
#define VANGUARD_TRAIT "vanguard"
/// Has an item been enchanted by a clock cult Stargazer
#define TRAIT_STARGAZED "stargazed"
/// Trait source for the stargazer
#define STARGAZER_TRAIT "stargazer"
/// Prevents the invocation of clockwork scriptures
#define TRAIT_NO_SLAB_INVOKE "no_slab_invoke"
/// Indicates that they've inhaled helium.
#define TRAIT_HELIUM "helium"
/// Allows the user to start any surgery, anywhere. Mostly used by abductor scientists.
#define TRAIT_ALL_SURGERIES "all_surgeries"
/// Prevents the user from ever (unintentionally) failing a surgery step, and ensures they always have the maximum surgery speed.
#define TRAIT_PERFECT_SURGEON "perfect_surgeon"
/// Prevents the user from casting spells using sign language. Works on both /datum/mind and /mob/living.
#define TRAIT_CANT_SIGN_SPELLS "cant_sign_spells"
/// Ethereals with this trait will not suffer negative effects from overcharge.
#define TRAIT_ETHEREAL_NO_OVERCHARGE "ethereal_no_overcharge"
/// Indicates that the user has been removed from the crew manifest. Used to track if multiple antags have removed the same person.
#define TRAIT_REMOVED_FROM_MANIFEST "removed_from_manifest"
/// Station trait for when the clown has bridge access *shudders*
#define STATION_TRAIT_CLOWN_BRIDGE "clown_bridge"

// /datum/mind
/// Prevents any sort of antagonist/brainwashing conversion.
#define TRAIT_UNCONVERTABLE "unconvertable"


#define TRAIT_SENSOR_HUD "sensor_hud"
#define TRAIT_SHOVE_RESIST	"shove_resist" //Used by implants
#define TRAIT_FAST_CLIMBER 	"fast_climber" //Used by implants
#define ANTI_DROP_IMPLANT_TRAIT "antidrop_implant"
// /obj/item
/// Whether a storage item can be compressed by the bluespace compression kit, without the usual storage limitation.
#define TRAIT_BYPASS_COMPRESS_CHECK "can_compress_anyways"
/// This item is considered "trash" (and will be eaten by cleaner slimes)
#define TRAIT_TRASH_ITEM "trash_item"

#define ABDUCTOR_GLAND_VENTCRAWLING_TRAIT "abductor_gland_ventcrawling"
#define TRAIT_BETTER_CYBERCONNECTOR "better_cyberconnector_hacking"

/// Allows the user to instantly reload.
#define TRAIT_INSTANT_RELOAD "instant_reload"


// /turf/open
/// If a trait is considered as having "coverage" by a meteor shield.
#define TRAIT_COVERED_BY_METEOR_SHIELD		"covered_by_meteor_shield"
/// Liquids cannot spread over this turf.
#define TRAIT_BLOCK_LIQUID_SPREAD			"block_liquid_spread"

///added to structures we want the mobs to be able to target.
#define TRAIT_MOB_DESTROYABLE "mob_destroyable"
