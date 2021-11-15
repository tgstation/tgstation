/** AI defines */

#define DEFAULT_AI_LAWID "default"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"

//AI notification defines
///Alert when a new Cyborg is created.
#define AI_NOTIFICATION_NEW_BORG 1
///Alert when a Cyborg selects a model.
#define AI_NOTIFICATION_NEW_MODEL 2
///Alert when a Cyborg changes their name.
#define AI_NOTIFICATION_CYBORG_RENAMED 3
///Alert when an AI disconnects themselves from their shell.
#define AI_NOTIFICATION_AI_SHELL 4
///Alert when a Cyborg gets disconnected from their AI.
#define AI_NOTIFICATION_CYBORG_DISCONNECTED 5

/** Cyborg defines */

/// Special value to reset cyborg's lamp_cooldown
#define BORG_LAMP_CD_RESET -1

//Module slot define
///The third module slots is disabed.
#define BORG_MODULE_THREE_DISABLED (1<<0)
///The second module slots is disabed.
#define BORG_MODULE_TWO_DISABLED (1<<1)
///All modules slots are disabled.
#define BORG_MODULE_ALL_DISABLED (1<<2)

//Cyborg module selection
///First Borg module slot.
#define BORG_CHOOSE_MODULE_ONE 1
///Second Borg module slot.
#define BORG_CHOOSE_MODULE_TWO 2
///Third Borg module slot.
#define BORG_CHOOSE_MODULE_THREE 3

#define SKIN_ICON "skin_icon"
#define SKIN_ICON_STATE "skin_icon_state"
#define SKIN_PIXEL_X "skin_pixel_x"
#define SKIN_PIXEL_Y "skin_pixel_y"
#define SKIN_LIGHT_KEY "skin_light_key"
#define SKIN_HAT_OFFSET "skin_hat_offset"
#define SKIN_TRAITS "skin_traits"

/** Simple Animal BOT defines */

//Bot defines, placed here so they can be read by other things!
/// Delay between movemements
#define BOT_STEP_DELAY 4
/// Maximum times a bot will retry to step from its position
#define BOT_STEP_MAX_RETRIES 5

/// Default view range for finding targets.
#define DEFAULT_SCAN_RANGE 7

//Bot types
/// Secutritrons (Beepsky)
#define SEC_BOT (1<<0)
/// ED-209s
#define ADVANCED_SEC_BOT (1<<1)
/// MULEbots
#define MULE_BOT (1<<2)
/// Floorbots
#define FLOOR_BOT (1<<3)
/// Cleanbots
#define CLEAN_BOT (1<<4)
/// Medibots
#define MED_BOT (1<<5)
/// Honkbots & ED-Honks
#define HONK_BOT (1<<6)
/// Firebots
#define FIRE_BOT (1<<7)
/// Hygienebots
#define HYGIENE_BOT (1<<8)
/// Vibe bots
#define VIBE_BOT (1<<9)

//Mode defines. If you add a new one make sure you update mode_name in /mob/living/simple_animal/bot
/// Idle
#define BOT_IDLE 0
/// Found target, hunting
#define BOT_HUNT 1
/// Currently tipped over.
#define BOT_TIPPED 2
/// Start patrol
#define BOT_START_PATROL 3
/// Patrolling
#define BOT_PATROL 4
/// Summoned to a location
#define BOT_SUMMON 5
/// Currently moving
#define BOT_MOVING 6
/// Secbot - At target, preparing to arrest
#define BOT_PREP_ARREST 7
/// Secbot - Arresting target
#define BOT_ARREST 8
/// Cleanbot - Cleaning
#define BOT_CLEANING 9
/// Hygienebot - Cleaning unhygienic humans
#define BOT_SHOWERSTANCE 10
/// Floorbots - Repairing hull breaches
#define BOT_REPAIRING 11
/// Medibots - Healing people
#define BOT_HEALING 12
/// Responding to a call from the AI
#define BOT_RESPONDING 13
/// MULEbot - Moving to deliver
#define BOT_DELIVER 14
/// MULEbot - Returning to home
#define BOT_GO_HOME 15
/// MULEbot - Blocked
#define BOT_BLOCKED 16
/// MULEbot - Computing navigation
#define BOT_NAV 17
/// MULEbot - Waiting for nav computation
#define BOT_WAIT_FOR_NAV 18
/// MULEbot - No destination beacon found (or no route)
#define BOT_NO_ROUTE 19

//SecBOT defines on arresting
///Whether arrests should be broadcasted over the Security radio
#define SECBOT_DECLARE_ARRESTS (1<<0)
///Will arrest people who lack an ID card
#define SECBOT_CHECK_IDS (1<<1)
///Will check for weapons, taking Weapons access into account
#define SECBOT_CHECK_WEAPONS (1<<2)
///Will check Security record on whether to arrest
#define SECBOT_CHECK_RECORDS (1<<3)
///Whether we will stun & cuff or endlessly stun
#define SECBOT_HANDCUFF_TARGET (1<<4)

/** Misc Robot defines */

//Assembly defines
#define ASSEMBLY_FIRST_STEP 0
#define ASSEMBLY_SECOND_STEP 1
#define ASSEMBLY_THIRD_STEP 2
#define ASSEMBLY_FOURTH_STEP 3
#define ASSEMBLY_FIFTH_STEP 4
