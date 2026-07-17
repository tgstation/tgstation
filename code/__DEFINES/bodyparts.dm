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
/// Fish infusion color priority
#define LIMB_COLOR_FISH_INFUSION 15
/// Carp infusion color priority
#define LIMB_COLOR_CARP_INFUSION 20
/// Base priority for atom colors, gets atom priorities added to it
#define LIMB_COLOR_ATOM_COLOR 40
/// Voidwalker effect color priority
#define LIMB_COLOR_VOIDWALKER_CURSE 50

// Overlay priorities
#define BODYPART_OVERLAY_FISH_INFUSION 1
#define BODYPART_OVERLAY_CARP_INFUSION 2
#define BODYPART_OVERLAY_CSS_SUICIDE 3
#define BODYPART_OVERLAY_VOIDWALKER_CURSE 4

/// This limb cannot be disabled via damage thresholds
#define LIMB_NO_DISABLE -1

/// Helper to figure out if a limb is organic
#define IS_ORGANIC_LIMB(limb) (limb.bodytype & BODYTYPE_ORGANIC)
/// Helper to figure out if a limb is robotic
#define IS_ROBOTIC_LIMB(limb) (limb.bodytype & BODYTYPE_ROBOTIC)
/// Helper to figure out if a limb is a peg limb
#define IS_PEG_LIMB(limb) (limb.bodytype & BODYTYPE_PEG)

/// Is the bodypart a stump
#define IS_STUMP(limb) (limb.bodypart_flags & BODYPART_STUMP)

// Flags for the bodypart_flags var on /obj/item/bodypart
/// Bodypart cannot be dismembered or amputated
#define BODYPART_UNREMOVABLE (1<<0)
/// Bodypart is a pseudopart (like a chainsaw arm)
#define BODYPART_PSEUDOPART (1<<1)
/// Bodypart did not match the owner's default bodypart limb_id when surgically implanted
#define BODYPART_IMPLANTED (1<<2)
/// Bodypart never displays as a husk
#define BODYPART_UNHUSKABLE (1<<3)
/// Bodypart has never been added to a mob
#define BODYPART_VIRGIN (1<<4)
/// Not a full bodypart, but in fact is part of a missing limb
#define BODYPART_STUMP (1<<5)
/// Allow potential digitigrade status of legs to be retained after a replace_body() call (primarily species change)
#define BODYPART_RETAIN_DIGITIGRADE (1<<6)

// Bodypart change blocking flags
///Bodypart does not get replaced during set_species()
#define BP_BLOCK_CHANGE_SPECIES (1<<0)

// Flags for the head_flags var on /obj/item/bodypart/head
/// Head can have hair
#define HEAD_HAIR (1<<0)
/// Head can have facial hair
#define HEAD_FACIAL_HAIR (1<<1)
/// Head can have lips
#define HEAD_LIPS (1<<2)
/// Head can have eye sprites
#define HEAD_EYESPRITES (1<<3)
/// Head will have colored eye sprites
#define HEAD_EYECOLOR (1<<4)
/// Head can have eyeholes when missing eyes
#define HEAD_EYEHOLES (1<<5)
/// Head can have debrain overlay
#define HEAD_DEBRAIN (1<<6)
/// Head will never be disfigured by damage
#define HEAD_NO_DISFIGURE (1<<7)
/// Default for most heads
#define HEAD_DEFAULT_FEATURES (HEAD_HAIR|HEAD_FACIAL_HAIR|HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN)

/// Biological state that has some kind of skin that can be cut.
#define BIOSTATE_HAS_SKIN (BIO_FLESH|BIO_METAL|BIO_CHITIN)
/// Checks if a bodypart lacks both flesh and metal, meaning it has no skin to cut.
#define LIMB_HAS_SKIN(limb) (limb?.biological_state & BIOSTATE_HAS_SKIN)
/// Biological state that has some kind of bones that can be sawed.
#define BIOSTATE_HAS_BONES (BIO_BONE|BIO_METAL)
/// Checks if a bodypart lacks both bone and metal, meaning it has no bones to saw.
#define LIMB_HAS_BONES(limb) (limb?.biological_state & BIOSTATE_HAS_BONES)
/// Biological state that has some kind of vessels that can be clamped.
#define BIOSTATE_HAS_VESSELS (BIO_BLOODED|BIO_WIRED)
/// Checks if a bodypart lacks both blood and wires, meaning it has no vessels to manipulate.
#define LIMB_HAS_VESSELS(limb) (limb?.biological_state & BIOSTATE_HAS_VESSELS)

/// Do not draw this bodypart overlay on husks
#define HUSK_OVERLAY_NONE 0
/// Draw this overlay on husks but grayscale it
#define HUSK_OVERLAY_GRAYSCALE 1
/// Draw this overlay on husks as normal
#define HUSK_OVERLAY_NORMAL 2

// Limb item categories
/// Gauze slot, asserted to be wrap items
#define LIMB_ITEM_GAUZE "gauze"
/// Tourniquet slot
#define LIMB_ITEM_TOURNIQUET "tourniquet"
