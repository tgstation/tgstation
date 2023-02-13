// Flags for the organ_flags var on /obj/item/organ
///Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_SYNTHETIC (1<<0)
///Frozen organs, don't deteriorate
#define ORGAN_FROZEN (1<<1)
///Failing organs perform damaging effects until replaced or fixed
#define ORGAN_FAILING (1<<2)
///Currently only the brain
#define ORGAN_VITAL (1<<3)
///is a snack? :D
#define ORGAN_EDIBLE (1<<4)
///Synthetic organ affected by an EMP. Deteriorates over time.
#define ORGAN_SYNTHETIC_EMP (1<<5)
// //Can't be removed using surgery
#define ORGAN_UNREMOVABLE (1<<6)

/// When the surgery step fails :(
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
