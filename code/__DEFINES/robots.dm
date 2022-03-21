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

//transfer_ai() defines. Main proc in ai_core.dm
///Downloading AI to InteliCard
#define AI_TRANS_TO_CARD 1
///Uploading AI from InteliCard
#define AI_TRANS_FROM_CARD 2
///Malfunctioning AI hijacking mecha
#define AI_MECH_HACK 3

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

//Assembly defines
#define ASSEMBLY_FIRST_STEP 1
#define ASSEMBLY_SECOND_STEP 2
#define ASSEMBLY_THIRD_STEP 3
#define ASSEMBLY_FOURTH_STEP 4
#define ASSEMBLY_FIFTH_STEP 5
#define ASSEMBLY_SIXTH_STEP 6
#define ASSEMBLY_SEVENTH_STEP 7
#define ASSEMBLY_EIGHTH_STEP 8
#define ASSEMBLY_NINTH_STEP 9

//Bot defines, placed here so they can be read by other things!
/// Delay between movemements
#define BOT_STEP_DELAY 4
/// Maximum times a bot will retry to step from its position
#define BOT_STEP_MAX_RETRIES 5
/// Default view range for finding targets.
#define DEFAULT_SCAN_RANGE 7
//Amount of time that must pass after a Commissioned bot gets saluted to get another.
#define BOT_COMMISSIONED_SALUTE_DELAY (60 SECONDS)

//Bot mode defines displaying how Bots act
///The Bot is currently active, and will do whatever it is programmed to do.
#define BOT_MODE_ON (1<<0)
///The Bot is currently set to automatically patrol the station.
#define BOT_MODE_AUTOPATROL (1<<1)
///The Bot is currently allowed to be remote controlled by Silicon.
#define BOT_MODE_REMOTE_ENABLED (1<<2)
///The Bot is allowed to have a pAI placed in control of it.
#define BOT_MODE_PAI_CONTROLLABLE (1<<3)

//Bot cover defines indicating the Bot's status
///The Bot's cover is open and can be modified/emagged by anyone.
#define BOT_COVER_OPEN (1<<0)
///The Bot's cover is locked, and cannot be opened without unlocking it.
#define BOT_COVER_LOCKED (1<<1)
///The Bot is emagged.
#define BOT_COVER_EMAGGED (1<<2)
///The Bot has been hacked by a Silicon, emagging them, but revertable.
#define BOT_COVER_HACKED (1<<3)

//Bot types
/// Secutritrons (Beepsky)
#define SEC_BOT "Securitron"
/// ED-209s
#define ADVANCED_SEC_BOT "ED-209"
/// MULEbots
#define MULE_BOT "MULEbot"
/// Floorbots
#define FLOOR_BOT "Floorbot"
/// Cleanbots
#define CLEAN_BOT "Cleanbot"
/// Medibots
#define MED_BOT "Medibot"
/// Honkbots & ED-Honks
#define HONK_BOT "Honkbot"
/// Firebots
#define FIRE_BOT "Firebot"
/// Hygienebots
#define HYGIENE_BOT "Hygienebot"
/// Vibe bots
#define VIBE_BOT "Vibebot"

//Mode defines. If you add a new one make sure you update mode_name in /mob/living/simple_animal/bot

// General Bot modes //
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

// Unique modes //
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

//MedBOT defines
///Whether to declare if someone (we are healing) is in critical condition
#define MEDBOT_DECLARE_CRIT (1<<0)
///If the bot will stand still, only healing those next to it.
#define MEDBOT_STATIONARY_MODE (1<<1)
///Whether the bot will randomly speak from time to time. This will not actually prevent all speech.
#define MEDBOT_SPEAK_MODE (1<<2)
