// bot keys
///The first beacon we find
#define BB_BEACON_TARGET "beacon_target"
///The last beacon we found, we will use its codes to find the next beacon
#define BB_PREVIOUS_BEACON_TARGET "previous_beacon_target"
///Location of whoever summoned us
#define BB_BOT_SUMMON_TARGET "bot_summon_target"
///salute messages to beepsky
#define BB_SALUTE_MESSAGES "salute_messages"
///the beepsky we will salute
#define BB_SALUTE_TARGET "salute_target"
///our announcement ability
#define BB_ANNOUNCE_ABILITY "announce_ability"
///list of our radio channels
#define BB_RADIO_CHANNEL "radio_channel"
///list of unreachable things we will temporarily ignore
#define BB_TEMPORARY_IGNORE_LIST "temporary_ignore_list"
///Last thing we attempted to reach
#define BB_LAST_ATTEMPTED_PATHING "last_attempted_pathing"

// medbot keys
///the patient we must heal
#define BB_PATIENT_TARGET "patient_target"
///list holding our wait dialogue
#define BB_WAIT_SPEECH "wait_speech"
///what we will say to our patient after we heal them
#define BB_AFTERHEAL_SPEECH "afterheal_speech"
///things we will say when we are bored
#define BB_IDLE_SPEECH "idle_speech"
///speech unlocked after being emagged
#define BB_EMAGGED_SPEECH "emagged_speech"
///speech when we are tipped
#define BB_WORRIED_ANNOUNCEMENTS "worried_announcements"
///speech when our patient is near death
#define BB_NEAR_DEATH_SPEECH "near_death_speech"
///in crit patient we must alert medbay about
#define BB_PATIENT_IN_CRIT "patient_in_crit"
///how much time interval before we clear list
#define BB_UNREACHABLE_LIST_COOLDOWN "unreachable_list_cooldown"
///can we clear the list now
#define	BB_CLEAR_LIST_READY "clear_list_ready"

// cleanbots
///key that holds the foaming ability
#define BB_CLEANBOT_FOAM "cleanbot_foam"
///key that holds decals we hunt
#define BB_CLEANABLE_DECALS "cleanable_decals"
///key that holds blood we hunt
#define BB_CLEANABLE_BLOOD "cleanable_blood"
///key that holds pests we hunt
#define BB_HUNTABLE_PESTS "huntable_pests"
///key that holds emagged speech
#define BB_CLEANBOT_EMAGGED_PHRASES "emagged_phrases"
///key that holds drawings we hunt
#define BB_CLEANABLE_DRAWINGS "cleanable_drawings"
///Key that holds our clean target
#define BB_CLEAN_TARGET "clean_target"
///key that holds the janitor we will befriend
#define BB_FRIENDLY_JANITOR "friendly_janitor"
///key that holds the victim we will spray
#define BB_ACID_SPRAY_TARGET "acid_spray_target"
///key that holds trash we will burn
#define BB_HUNTABLE_TRASH "huntable_trash"

//hygienebots
///key that holds our threats
#define BB_WASH_THREATS "wash_threats"
///key that holds speech when we find our target
#define BB_WASH_FOUND "wash_found"
///key that holds speech when we cleaned our target
#define BB_WASH_DONE "wash_done"
///key that holds target we will wash
#define BB_WASH_TARGET "wash_target"
///key that holds how frustrated we are when target is running away
#define BB_WASH_FRUSTRATION "wash_frustration"
///key that holds cooldown after we finish cleaning something, so we dont immediately run off to patrol
#define BB_POST_CLEAN_COOLDOWN "post_clean_cooldown"
