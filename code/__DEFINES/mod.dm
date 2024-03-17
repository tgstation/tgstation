/// Default value for the max_complexity var on MODsuits
#define DEFAULT_MAX_COMPLEXITY 15

/// Default cell drain per process on MODsuits
#define DEFAULT_CHARGE_DRAIN 5

/// Default time for a part to seal
#define MOD_ACTIVATION_STEP_TIME (2 SECONDS)

/// Passive module, just acts when put in naturally.
#define MODULE_PASSIVE 0
/// Usable module, does something when you press a button.
#define MODULE_USABLE 1
/// Toggle module, you turn it on/off and it does stuff.
#define MODULE_TOGGLE 2
/// Actively usable module, you may only have one selected at a time.
#define MODULE_ACTIVE 3

/// This module can be used during phaseout
#define MODULE_ALLOW_PHASEOUT (1<<0)
/// This module can be used while incapacitated
#define MODULE_ALLOW_INCAPACITATED (1<<1)
/// This module can be used while the suit is off
#define MODULE_ALLOW_INACTIVE (1<<2)

//Defines used by the theme for clothing flags and similar
#define CONTROL_LAYER "control_layer"
#define HELMET_FLAGS "helmet_flags"
#define CHESTPLATE_FLAGS "chestplate_flags"
#define GAUNTLETS_FLAGS "gauntlets_flags"
#define BOOTS_FLAGS "boots_flags"

#define UNSEALED_LAYER "unsealed_layer"
#define UNSEALED_CLOTHING "unsealed_clothing"
#define SEALED_CLOTHING "sealed_clothing"
#define UNSEALED_INVISIBILITY "unsealed_invisibility"
#define SEALED_INVISIBILITY "sealed_invisibility"
#define UNSEALED_COVER "unsealed_cover"
#define SEALED_COVER "sealed_cover"
#define CAN_OVERSLOT "can_overslot"

//Defines used to override MOD clothing's icon and worn icon files in the skin.
#define MOD_ICON_OVERRIDE "mod_icon_override"
#define MOD_WORN_ICON_OVERRIDE "mod_worn_icon_override"

//Defines for MODlink frequencies
#define MODLINK_FREQ_NANOTRASEN "NT"
#define MODLINK_FREQ_SYNDICATE "SYND"
#define MODLINK_FREQ_CHARLIE "CHRL"
#define MODLINK_FREQ_CENTCOM "CC"

/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
/// Global list of all ids associated to a /datum/mod_link instance
GLOBAL_LIST_EMPTY(mod_link_ids)
