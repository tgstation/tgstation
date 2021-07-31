
//Threshold levels for beauty for humans
#define BEAUTY_LEVEL_HORRID -66
#define BEAUTY_LEVEL_BAD -33
#define BEAUTY_LEVEL_DECENT 33
#define BEAUTY_LEVEL_GOOD 66
#define BEAUTY_LEVEL_GREAT 100

//Moods levels for humans
#define MOOD_LEVEL_HAPPY4 15
#define MOOD_LEVEL_HAPPY3 10
#define MOOD_LEVEL_HAPPY2 6
#define MOOD_LEVEL_HAPPY1 2
#define MOOD_LEVEL_NEUTRAL 0
#define MOOD_LEVEL_SAD1 -3
#define MOOD_LEVEL_SAD2 -7
#define MOOD_LEVEL_SAD3 -15
#define MOOD_LEVEL_SAD4 -20

//Sanity levels for humans
#define SANITY_MAXIMUM 150
#define SANITY_GREAT 125
#define SANITY_NEUTRAL 100
#define SANITY_DISTURBED 75
#define SANITY_UNSTABLE 50
#define SANITY_CRAZY 25
#define SANITY_INSANE 0

///value of the insanity effects (how much easier it is to crit the low mood person)
#define MOOD_NO_INSANITY 0
#define MOOD_MINOR_INSANITY 5
#define MOOD_MAJOR_INSANITY 10

///thresholds for the mood event values to get certain spans
#define MOOD_EVENT_BOLDWARNING_THRESHOLD -10
#define MOOD_EVENT_WARNING_THRESHOLD -1
#define MOOD_EVENT_NEUTRAL_THRESHOLD 0
#define MOOD_EVENT_NICEGREEN_THRESHOLD 1
#define MOOD_EVENT_BOLDNICEGREEN_THRESHOLD 8
