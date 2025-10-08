
// Legacy preference toggles.
// !!! DO NOT ADD ANY NEW ONES HERE !!!
// Use `/datum/preference/toggle` instead.
#define SOUND_ADMINHELP (1<<0)
#define MEMBER_PUBLIC (1<<4)
#define SOUND_PRAYERS (1<<9)
#define ANNOUNCE_LOGIN (1<<10)
#define DISABLE_DEATHRATTLE (1<<12)
#define DISABLE_ARRIVALRATTLE (1<<13)
#define COMBOHUD_LIGHTING (1<<14)
#define DEADMIN_ALWAYS (1<<15)
#define DEADMIN_ANTAGONIST (1<<16)
#define DEADMIN_POSITION_HEAD (1<<17)
#define DEADMIN_POSITION_SECURITY (1<<18)
#define DEADMIN_POSITION_SILICON (1<<19)
#define ADMIN_IGNORE_CULT_GHOST (1<<21)
#define SPLIT_ADMIN_TABS (1<<23)

#define TOGGLES_DEADMIN_DEFAULT (DEADMIN_ANTAGONIST|DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY|DEADMIN_POSITION_SILICON)
#define TOGGLES_DEFAULT (SOUND_ADMINHELP|MEMBER_PUBLIC|SOUND_PRAYERS|TOGGLES_DEADMIN_DEFAULT)

// Legacy chat toggles.
// !!! DO NOT ADD ANY NEW ONES HERE !!!
// Use `/datum/preference/toggle` instead.
#define CHAT_OOC (1<<0)
#define CHAT_DEAD (1<<1)
#define CHAT_GHOSTEARS (1<<2)
#define CHAT_GHOSTSIGHT (1<<3)
#define CHAT_PRAYER (1<<4)
#define CHAT_PULLR (1<<6)
#define CHAT_GHOSTWHISPER (1<<7)
#define CHAT_GHOSTPDA (1<<8)
#define CHAT_GHOSTRADIO (1<<9)
#define CHAT_BANKCARD (1<<10)
#define CHAT_GHOSTLAWS (1<<11)
#define CHAT_LOGIN_LOGOUT (1<<12)

#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_PRAYER|CHAT_PULLR|CHAT_GHOSTPDA|CHAT_GHOSTRADIO|CHAT_BANKCARD|CHAT_GHOSTLAWS|CHAT_LOGIN_LOGOUT)

/// File path to where we save backups of preference savefiles when updating them.
#define PREFS_BACKUP_PATH(base_path) "[base_path].updatebac"
/// File path to the dev preference json file, which is loaded by guests while localhosting.
#define DEV_PREFS_PATH "config/dev_preferences.json"

#define PARALLAX_INSANE "Insane"
#define PARALLAX_HIGH "High"
#define PARALLAX_MED "Medium"
#define PARALLAX_LOW "Low"
#define PARALLAX_DISABLE "Disabled"

#define SCALING_METHOD_NORMAL "normal"
#define SCALING_METHOD_DISTORT "distort"
#define SCALING_METHOD_BLUR "blur"

#define PARALLAX_DELAY_DEFAULT world.tick_lag
#define PARALLAX_DELAY_MED 1
#define PARALLAX_DELAY_LOW 2

#define SEC_DEPT_NONE "None"
#define SEC_DEPT_ENGINEERING "Engineering"
#define SEC_DEPT_MEDICAL "Medical"
#define SEC_DEPT_SCIENCE "Science"
#define SEC_DEPT_SUPPLY "Supply"

// Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING "Living"
#define EXP_TYPE_CREW "Crew"
#define EXP_TYPE_COMMAND "Command"
#define EXP_TYPE_ENGINEERING "Engineering"
#define EXP_TYPE_MEDICAL "Medical"
#define EXP_TYPE_SCIENCE "Science"
#define EXP_TYPE_SUPPLY "Supply"
#define EXP_TYPE_SECURITY "Security"
#define EXP_TYPE_SILICON "Silicon"
#define EXP_TYPE_SERVICE "Service"
#define EXP_TYPE_ANTAG "Antag"
#define EXP_TYPE_SPECIAL "Special"
#define EXP_TYPE_GHOST "Ghost"
#define EXP_TYPE_ADMIN "Admin"

