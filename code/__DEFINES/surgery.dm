/// Flags for the organ_flags var on /obj/item/organ. Binary 0 is skipped to avoid accidental features when someone forgets to set organ flags
#define ORGAN_SYNTHETIC (1<<1) //Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_FROZEN (1<<1) //Frozen organs, don't deteriorate
#define ORGAN_FAILING (1<<3) //Failing organs perform damaging effects until replaced or fixed
#define ORGAN_INTERNAL (1<<4) //majority of organs, like hearts, lungs, livers, etc
#define ORGAN_EXTERNAL (1<<5) //Was this organ implanted/inserted/etc, if true will not be removed during species change.
#define ORGAN_VITAL (1<<6) //Currently only the brain
#define ORGAN_EDIBLE (1<<7) //is a snack? :D
#define ORGAN_SYNTHETIC_EMP (1<<8) //Synthetic organ affected by an EMP. Deteriorates over time.
#define ORGAN_UNREMOVABLE (1<<9) //Can't be removed using surgery

DEFINE_BITFIELD(organ_flags, list(
	"ORGAN_SYNTHETIC" = ORGAN_SYNTHETIC,
	"ORGAN_FROZEN" = ORGAN_FROZEN,
	"ORGAN_FAILING" = ORGAN_FAILING,
	"ORGAN_INTERNAL" = ORGAN_INTERNAL,
	"ORGAN_EXTERNAL" = ORGAN_EXTERNAL,
	"ORGAN_VITAL" = ORGAN_VITAL,
	"ORGAN_EDIBLE" = ORGAN_EDIBLE,
	"ORGAN_SYNTHETIC_EMP" = ORGAN_SYNTHETIC_EMP,
	"ORGAN_UNREMOVABLE" = ORGAN_UNREMOVABLE,
))

/// When the surgery step fails :(
#define SURGERY_STEP_FAIL -1
