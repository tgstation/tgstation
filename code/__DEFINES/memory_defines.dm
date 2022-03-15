///name of the file that has all the memory strings
#define MEMORY_FILE "memories.json"
///name of the file that has all the saved engravings
#define ENGRAVING_SAVE_FILE "data/engravings/[SSmapping.config.map_name]_engravings.json"
///name of the file that has all the prisoner tattoos
#define PRISONER_TATTOO_SAVE_FILE "data/engravings/prisoner_tattoos.json"
///Current version of the engraving persistence json
#define ENGRAVING_PERSISTENCE_VERSION 0
///Current version of the tattoo persistence json
#define TATTOO_PERSISTENCE_VERSION 0

///how many engravings will be loaded max with persistence
#define MIN_PERSISTENT_ENGRAVINGS 15
#define MAX_PERSISTENT_ENGRAVINGS 25

///threshold for the memory being a happy one 8)
#define MEMORY_HAPPY_THRESHOLD 7
///threshold for the memory being a sad one :^(
#define MEMORY_SAD_THRESHOLD 7
///moodlet set if the creature with the memory doesn't use mood (doesn't include mood line)
#define MOODLESS_MEMORY "nope"

///Factor of how beauty is divided to make the engraving art value
#define ENGRAVING_BEAUTY_TO_ART_FACTOR 10
//Factor on how much beauty is removed from before adding the element on old engravings
#define ENGRAVING_PERSISTENCE_BEAUTY_LOSS_FACTOR 5

///How cool a story is!
#define STORY_VALUE_SHIT 0 // poo icon
#define STORY_VALUE_NONE 1 // |: face
#define STORY_VALUE_MEH 2 // bronze star
#define STORY_VALUE_OKAY 3 // silver star
#define STORY_VALUE_AMAZING 4 //gold star
#define STORY_VALUE_LEGENDARY 5 //platinum star

//Flags for memories
///this memory doesn't have a location, emit that
#define MEMORY_FLAG_NOLOCATION (1<<0)
///this memory's protagonist for one reason or another doesn't have a mood, emit that
#define MEMORY_FLAG_NOMOOD	(1<<1)
///this memory shouldn't include the station name (example: revolution memory)
#define MEMORY_FLAG_NOSTATIONNAME	(1<<2)
///this memory is REALLY shit and should never be saved in persistence, basically apply this to all quirks.
#define MEMORY_FLAG_NOPERSISTENCE	(1<<3)
///this memory has already been engraved, and cannot be selected for engraving again.
#define MEMORY_FLAG_ALREADY_USED	(1<<4)
///this memory requires the target not to be blind.
#define MEMORY_CHECK_BLINDNESS (1<<5)
///this memory requires the target not to be deaf.
#define MEMORY_CHECK_DEAFNESS (1<<6)
///this memory requires the target not to be both deaf and blind.
#define MEMORY_CHECK_BLIND_AND_DEAF (MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS)
///this memory can be memorized by unconscious people.
#define MEMORY_SKIP_UNCONSCIOUS (1<<8)

// These defines are for what notable event happened. they correspond to the json lists related to the memory
/// A memory of completing a surgery.
#define MEMORY_SUCCESSFUL_SURGERY "surgery"
/// A memory of priming a bomb
#define MEMORY_BOMB_PRIMED "bomb"
/// A memory of pulling off either a high five or a high ten
#define MEMORY_HIGH_FIVE "highfive"
/// A memory of getting borged
#define MEMORY_BORGED "borged"
/// A memory of dying! includes time of death
#define MEMORY_DEATH "death"
/// A memory of being creampied! Mentions where
#define MEMORY_CREAMPIED "creampied"
/// A memory of being slipped! Mentions on what
#define MEMORY_SLIPPED "slipped"
/// A memory of letting my spaghetti spill, how embarrasing!
#define MEMORY_SPAGHETTI_SPILL "spaghetti_spilled"
/// A memory of getting a kiss blown. Provides the kisser and kissee.
#define MEMORY_KISS "kiss"
/// A memory of a really good meal
#define MEMORY_MEAL "meal"
/// A memory of a really good drink
#define MEMORY_DRINK "drink"
/// A memory of being lit
#define MEMORY_FIRE "fire"
/// A memory of limb loss
#define MEMORY_DISMEMBERED "dismembered"
/// A memory of seeing a pet die
#define MEMORY_PET_DEAD "pet_dead"
/// A memory of leading a winning revolution
#define MEMORY_WON_REVOLUTION "won_revolution"
/// An award ceremony of a medal
#define MEMORY_RECEIVED_MEDAL "received_medal"
/// A megafauna kill!
#define MEMORY_MEGAFAUNA_KILL "megafauna_kill"
/// Being held at gunpoint
#define MEMORY_GUNPOINT "held_at_gunpoint"
/// Exploding into gibs
#define MEMORY_GIBBED "gibbed"
/// Crushed by vending machine
#define MEMORY_VENDING_CRUSHED "vending_crushed"
/// Dusted by SM
#define MEMORY_SUPERMATTER_DUSTED "supermatter_dusted"
/// Nuke ops nuke code memory
#define MEMORY_NUKECODE "nuke_code"
/// A memory of having to play 52 card pickup
#define MEMORY_PLAYING_52_PICKUP "playing_52_pickup"
/// A memory of playing cards with others
#define MEMORY_PLAYING_CARDS "playing_cards"


