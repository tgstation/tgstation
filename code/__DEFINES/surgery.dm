/// Helper to figure out if an organ is organic
#define IS_ORGANIC_ORGAN(organ) (organ.organ_flags & ORGAN_ORGANIC)
/// Helper to figure out if an organ is robotic
#define IS_ROBOTIC_ORGAN(organ) (organ.organ_flags & ORGAN_ROBOTIC)

/// List of organ flags that can not be bioscrambled
#define ORGAN_BIOSCRAMBLE_INCOMPATIBLE (ORGAN_ROBOTIC | ORGAN_MINERAL)
/// Check to see if an organ can be bioscrambled
#define ORGAN_CAN_BE_BIOSCRAMBLED(organ) (!(organ.organ_flags & ORGAN_BIOSCRAMBLE_INCOMPATIBLE) && !(organ.flags_1 & HOLOGRAM_1))

// Flags for the organ_flags var on /obj/item/organ
/// Organic organs, the default. Don't get affected by EMPs.
#define ORGAN_ORGANIC (1<<0)
/// Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_ROBOTIC (1<<1)
/// Mineral organs. Snowflakey.
#define ORGAN_MINERAL (1<<2)
/// Frozen organs, don't deteriorate
#define ORGAN_FROZEN (1<<3)
/// Failing organs perform damaging effects until replaced or fixed, and typically they don't function properly either
#define ORGAN_FAILING (1<<4)
/// Synthetic organ affected by an EMP. Deteriorates over time.
#define ORGAN_EMP (1<<5)
/// Currently only the brain - Removing this organ KILLS the owner
#define ORGAN_VITAL (1<<6)
/// Can be eaten
#define ORGAN_EDIBLE (1<<7)
/// Can't be removed using surgery or other common means
#define ORGAN_UNREMOVABLE (1<<8)
/// Can't be seen by scanners, doesn't anger body purists
#define ORGAN_HIDDEN (1<<9)
/// Has the organ already been inserted inside someone
#define ORGAN_VIRGIN (1<<10)
/// ALWAYS show this when scanned by advanced scanners, even if it is totally healthy
#define ORGAN_PROMINENT (1<<11)
/// An organ that is ostensibly dangerous when inside a body
#define ORGAN_HAZARDOUS (1<<12)
/// This is an external organ, not an inner one. Used in several checks.
#define ORGAN_EXTERNAL (1<<13)
/// This is a ghost organ, which can be used for wall phasing.
#define ORGAN_GHOST (1<<14)
/// This is a mutant organ, having this makes you a -derived mutant to health analyzers.
#define ORGAN_MUTANT (1<<15)
/// The organ has been chomped or otherwise rendered unusable.
#define ORGAN_UNUSABLE (1<<16)

/// Organ flags that correspond to bodytypes
#define ORGAN_TYPE_FLAGS (ORGAN_ORGANIC | ORGAN_ROBOTIC | ORGAN_MINERAL | ORGAN_GHOST)

/// Scarring on the right eye
#define RIGHT_EYE_SCAR (1<<0)
/// Scarring on the left eye
#define LEFT_EYE_SCAR (1<<1)

/// Checks if the mob is lying down if they can lie down, otherwise always passes
#define IS_LYING_OR_CANNOT_LIE(mob) ((mob.mobility_flags & MOBILITY_LIEDOWN) ? (mob.body_position == LYING_DOWN) : TRUE)

/// Applies moodlets after the surgical operation is complete
#define OPERATION_AFFECTS_MOOD (1<<0)
/// Notable operations are specially logged and also leave memories
#define OPERATION_NOTABLE (1<<1)
/// Operation will automatically repeat until it can no longer be performed
#define OPERATION_LOOPING (1<<2)
/// Grants a speed bonus if the user is morbid and their tool is morbid
#define OPERATION_MORBID (1<<3)
/// Not innately available to doctors, must be added via COMSIG_MOB_ATTEMPT_SURGERY to show up
#define OPERATION_LOCKED (1<<4)
/// A surgeon can perform this operation on themselves
#define OPERATION_SELF_OPERABLE (1<<5)
/// Operation can be performed on standing patients - note: mobs that cannot lie down are *always* considered lying down for surgery
#define OPERATION_STANDING_ALLOWED (1<<6)
/// Some traits may cause operations to be infalliable - this flag disables that behavior, always allowing it to be failed
#define OPERATION_ALWAYS_FAILABLE (1<<7)
/// If set, the operation will ignore clothing when checking for access to the target body part.
#define OPERATION_IGNORE_CLOTHES (1<<8)
/// This operation should be prioritized as the next step in a surgery sequence. (In the operating computer it will flash red)
#define OPERATION_PRIORITY_NEXT_STEP (1<<9)
/// Operation is a mechanic / robotic surgery
#define OPERATION_MECHANIC (1<<10)
/// Hides the operation from autowiki generation
#define OPERATION_NO_WIKI (1<<11)
/// This operation can be performed on a detached limb
#define OPERATION_NO_PATIENT_REQUIRED (1<<12)

