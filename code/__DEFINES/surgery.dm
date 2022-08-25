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
