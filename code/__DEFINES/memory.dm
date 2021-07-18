///name of the file that has all the memory strings
#define MEMORY_FILE "memories.json"

///threshold for the memory being a happy one 8)
#define MEMORY_HAPPY_THRESHOLD 7
///threshold for the memory being a sad one :^(
#define MEMORY_SAD_THRESHOLD 7

//These defines are for what notable event happened
///a memory of completing a surgery.
#define MEMORY_SUCCESSFUL_SURGERY "surgery"

//These defines are for what the story is for, they should be defined as what part of the json file they interact with
///wall engraving stories
#define STORY_ENGRAVING "engravings"
///changeling memory reading
#define STORY_CHANGELING_ABSORB "changeling_absorb"

//These defines are story flags for including special bits on the generated story.
///include a date this event happened
#define STORY_FLAG_DATED (1<<0)
