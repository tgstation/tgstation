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

/// Return value when the surgery step fails :(
#define SURGERY_STEP_FAIL -1

// Flags for surgery_flags on surgery datums
///Will allow the surgery to bypass clothes
#define SURGERY_IGNORE_CLOTHES (1<<0)
///Will allow the surgery to be performed by the user on themselves.
#define SURGERY_SELF_OPERABLE (1<<1)
///Will allow the surgery to work on mobs that aren't lying down.
#define SURGERY_REQUIRE_RESTING (1<<2)
///Will allow the surgery to work only if there's a limb.
#define SURGERY_REQUIRE_LIMB (1<<3)
///Will allow the surgery to work only if there's a real (eg. not pseudopart) limb.
#define SURGERY_REQUIRES_REAL_LIMB (1<<4)
///Will grant a bonus during surgery steps to users with TRAIT_MORBID while they're using tools with CRUEL_IMPLEMENT
#define SURGERY_MORBID_CURIOSITY (1<<5)
/**
 * Instead of checking if the tool used is an actual surgery tool to avoid accidentally whacking patients with the wrong tool,
 * it'll check if it has a defined tool behaviour instead. Useful for surgeries that use mechanical tools instead of medical ones,
 * like hardware manipulation.
 */
#define SURGERY_CHECK_TOOL_BEHAVIOUR (1<<6)

///Return true if target is not in a valid body position for the surgery
#define IS_IN_INVALID_SURGICAL_POSITION(target, surgery) ((surgery.surgery_flags & SURGERY_REQUIRE_RESTING) && (target.mobility_flags & MOBILITY_LIEDOWN && target.body_position != LYING_DOWN))
