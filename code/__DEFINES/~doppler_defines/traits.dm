////
// Skills
////
/// trait that lets you do xenoarch magnification
#define TRAIT_XENOARCH_QUALIFIED "trait_xenoarch_qualified"
/// Traits granted by glassblowing
#define TRAIT_GLASSBLOWING "glassblowing"
/// Trait that is applied whenever someone or something is glassblowing
#define TRAIT_CURRENTLY_GLASSBLOWING "currently_glassblowing"

////
// Species
////
/// Trait for hemophages particularly!
#define TRAIT_OXYIMMUNE	"oxyimmune" // Immune to oxygen damage, ideally give this to all non-breathing species or bad stuff will happen
/// Trait that defines if an android species type is charging their cell
#define TRAIT_CHARGING "charging"
/// Trait which lets species pick from a list of animal traits, used by genemod + subtypes and anthromorphs
#define TRAIT_ANIMALISTIC "animalistic"
// Green blood traits
#define TRAIT_GREEN_BLOOD "green_blood"
// Blue blood traits
#define TRAIT_BLUE_BLOOD "blue_blood"
// Trait that lets golems put stone limbs back on
#define TRAIT_GOLEM_LIMBATTACHMENT "golem_limbattachment"

////
// Quirks
////
/// Trait for extra language point.
#define TRAIT_LINGUIST "linguist"
/// Trait for the excitable quirk, woof!
#define TRAIT_EXCITABLE "wagwag"
/// Trait for if you are left handed
#define TRAIT_LEFT_HANDED "left_handed"
/// Trait for people with the cybernetic quirk
#define TRAIT_PERMITTED_CYBERNETIC "permitted_cybernetic"
/// No step on glass
#define TRAIT_HARD_SOLES "hard_soles"

////
// Jobs
////
/// Given to the detective, if they have this, they can see syndicate special descriptions.
#define TRAIT_DETECTIVE "detective_ability"

////
// Reagents
////
/// Trait that was granted by a reagent.
#define REAGENT_TRAIT "reagent"
/// Trait that changes the ending effects of twitch leaving your system
#define TRAIT_TWITCH_ADAPTED "twitch_adapted"

////
// Wounds
////
/// When someone is fixing electrical damage, this trait is set and prevents the wound from worsening.
// We use a trait to avoid erronous setting of a variable to false if two people are repairing and one stops.
#define TRAIT_ELECTRICAL_DAMAGE_REPAIRING "electrical_damage_repairing"

////
// Speech
////
/// Trait for muting only speech, but allowing emotes.
#define TRAIT_SPEECH_ONLY_MUTE "speech_only_mute"