/**
 * These are also memories, but they're examples of what I kinda don't want to be memories. They're stuff that I had to port
 * over to this system from the old old and they don't make for good examples
*
 * ideally these eventually get moved off this system... though engraving your bank account is so HILARIOUSLY dumb so maybe leave that one
 */
///your memorized code
#define MEMORY_ACCOUNT "account"
///your memorized drug
#define MEMORY_QUIRK_DRUG "quirk_drug"
///your allergy
#define MEMORY_ALLERGY "allergy"

//These defines are for what the story is for, they should be defined as what part of the json file they interact with
///wall engraving stories
#define STORY_ENGRAVING "engraving"
///changeling memory reading
#define STORY_CHANGELING_ABSORB "changeling_absorb"
///tattoos
#define STORY_TATTOO "tattoo"

//These defines are story flags for including special bits on the generated story.
///include a date this event happened
#define STORY_FLAG_DATED (1<<0)

///Generic memory info keys. Use these whenever one of these is the case in a story, because we add extra story piece if these exist.
///The location of the memory, add these to have a chance of it being added to the story
#define DETAIL_WHERE "WHERE"
///The main subject of the memory. Should be whoever has the biggest impact on the story. (As it grabs the memory from this person)
#define DETAIL_PROTAGONIST "PROTAGONIST"
///Usually used bespokely by specific memory types and not added generically, but its generaly the object used to cause the memory. E.g. a peel to slip, the food that was eaten.
#define DETAIL_WHAT_BY "WHAT_BY"
///Used whenever a memory has a secondary character. Used bespokely by actions.
#define DETAIL_DEUTERAGONIST "DEUTERAGONIST"
///Automatically obtained details
#define DETAIL_PROTAGONIST_MOOD "VICTIM_MOOD"

//Specific memory info keys. they are used to replace json strings with memory specific data!
#define DETAIL_SURGERY_TYPE "SURGERY_TYPE"
#define DETAIL_TIME_OF_DEATH "TIME_OF_DEATH"
#define DETAIL_ALLERGY_TYPE "ALLERGY_TYPE"
#define DETAIL_FAV_BRAND "FAV_BRAND"
#define DETAIL_HIGHFIVE_TYPE "HIGHFIVE_TYPE"
#define DETAIL_BOMB_TYPE "BOMB_TYPE"
#define DETAIL_ACCOUNT_ID "ACCOUNT_ID"
#define DETAIL_KISSER "KISSER"
#define DETAIL_FOOD "FOOD"
#define DETAIL_DRINK "DRINK"
#define DETAIL_LOST_LIMB "LOST_LIMB"
#define DETAIL_STATION_NAME "STATION_NAME"
#define DETAIL_MEDAL_TYPE "MEDAL_TYPE"
#define DETAIL_MEDAL_REASON "MEDAL_REASON"
#define DETAIL_NUKE_CODE "NUKE_CODE"
// for cardgames
#define DETAIL_PLAYERS "PLAYERS"
#define DETAIL_CARDGAME "CARDGAME"
#define DETAIL_DEALER "DEALER"
#define DETAIL_HELD_CARD_ITEM "HELD_CARD_ITEM" // could either be a singlecard, cardhand, or a deck


