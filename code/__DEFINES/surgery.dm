/// Helper to figure out if an organ is organic
#define IS_ORGANIC_ORGAN(organ) (organ.organ_flags & ORGAN_ORGANIC)
/// Helper to figure out if an organ is robotic
#define IS_ROBOTIC_ORGAN(organ) (organ.organ_flags & ORGAN_ROBOTIC)

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

/// Helper to figure out if a limb is organic
#define IS_ORGANIC_LIMB(limb) (limb.bodytype & BODYTYPE_ORGANIC)
/// Helper to figure out if a limb is robotic
#define IS_ROBOTIC_LIMB(limb) (limb.bodytype & BODYTYPE_ROBOTIC)
/// Helper to figure out if a limb is a peg limb
#define IS_PEG_LIMB(limb) (limb.bodytype & BODYTYPE_PEG)

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