DEFINE_BITFIELD(operation_flags, list(
	"AFFECTS MOOD" = OPERATION_AFFECTS_MOOD,
	"NOTABLE" = OPERATION_NOTABLE,
	"LOOPING" = OPERATION_LOOPING,
	"MORBID" = OPERATION_MORBID,
	"LOCKED" = OPERATION_LOCKED,
	"SELF OPERABLE" = OPERATION_SELF_OPERABLE,
	"STANDING ALLOWED" = OPERATION_STANDING_ALLOWED,
	"ALWAYS FAILABLE" = OPERATION_ALWAYS_FAILABLE,
	"IGNORE CLOTHES" = OPERATION_IGNORE_CLOTHES,
	"PRIORITY NEXT STEP" = OPERATION_PRIORITY_NEXT_STEP,
	"MECHANIC" = OPERATION_MECHANIC,
))

/// All of these equipment slots are ignored when checking for clothing coverage during surgery
#define IGNORED_OPERATION_CLOTHING_SLOTS (ITEM_SLOT_NECK)

// Surgery related mood defines
#define SURGERY_STATE_STARTED "surgery_started"
#define SURGERY_STATE_FAILURE "surgery_failed"
#define SURGERY_STATE_SUCCESS "surgery_success"
#define SURGERY_MOOD_CATEGORY "surgery"

/// Dummy "tool" for surgeries which use hands
#define IMPLEMENT_HAND "hands"

/// Surgery speed modifiers are soft-capped at this value
/// The actual modifier can exceed this but it gets
#define SURGERY_MODIFIER_FAILURE_THRESHOLD 2.5
/// There is an x percent chance of failure per second beyond 2.5x the base surgery time
#define FAILURE_CHANCE_PER_SECOND 10
/// Calculates failure chance of an operation based on the base time and the effective speed modifier
/// This may look something like: Base time 1 second and 4x effective multiplier -> 4 seconds - 2.5 seconds = 1.5 seconds * 10 = 15% failure chance
/// Or: Base time 2 seconds and 1x effective multiplier -> 2 seconds - 5 seconds = -3 seconds * 10 = -30% failure chance (clamped to 0%)
#define GET_FAILURE_CHANCE(base_time, speed_mod) (FAILURE_CHANCE_PER_SECOND * (((speed_mod * (base_time)) - (SURGERY_MODIFIER_FAILURE_THRESHOLD * (base_time))) / (1 SECONDS)))

// Operation argument indexes
/// Total speed/failure modifier applied to the operation
#define OPERATION_SPEED "speed_modifier"
/// The action being performed, simply "default" for 95% of surgeries
#define OPERATION_ACTION "action"
/// Whether the operation should automatically fail
#define OPERATION_FORCE_FAIL "force_fail"
/// The body zone being targeted by the operation
#define OPERATION_TARGET_ZONE "target_zone"
/// The specific target of the operation, usually a bodypart or organ, generally redundant
#define OPERATION_TARGET "target"
// For tend wounds - only reason these aren't local is we use them in unit testing
#define OPERATION_BRUTE_HEAL "brute_heal"
#define OPERATION_BURN_HEAL "burn_heal"
#define OPERATION_BRUTE_MULTIPLIER "brute_multiplier"
#define OPERATION_BURN_MULTIPLIER "burn_multiplier"

/// Used in string formatting to print a limb as "John's right arm" or "the human right arm"
#define FORMAT_LIMB_OWNER(limb) (limb.owner ? "[limb.owner]'s [limb.plaintext_zone]" : limb)
/// Used in string formatting to print an organ's location as "John" or "the human chest"
#define FORMAT_ORGAN_OWNER(organ) (organ.owner || organ.loc)

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

/// How much blood is lost from unclamped vessels?
#define UNCLAMPED_VESSELS_BLEEDING 1.5
/// How much blood is lost from clamped vessels or cut organs?
#define CLAMPED_VESSELS_BLEEDING 0.2
