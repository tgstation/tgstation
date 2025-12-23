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
/// Untextured fish suicide color priority
#define LIMB_COLOR_CS_SOURCE_SUICIDE 30
/// Base priority for atom colors, gets atom priorities added to it
#define LIMB_COLOR_ATOM_COLOR 40
/// Voidwalker effect color priority
#define LIMB_COLOR_VOIDWALKER_CURSE 50

// Overlay priorities
#define BODYPART_OVERLAY_FISH_INFUSION 1
#define BODYPART_OVERLAY_CARP_INFUSION 2
#define BODYPART_OVERLAY_CSS_SUICIDE 3
#define BODYPART_OVERLAY_VOIDWALKER_CURSE 4

// Bodypart surgery state
/// An incision has been made into the skin
#define SURGERY_SKIN_CUT (1<<0)
/// Skin has been pulled back - 99% of surgeries require this
#define SURGERY_SKIN_OPEN (1<<1)
/// Blood vessels are accessible, cut, and bleeding
#define SURGERY_VESSELS_UNCLAMPED (1<<2)
/// Blood vessels are accessible but clamped
#define SURGERY_VESSELS_CLAMPED (1<<3)
/// Indicates either an incision has been made into the organs present in the limb or organs have been incised from the limb
#define SURGERY_ORGANS_CUT (1<<4)
/// Holes have been drilled in our bones, exclusive with sawed
#define SURGERY_BONE_DRILLED (1<<5)
/// Bones have been sawed apart
#define SURGERY_BONE_SAWED (1<<6)
/// Used in advanced plastic surgery: Has plastic been applied
#define SURGERY_PLASTIC_APPLIED (1<<7)
/// Used in prosthetic surgery: Is the prosthetic unsecured
#define SURGERY_PROSTHETIC_UNSECURED (1<<8)
/// Used for cavity implants
#define SURGERY_CAVITY_WIDENED (1<<9)

DEFINE_BITFIELD(surgery_state, list(
	"SKIN CUT" = SURGERY_SKIN_CUT,
	"SKIN OPEN" = SURGERY_SKIN_OPEN,
	"VESSELS UNCLAMPED" = SURGERY_VESSELS_UNCLAMPED,
	"VESSELS CLAMPED" = SURGERY_VESSELS_CLAMPED,
	"ORGANS CUT" = SURGERY_ORGANS_CUT,
	"BONE DRILLED" = SURGERY_BONE_DRILLED,
	"BONE SAWED" = SURGERY_BONE_SAWED,
	"PLASTIC APPLIED" = SURGERY_PLASTIC_APPLIED,
	"PROSTHETIC UNSECURED" = SURGERY_PROSTHETIC_UNSECURED,
	"CAVITY OPENED" = SURGERY_CAVITY_WIDENED,
))

/// For use in translating bitfield to human readable strings. Keep in the correct order!
#define SURGERY_STATE_READABLE list(\
	"Skin is cut" = SURGERY_SKIN_CUT, \
	"Skin is open" = SURGERY_SKIN_OPEN, \
	"Blood vessels are unclamped" = SURGERY_VESSELS_UNCLAMPED, \
	"Blood vessels are clamped" = SURGERY_VESSELS_CLAMPED, \
	"Organs are cut" = SURGERY_ORGANS_CUT, \
	"Bone is drilled" = SURGERY_BONE_DRILLED, \
	"Bone is sawed" = SURGERY_BONE_SAWED, \
	"Plastic is applied" = SURGERY_PLASTIC_APPLIED, \
	"Prosthetic is unsecured" = SURGERY_PROSTHETIC_UNSECURED, \
	"Cavity is opened wide" = SURGERY_CAVITY_WIDENED, \
)

/// For use in translating bitfield to steps required for surgery. Keep in the correct order!
#define SURGERY_STATE_GUIDES(must_must_not) list(\
	"the skin [must_must_not] be cut" = SURGERY_SKIN_CUT, \
	"the skin [must_must_not] be open" = SURGERY_SKIN_OPEN, \
	"the blood vessels [must_must_not] be unclamped" = SURGERY_VESSELS_UNCLAMPED, \
	"the blood vessels [must_must_not] be clamped" = SURGERY_VESSELS_CLAMPED, \
	"the organs [must_must_not] be cut" = SURGERY_ORGANS_CUT, \
	"the bone [must_must_not] be drilled" = SURGERY_BONE_DRILLED, \
	"the bone [must_must_not] be sawed" = SURGERY_BONE_SAWED, \
	"plastic [must_must_not] be applied" = SURGERY_PLASTIC_APPLIED, \
	"the prosthetic [must_must_not] be unsecured" = SURGERY_PROSTHETIC_UNSECURED, \
	"the chest cavity [must_must_not] be opened wide" = SURGERY_CAVITY_WIDENED, \
)

// Yes these are glorified bitflag manipulation macros, they're meant to make reading surgical operations a bit easier
/// Checks if the input surgery state has all of the bitflags passed
#define HAS_SURGERY_STATE(input_state, check_state) ((input_state & (check_state)) == (check_state))
/// Checks if the input surgery state has any of the bitflags passed
#define HAS_ANY_SURGERY_STATE(input_state, check_state) ((input_state & (check_state)))
/// Checks if the limb has all of the bitflags passed
#define LIMB_HAS_SURGERY_STATE(limb, check_state) HAS_SURGERY_STATE(limb?.surgery_state, check_state)
/// Checks if the limb has any of the bitflags passed
#define LIMB_HAS_ANY_SURGERY_STATE(limb, check_state) HAS_ANY_SURGERY_STATE(limb?.surgery_state, check_state)

/// All states that concern itself with the skin
#define ALL_SURGERY_SKIN_STATES (SURGERY_SKIN_CUT|SURGERY_SKIN_OPEN)
/// All states that concern itself with the blood vessels
#define ALL_SURGERY_VESSEL_STATES (SURGERY_VESSELS_UNCLAMPED|SURGERY_VESSELS_CLAMPED)
/// All states that concern itself with the bones
#define ALL_SURGERY_BONE_STATES (SURGERY_BONE_DRILLED|SURGERY_BONE_SAWED)
/// All states that concern itself with internal organs
#define ALL_SURGERY_ORGAN_STATES (SURGERY_ORGANS_CUT)

/// These states are automatically cleared when the surgery is closed for ease of use
#define ALL_SURGERY_STATES_UNSET_ON_CLOSE (ALL_SURGERY_SKIN_STATES|ALL_SURGERY_VESSEL_STATES|ALL_SURGERY_BONE_STATES|ALL_SURGERY_ORGAN_STATES|SURGERY_CAVITY_WIDENED)
/// Surgery state required for a limb with a certain zone to... be... fished... in...
#define ALL_SURGERY_FISH_STATES(for_zone) (SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|(for_zone == BODY_ZONE_CHEST ? SURGERY_BONE_SAWED : NONE))

/// Surgery states flipped on automatically if the bodypart lacks a form of skin
#define SKINLESS_SURGERY_STATES (SURGERY_SKIN_OPEN)
// (These are normally mutually exclusive, but as a bonus for lacking bones, you can do drill and saw operations simultaneously!)
/// Surgery states flipped on automatically if the bodypart lacks bones
#define BONELESS_SURGERY_STATES (SURGERY_BONE_DRILLED|SURGERY_BONE_SAWED)
/// Surgery states flipped on automatically if the bodypart lacks vessels
#define VESSELLESS_SURGERY_STATES (SURGERY_VESSELS_CLAMPED|SURGERY_ORGANS_CUT)

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
