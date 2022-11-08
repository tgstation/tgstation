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

///threshold for the memory being a happy one
#define MEMORY_HAPPY_THRESHOLD 7
///threshold for the memory being a sad one
#define MEMORY_SAD_THRESHOLD 7
///moodlet set if the creature with the memory doesn't use mood (doesn't include mood line)
#define MOODLESS_MEMORY "nope"

///Factor of how beauty is divided to make the engraving art value
#define ENGRAVING_BEAUTY_TO_ART_FACTOR 10
//Factor on how much beauty is removed from before adding the element on old engravings
#define ENGRAVING_PERSISTENCE_BEAUTY_LOSS_FACTOR 5

///How cool a story is!
#define STORY_VALUE_KEY -1 // key
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
#define MEMORY_FLAG_NOMOOD (1<<1)
///this memory shouldn't include the station name (example: revolution memory)
#define MEMORY_FLAG_NOSTATIONNAME (1<<2)
///this memory is REALLY shit and should never be saved in persistence, basically apply this to all quirks.
#define MEMORY_FLAG_NOPERSISTENCE (1<<3)
/// This memory has already been engraved, and cannot be selected for engraving again.
#define MEMORY_FLAG_ALREADY_USED (1<<4)
/// A blind mob cannot experience this memory.
#define MEMORY_CHECK_BLINDNESS (1<<5)
/// A deaf mbo cannot experience this memory.
#define MEMORY_CHECK_DEAFNESS (1<<6)
/// A mob which is currently unconscious can experience this memory.
#define MEMORY_SKIP_UNCONSCIOUS (1<<7)
/// This memory can't be selected for tattoo-ing or engraving
#define MEMORY_NO_STORY (1<<8)


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
