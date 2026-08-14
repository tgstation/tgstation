// Language flags
/// Language is never stuttered
#define LANGUAGE_NO_STUTTER (1<<0)
/// Language is speakable without a tongue
#define LANGUAGE_TONGUELESS_SPEECH (1<<1)
/// Language icon is hidden if the language is understood
#define LANGUAGE_HIDE_ICON_IF_UNDERSTOOD (1<<2)
/// Language icon is hidden if the language is not understood
#define LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD (1<<3)

// Returns from display_icon_type
/// Display no icon for this language
#define DISPLAY_LANGUAGE_ICON_NONE 0
/// Display the full icon for this language
#define DISPLAY_LANGUAGE_ICON_FULL 1
/// Display a blended icon for this language, indicating partial understanding
#define DISPLAY_LANGUAGE_ICON_PARTIAL 2

// LANGUAGE SOURCE DEFINES
/// For use in full removal only.
#define LANGUAGE_ALL "all"

// Generic language sources.
/// Language is linked to the movable directly.
#define LANGUAGE_ATOM "atom"
/// Language is linked to the mob's mind.
/// If a mind transfer happens, language follows.
#define LANGUAGE_MIND "mind"
/// Language is linked to the mob's species.
/// If a species change happens, language goes away.
/// If applied to a non-human (no species) atom, this is effectively the same as [LANGUAGE_ATOM].
#define LANGUAGE_SPECIES "species"

// More specific language sources.
// Only ever goes away when dismissed directly.
#define LANGUAGE_ABSORB "absorb"
#define LANGUAGE_APHASIA "aphasia"
#define LANGUAGE_BOUNTYHUNTER "bountyhunter"
#define LANGUAGE_CULTIST "cultist"
#define LANGUAGE_CURATOR "curator"
#define LANGUAGE_GLAND "gland"
#define LANGUAGE_HAT "hat"
#define LANGUAGE_QUIRK "quirk"
#define LANGUAGE_DRINK "drink"
#define LANGUAGE_MALF "malf"
#define LANGUAGE_PIRATE "pirate"
#define LANGUAGE_MASTER "master"
#define LANGUAGE_PAI "pai"
#define LANGUAGE_SOFTWARE "software"
#define LANGUAGE_STONER "stoner"
#define LANGUAGE_VOICECHANGE "voicechange"
#define LANGUAGE_RADIOKEY "radiokey"
#define LANGUAGE_BABEL "babel"
#define LANGUAGE_EMP "emp"
#define LANGUAGE_TONGUE "tongue"
#define LANGUAGE_BLOOD_WORM "blood_worm"

// Language flags. Used in granting and removing languages.
/// This language can be spoken.
#define SPOKEN_LANGUAGE (1<<0)
/// This language can be understood.
#define UNDERSTOOD_LANGUAGE (1<<1)
