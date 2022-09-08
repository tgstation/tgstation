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

// Surgery Sounds
#define SURGERY_SOUND_CAUTERY_ONE 'sound/surgery/cautery1.ogg'
#define SURGERY_SOUND_CAUTERY_TWO 'sound/surgery/cautery2.ogg'
#define SURGERY_SOUND_HEMOSTAT 'sound/surgery/hemostat1.ogg'
#define SURGERY_SOUND_ORGAN_ONE 'sound/surgery/organ1.ogg'
#define SURGERY_SOUND_ORGAN_TWO 'sound/surgery/organ2.ogg'
#define SURGERY_SOUND_RETRACTOR_ONE 'sound/surgery/retractor1.ogg'
#define SURGERY_SOUND_RETRACTOR_TWO 'sound/surgery/retractor2.ogg'
#define SURGERY_SOUND_SAW 'sound/surgery/saw.ogg'
#define SURGERY_SOUND_SCALPEL_ONE 'sound/surgery/scalpel1.ogg'
#define SURGERY_SOUND_SCALPEL_TWO 'sound/surgery/scalpel2.ogg'
