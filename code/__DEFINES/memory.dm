///name of the file that has all the memory strings
#define MEMORY_FILE "memories.json"
///name of the file that has all the saved engravings
#define ENGRAVING_SAVE_FILE "data/engravings/[SSmapping.config.map_name]_engravings.json"
///how many engravings will be loaded max with persistence
#define MAX_PERSISTENT_ENGRAVINGS 20

///replacement for null that makes the memory additions more readable and as such more addable
#define NO_TARGET null

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
