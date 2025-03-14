///The standard amount of bodyparts a carbon has. Currently 6, HEAD/L_ARM/R_ARM/CHEST/L_LEG/R_LEG
#define BODYPARTS_DEFAULT_MAXIMUM 6

/// Limb Health

/// The max damage a limb can take before it stops taking damage.
/// Used by the max_damage var.
#define LIMB_MAX_HP_PROSTHESIS 20 //Used by surplus prosthesis limbs.
#define LIMB_MAX_HP_DEFAULT 50 //Used by most all limbs by default.
#define LIMB_MAX_HP_ADVANCED 75 //Used by advanced robotic limbs.
#define LIMB_MAX_HP_CORE 200 //Only use this for heads and torsos.

/// Xenomorph Limbs
#define LIMB_MAX_HP_ALIEN_LARVA 50 //Used by the weird larva chest and head. Did you know they have those?
#define LIMB_MAX_HP_ALIEN_LIMBS 100 //Used by xenomorph limbs.
#define LIMB_MAX_HP_ALIEN_CORE 500 //Used by xenomorph chests and heads
#define LIMB_ALIEN_BURN_DAMAGE_MULTIPLIER 2 //Used by xenomorphs and their larvae

/// Limb Body Damage Coefficient
/// A multiplication of the burn and brute damage that the limb's stored damage contributes to its attached mob's overall wellbeing.
/// For instance, if a limb has 50 damage, and has a coefficient of 50%, the human is considered to have suffered 25 damage to their total health.

#define LIMB_BODY_DAMAGE_COEFFICIENT_ADVANCED 0.5 //Used by advanced robotic limbs.
#define LIMB_BODY_DAMAGE_COEFFICIENT_DEFAULT 0.75 //Used by all limbs by default.
#define LIMB_BODY_DAMAGE_COEFFICIENT_TOTAL 1 //Used by heads and torsos
#define LIMB_BODY_DAMAGE_COEFFICIENT_PROSTHESIS 2.5 //Used by surplus prosthesis limbs

// EMP
// Note most of these values are doubled on heavy EMP

/// The brute damage an augged limb takes from an EMP.
#define AUGGED_LIMB_EMP_BRUTE_DAMAGE 2
/// The brute damage an augged limb takes from an EMP.
#define AUGGED_LIMB_EMP_BURN_DAMAGE 1.5

/// When hit by an EMP, the time an augged limb will be paralyzed for if its above the damage threshold.
#define AUGGED_LIMB_EMP_PARALYZE_TIME 3 SECONDS

/// When hit by an EMP, the time an augged leg will be knocked down for.
#define AUGGED_LEG_EMP_KNOCKDOWN_TIME 3 SECONDS
/// When hit by an EMP, the time a augged chest will cause a hardstun for if its above the damage threshold.
#define AUGGED_CHEST_EMP_STUN_TIME 3 SECONDS
/// When hit by an EMP, the time an augged chest will cause the mob to shake() for.
#define AUGGED_CHEST_EMP_SHAKE_TIME 5 SECONDS
/// When hit by an EMP, the time an augged head will make vision fucky for.
#define AUGGED_HEAD_EMP_GLITCH_DURATION 6 SECONDS

// Color priorities for bodyparts
/// Abductor team recoloring priority
#define LIMB_COLOR_AYYLMAO 5
/// Hulk effect color priority
#define LIMB_COLOR_HULK 10
/// Carp infusion color priority
#define LIMB_COLOR_CARP_INFUSION 20
#define LIMB_COLOR_CS_SOURCE_SUICIDE 30
/// Base priority for atom colors, gets atom priorities added to it
#define LIMB_COLOR_ATOM_COLOR 40
/// Voidwalker effect color priority
#define LIMB_COLOR_VOIDWALKER_CURSE 50

// Overlay priorities
#define BODYPART_OVERLAY_CARP_INFUSION 1
#define BODYPART_OVERLAY_CSS_SUICIDE 2
#define BODYPART_OVERLAY_VOIDWALKER_CURSE 3