//Flags in the players table in the db
#define DB_FLAG_EXEMPT (1<<0)

#define DEFAULT_CYBORG_NAME "Default Cyborg Name"

// Choose grid or list TGUI layouts for UI's, when possible.
/// Force grid layout, even if default is a list.
#define TGUI_LAYOUT_GRID "grid"
/// Force list layout, even if default is a grid.
#define TGUI_LAYOUT_LIST "list"

//Job preferences levels
#define JP_ANY 0
#define JP_LOW 1
#define JP_MEDIUM 2
#define JP_HIGH 3

//randomised elements
#define RANDOM_ANTAG_ONLY 1
#define RANDOM_DISABLED 2
#define RANDOM_ENABLED 3

//recommened client FPS
#define RECOMMENDED_FPS 100

// randomise_appearance_prefs() and randomize_human_appearance() proc flags
#define RANDOMIZE_SPECIES (1<<0)
#define RANDOMIZE_NAME (1<<1)

// Values for /datum/preference/savefile_identifier
/// This preference is character specific.
#define PREFERENCE_CHARACTER "character"
/// This preference is account specific.
#define PREFERENCE_PLAYER "player"

// Values for /datum/preferences/current_tab
/// Open the character preference window
#define PREFERENCE_TAB_CHARACTER_PREFERENCES 0

/// Open the game preferences window
#define PREFERENCE_TAB_GAME_PREFERENCES 1

/// Open the keybindings window
#define PREFERENCE_TAB_KEYBINDINGS 2

/// These will be shown in the character sidebar, but at the bottom.
#define PREFERENCE_CATEGORY_FEATURES "features"

/// Any preferences that will show to the sides of the character in the setup menu.
#define PREFERENCE_CATEGORY_CLOTHING "clothing"

/// Preferences that will be put into the 3rd list, and are not contextual.
#define PREFERENCE_CATEGORY_NON_CONTEXTUAL "non_contextual"

/// Will be put under the game preferences window.
#define PREFERENCE_CATEGORY_GAME_PREFERENCES "game_preferences"

/// These will show in the list to the right of the character preview.
#define PREFERENCE_CATEGORY_SECONDARY_FEATURES "secondary_features"

/// These are preferences that are supplementary for main features,
/// such as hair color being affixed to hair.
#define PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES "supplemental_features"

/// These preferences will not be rendered on the preferences page, and are practically invisible unless specifically rendered. Used for quirks, currently.
#define PREFERENCE_CATEGORY_MANUALLY_RENDERED "manually_rendered_features"

// Playtime is tracked in minutes
/// The time needed to unlock hardcore random mode in preferences
#define PLAYTIME_HARDCORE_RANDOM 120 // 2 hours
/// The time needed to unlock the gamer cloak in preferences
#define PLAYTIME_VETERAN 300000 // 5,000 hours

/// The key used for sprite accessories that should never actually be applied to the player.
#define SPRITE_ACCESSORY_NONE "None"

// Loadout
/// Used to make something not recolorable even if it's capable
#define DONT_GREYSCALE -1
// Loadout item info keys
// Changing these will break existing loadouts
/// Tracks GAGS color information
#define INFO_GREYSCALE "greyscale"
/// Used to set custom names
#define INFO_NAMED "name"
/// Used for specific alt-reskins, like the pride pin
#define INFO_RESKIN "reskin"
/// Handles which layer the item will be on, for accessories
#define INFO_LAYER "layer"

// Lipstick styles
#define UPPER_LIP "Upper"
#define MIDDLE_LIP "Middle"
#define LOWER_LIP "Lower"
