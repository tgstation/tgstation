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
/// Can detach cybernetic limbs voluntarily
#define TRAIT_ROBOTIC_LIMBATTACHMENT "robotic_limbattachment"
/// This person has the same taste in food as a different species
#define TRAIT_ATYPICAL_TASTER "atypical_taster"
/// This person is space-acclimated and can "spacer-swim" on zero gravity turfs inside light atmosphere.
#define TRAIT_SPACER_SWIM "spacer_swim"
/// This person has criminal connections and is able to benefit from whatever those entail (allows viewing of exploitables upon examine)
#define TRAIT_CRIMINAL_CONNECTIONS "criminal_connections"
////
// Jobs
////
/// Given to the detective, if they have this, they can see syndicate special descriptions.
#define TRAIT_DETECTIVE "detective_ability"

/// Used to quickly earmark mobs as bit avatars
#define TRAIT_BITRUNNER_AVATAR "bitrunner_avatar"

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

////
// Items
////

#define TRAIT_WORN_EXAMINE "worn_examine"
/// Trait given to a brain that is able to accept souls from a RSD
#define TRAIT_RSD_COMPATIBLE "rsd_compatible"

////
// Powers
////

#define TRAIT_POWER "power_trait"

#define TRAIT_PATH_SORCEROUS "path_sorcerous"
#define TRAIT_PATH_RESONANT "path_resonant"
#define TRAIT_PATH_MORTAL "path_mortal"

// Sorcerous
#define TRAIT_PATH_SUBTYPE_THAUMATURGE "subtype_thamaturge"
#define TRAIT_PATH_SUBTYPE_ENIGMATIST "subtype_engimatist"
#define TRAIT_PATH_SUBTYPE_THEOLOGIST "subtype_theologist"

// Resonant
#define TRAIT_PATH_SUBTYPE_PSYKER "subtype_psyker"
#define TRAIT_PATH_SUBTYPE_CULTIVATOR "subtype_cultivator"
#define TRAIT_PATH_SUBTYPE_ABERRANT "subtype_aberrant"

// Mortal
#define TRAIT_PATH_SUBTYPE_WARFIGHTER "subtype_warfighter"
#define TRAIT_PATH_SUBTYPE_EXPERT "subtype_expert"
#define TRAIT_PATH_SUBTYPE_AUGMENTED "subtype_augmented"

// Powers
#define TRAIT_POWER_TENACIOUS "power_tenacious"
#define TRAIT_POWER_MUSCLY "power_muscly"
#define TRAIT_POWER_BESTIAL "power_bestial"
#define TRAIT_POWER_CQB "power_cqb"
#define TRAIT_POWER_SNIPER "power_sniper"
#define TRAIT_POWER_MEDICAL "power_medical"
#define TRAIT_POWER_ENGINEERING "power_engineering"
#define TRAIT_POWER_SERVICE "power_service"
