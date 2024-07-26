//bitfield defines

///can honkbots slip people?
#define HONKBOT_MODE_SLIP (1<<0)
///can honkbots check IDs?
#define HONKBOT_CHECK_IDS (1<<1)
///can honkbots check records?
#define HONKBOT_CHECK_RECORDS (1<<2)
///can honkbots handcuff people?
#define HONKBOT_HANDCUFF_TARGET (1<<3)

DEFINE_BITFIELD(honkbot_flags, list(
	"CAN_SLIP" = HONKBOT_MODE_SLIP,
	"CHECK_IDS" = HONKBOT_CHECK_IDS,
	"CHECK_RECORDS" = HONKBOT_CHECK_RECORDS,
	"CAN_FAKE_CUFF" = HONKBOT_HANDCUFF_TARGET,
))


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

//Honkbots
///key that holds all possible clown friends
#define BB_CLOWNS_LIST "clowns_list"
///key that holds the clown we play with
#define BB_CLOWN_FRIEND "clown_friend"
///key that holds the list of slippery items
#define BB_SLIPPERY_ITEMS "slippery_items"
///key that holds list of types we will attempt to slip
#define BB_SLIP_LIST "slip_list"
///key that holds the slippery item we will drag people too
#define BB_SLIPPERY_TARGET "slippery_target"
///key that holds the victim we will slip
#define BB_SLIP_TARGET "slip_target"
///key that holds our honk ability
#define BB_HONK_ABILITY "honk_ability"

//firebot keys
///things we can extinguish
#define BB_FIREBOT_CAN_EXTINGUISH "can_extinguish"
///the target we will extinguish
#define BB_FIREBOT_EXTINGUISH_TARGET "extinguish_target"
///lines we say when we detect a fire
#define BB_FIREBOT_FIRE_DETECTED_LINES "fire_detected_lines"
///lines we say when we are idle
#define BB_FIREBOT_IDLE_LINES "idle_lines"
///lines we say when we are emagged
#define BB_FIREBOT_EMAGGED_LINES "emagged_lines"

//vibebots
///key that holds our partying ability
#define BB_VIBEBOT_PARTY_ABILITY "party_ability"
///key that holds our birthday song
#define BB_VIBEBOT_BIRTHDAY_SONG "birthday_song"
///key that holds happy songs we play to depressed targets
#define BB_VIBEBOT_HAPPY_SONG "happy_song"
///key that holds grim song we play when emagged
#define BB_VIBEBOT_GRIM_SONG "GRIM_song"
///key that holds neutral targets we vibe with
#define BB_VIBEBOT_PARTY_TARGET "party_target"
///key that holds our instrument
#define BB_VIBEBOT_INSTRUMENT "instrument"
