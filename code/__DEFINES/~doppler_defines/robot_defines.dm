/// Resting for borgs, especially if we ever get more than one type
#define ROBOT_REST_NORMAL 1

/// Features that a specific borg skin has
#define SKIN_FEATURES "skin_features"

// Icon file locations for modular borg icons
/// Medical
#define CYBORG_ICON_MED_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_med.dmi'
/// Engineer
#define CYBORG_ICON_ENG_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_eng.dmi'
/// Peacekeeper
#define CYBORG_ICON_PEACEKEEPER_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_pk.dmi'
/// Service
#define CYBORG_ICON_SERVICE_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_serv.dmi'
/// Service
#define CYBORG_ICON_MINING_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_mine.dmi'
/// Janitor
#define CYBORG_ICON_JANI_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_jani.dmi'
/// Evil
#define CYBORG_ICON_SYNDIE_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_syndi.dmi'
/// Ninja (Evil)
#define CYBORG_ICON_NINJA_TALL 'modular_doppler/big_borg_lmao/icons/tallrobot_ninja.dmi'

//Defines for model features, set in the model_features list of a robot model datum. Are they a dogborg? Is the model small? etc.
/// Cyborgs with unique sprites for when they get totally broken down.
#define TRAIT_R_UNIQUEWRECK "unique_wreck"
/// Or when tipped over.
#define TRAIT_R_UNIQUETIP "unique_tip"
/// 32x64 skins
#define TRAIT_R_TALL "tall_borg"
/// Any model small enough to reject the shrinker upgrade.
#define TRAIT_R_SMALL "small_chassis"
/// Any model that has a custom front panel
#define TRAIT_R_UNIQUEPANEL "unique_openpanel"
