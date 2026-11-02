// Social ranks, age bands, Ratwood's position lists and known people (jobs/): the defines the module's systems share.

/// Ratwood's social ranks (__DEFINES/roguetown.dm SOCIAL_RANK_*): the standing of a role's holder, the numbers the porter
/// writes as rogue_social_rank of roles and subclasses (rockhill/port_data.dm).
#define ROGUE_SOCIAL_RANK_DIRT 1
#define ROGUE_SOCIAL_RANK_PEASANT 2
#define ROGUE_SOCIAL_RANK_YEOMAN 3
#define ROGUE_SOCIAL_RANK_MINOR_NOBLE 4
#define ROGUE_SOCIAL_RANK_NOBLE 5
#define ROGUE_SOCIAL_RANK_ROYAL 6

/// Ratwood's ages (__DEFINES ALL_AGES_LIST, AGE_IMMORTAL), the words of rogue_allowed_ages, as rogue_age_band() tells them
/// from the years (attributes/_defines.dm ROGUE_AGE_MIDDLE, ROGUE_AGE_OLD).
#define ROGUE_AGE_BAND_ADULT "Adult"
#define ROGUE_AGE_BAND_MIDDLE "Middle-Aged"
#define ROGUE_AGE_BAND_OLD "Old"
#define ROGUE_AGE_BAND_IMMORTAL "Immortal"

/// Ratwood's position lists (jobs/jobs.dm noble_positions and the rest): the keys of GLOB.rogue_positions.
#define ROGUE_POSITIONS_NOBLE "noble"
#define ROGUE_POSITIONS_COURTIER "courtier"
#define ROGUE_POSITIONS_GARRISON "garrison"
#define ROGUE_POSITIONS_CHURCH "church"
#define ROGUE_POSITIONS_INQUISITION "inquisition"
#define ROGUE_POSITIONS_YEOMAN "yeoman"
#define ROGUE_POSITIONS_PEASANT "peasant"
#define ROGUE_POSITIONS_YOUNGFOLK "youngfolk"

/// What a mind knows of a person it knows (Ratwood mind.dm known_people): the keys of an entry of
/// /datum/mind/var/rogue_known_people. Colour of the voice, the title the person goes by, gender, race, age band, house,
/// and the mark of a heresy the knower shares or sees.
#define ROGUE_KNOWN_COLOR "VCOLOR"
#define ROGUE_KNOWN_TITLE "FJOB"
#define ROGUE_KNOWN_GENDER "FGENDER"
#define ROGUE_KNOWN_RACE "FSPECIES"
#define ROGUE_KNOWN_AGE "FAGE"
#define ROGUE_KNOWN_HOUSE "FHOUSE"
#define ROGUE_KNOWN_HERESY "FHERESY"
