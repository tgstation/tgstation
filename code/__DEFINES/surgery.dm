// Flags for the organ_flags var on /obj/item/organ
///Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_SYNTHETIC (1<<0)
///Frozen organs, don't deteriorate
#define ORGAN_FROZEN (1<<1)
///Failing organs perform damaging effects until replaced or fixed
#define ORGAN_FAILING (1<<2)
///Is this organ external? defines how to manipulate the organ, should generally be reserved to cosmetic organs like tails, horns and wings
#define ORGAN_EXTERNAL (1<<3)
///Currently only the brain
#define ORGAN_VITAL (1<<4)
///is a snack? :D
#define ORGAN_EDIBLE (1<<5)
///Synthetic organ affected by an EMP. Deteriorates over time.
#define ORGAN_SYNTHETIC_EMP (1<<6)
// //Can't be removed using surgery
#define ORGAN_UNREMOVABLE (1<<7)
DEFINE_BITFIELD(organ_flags, list(
	"ORGAN_SYNTHETIC" = ORGAN_SYNTHETIC,
	"ORGAN_FROZEN" = ORGAN_FROZEN,
	"ORGAN_FAILING" = ORGAN_FAILING,
	"ORGAN_EXTERNAL" = ORGAN_EXTERNAL,
	"ORGAN_VITAL" = ORGAN_VITAL,
	"ORGAN_EDIBLE" = ORGAN_EDIBLE,
	"ORGAN_SYNTHETIC_EMP" = ORGAN_SYNTHETIC_EMP,
	"ORGAN_UNREMOVABLE" = ORGAN_UNREMOVABLE,
))

/// When the surgery step fails :(
#define SURGERY_STEP_FAIL -1
