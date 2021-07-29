///name of the file that has all the memory strings
#define MEMORY_FILE "memories.json"
///name of the file that has all the saved engravings
#define ENGRAVING_SAVE_FILE "data/engravings/[SSmapping.config.map_name]_engravings.json"
///how many engravings will be loaded max with persistence
#define MAX_PERSISTENT_ENGRAVINGS 20

///threshold for the memory being a happy one 8)
#define MEMORY_HAPPY_THRESHOLD 7
///threshold for the memory being a sad one :^(
#define MEMORY_SAD_THRESHOLD 7
///moodlet set if the creature with the memory doesn't use mood (doesn't include mood line)
#define MOODLESS_MEMORY "nope"

//These defines are for what notable event happened
///a memory of completing a surgery.
#define MEMORY_SUCCESSFUL_SURGERY "surgery"
///a memory of priming a bomb
#define MEMORY_BOMB_PRIMED "bomb"
///a memory of pulling off either a high five or a high ten
#define MEMORY_HIGH_FIVE "highfive"
///a memory of getting borged
#define MEMORY_BORGED "borged"
///a memory of dying! includes time of death
#define MEMORY_DEATH "death"
///a memory of being creampied! Mentions where
#define MEMORY_CREAMPIED "creampied"
///a memory of being slipped! Mentions on what
#define MEMORY_SLIPPED "slipped"
///A memory of letting my spaghetti spill, how embarrasing!
#define MEMORY_SPAGHETTI_SPILL "spaghetti_spilled"
///A memory of getting a kiss blown. Provides the kisser and kissee.
#define MEMORY_KISS "kiss"

///YOU HAVE WRITTEN MEMORY FLAVOR TO THIS POINT//

///a memory of getting gibbed, an alternate to death
#define MEMORY_GIBBING "gibbed"

/**
 * These are also memories, but they're examples of what I kinda don't want to be memories. They're stuff that I had to port
 * over to this system from the old old and they don't make for good examples
 *
 * ideally these eventually get moved off this system
 */
///your memorized code
#define MEMORY_ACCOUNT "account"
///your memorized drug
#define MEMORY_QUIRK_DRUG "quirk_drug"
///your allergy
#define MEMORY_ALLERGY "allergy"

//These defines are for what the story is for, they should be defined as what part of the json file they interact with
///wall engraving stories
#define STORY_ENGRAVING "engravings"
///changeling memory reading
#define STORY_CHANGELING_ABSORB "changeling_absorb"

//These defines are story flags for including special bits on the generated story.
///include a date this event happened
#define STORY_FLAG_DATED (1<<0)

///Generic memory info keys
#define DETAIL_WHERE "WHERE"
#define DETAIL_VICTIM "VICTIM"
#define DETAIL_WHAT_BY "WHAT_BY"

//Specific memory info keys
#define DETAIL_SURGERY_TYPE "SURGERY_TYPE"
#define DETAIL_TIME_OF_DEATH "TIME_OF_DEATH"
#define DETAIL_ALLERGY_TYPE "ALLERGY_TYPE"
#define DETAIL_FAV_BRAND "FAV_BRAND"
#define DETAIL_HIGHFIVE_TYPE "HIGHFIVE_TYPE"
#define DETAIL_BOMB_TYPE "BOMB_TYPE"
#define DETAIL_ACCOUNT_ID "ACCOUNT_ID"
#define DETAIL_KISSER "KISSER"



