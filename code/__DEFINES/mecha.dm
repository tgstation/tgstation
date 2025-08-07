#define MECHA_INT_FIRE (1<<0)
#define MECHA_INT_TEMP_CONTROL (1<<1)
#define MECHA_INT_SHORT_CIRCUIT (1<<2)
#define MECHA_CABIN_AIR_BREACH (1<<3)
#define MECHA_INT_CONTROL_LOST (1<<4)

#define PANEL_OPEN (1<<0)
#define ID_LOCK_ON (1<<1)
#define CAN_STRAFE (1<<2)
#define LIGHTS_ON (1<<3)
#define SILICON_PILOT (1<<4)
#define IS_ENCLOSED (1<<5)
#define HAS_LIGHTS (1<<6)
#define QUIET_STEPS (1<<7)
#define QUIET_TURNS (1<<8)
///blocks using equipment and melee attacking.
#define CANNOT_INTERACT (1<<9)
/// posibrains can drive this mecha
#define MMI_COMPATIBLE (1<<10)
/// AI's can be placed inside this mech. This only prevents direct uploads. It does not prevent mech domination on the mech.
#define AI_COMPATIBLE (1<<11)
/// Can click from any direction and perform stuff
#define OMNIDIRECTIONAL_ATTACKS (1<<12)
/// Prevents overpenetrating through the mecha and into the cockpit using an armour penetrating weapon
#define CANNOT_OVERPENETRATE (1<<13)
/// Can have a tracking beacon placed into the mech
#define BEACON_TRACKABLE (1<<14)
/// Can have an AI control beacon placed into the mech
#define BEACON_CONTROLLABLE (1<<15)

#define MECHA_MELEE (1 << 0)
#define MECHA_RANGED (1 << 1)

#define MECHA_FRONT_ARMOUR "mechafront"
#define MECHA_SIDE_ARMOUR "mechaside"
#define MECHA_BACK_ARMOUR "mechaback"

#define MECHA_WEAPON "mecha_weapon" //l and r arm weapon type
#define MECHA_L_ARM "mecha_l_arm"
#define MECHA_R_ARM "mecha_r_arm"
#define MECHA_UTILITY "mecha_utility"
#define MECHA_POWER "mecha_power"
#define MECHA_ARMOR "mecha_armor"

// Some mechs must (at least for now) use snowflake handling of their UI elements, these defines are for that
// when changing MUST update the same-named tsx file constants
#define MECHA_SNOWFLAKE_ID_SLEEPER "sleeper_snowflake"
#define MECHA_SNOWFLAKE_ID_SYRINGE "syringe_snowflake"
#define MECHA_SNOWFLAKE_ID_MODE "mode_snowflake"
#define MECHA_SNOWFLAKE_ID_EXTINGUISHER "extinguisher_snowflake"
#define MECHA_SNOWFLAKE_ID_EJECTOR "ejector_snowflake"
#define MECHA_SNOWFLAKE_ID_OREBOX_MANAGER "orebox_manager_snowflake"
#define MECHA_SNOWFLAKE_ID_RADIO "radio_snowflake"
#define MECHA_SNOWFLAKE_ID_AIR_TANK "air_tank_snowflake"
#define MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC "ballistic_weapon_snowflake"
#define MECHA_SNOWFLAKE_ID_GENERATOR "generator_snowflake"
#define MECHA_SNOWFLAKE_ID_ORE_SCANNER "orescanner_snowflake"
#define MECHA_SNOWFLAKE_ID_CLAW "lawclaw_snowflake"
#define MECHA_SNOWFLAKE_ID_RCD "rcd_snowflake"

#define MECHA_AMMO_INCENDIARY "Incendiary bullet"
#define MECHA_AMMO_BUCKSHOT "Buckshot shell"
#define MECHA_AMMO_LMG "LMG bullet"
#define MECHA_AMMO_MISSILE_SRM "SRM missile"
#define MECHA_AMMO_MISSILE_PEP "PEP missile"
#define MECHA_AMMO_FLASHBANG "Flashbang"
#define MECHA_AMMO_CLUSTERBANG "Clusterbang"
#define MECHA_AMMO_PUNCHING_GLOVE "Punching glove"
#define MECHA_AMMO_BANANA_PEEL "Banana peel"
#define MECHA_AMMO_MOUSETRAP "Mousetrap"

/// Values to determine the effects on a mech should it suffer an EMP
#define MECH_EMP_DAMAGE_LOWER 100
#define MECH_EMP_DAMAGE_UPPER 180

#define MECH_EMP_BEACON_DESTRUCTION_PROB 40

/// bitflags for do_after checks on mechs
#define MECH_DO_AFTER_DIR_CHANGE_FLAG (1 << 0)
#define MECH_DO_AFTER_ADJACENCY_FLAG (1 << 1)

/// Defines for Justice mech
#define JUSTICE_IDLE "idle"
#define JUSTICE_CHARGE "charge"
#define JUSTICE_INVISIBILITY "invisibility"
#define JUSTICE_INVISIBILITY_ATTACK "invisibility attack"
#define JUSTICE_FATALITY "fatality"

#define JUSTICE_ENGINE_ACTIVE "active"
#define JUSTICE_ENGINE_ACTIVATING "activating"
#define JUSTICE_ENGINE_ONCOOLDOWN "oncooldown"
#define JUSTICE_ENGINE_DEACTIVATING "deactivating"
#define JUSTICE_ENGINE_DEACTIVE "deactive"

#define COMSIG_JUSTICE_ATTACK_AOE "justice_attack_aoe"
#define COMSIG_JUSTICE_CHARGE_BUTTON_DOWN "justice_charge_button_down"

#define COMSIG_JUSTICE_INVISIBILITY_ACTIVATE "justice_invisibility_activate"
	#define COMPONENT_CANCEL_JUSTICE_INVISIBILITY_ACTIVATE (1<<0)
#define COMSIG_JUSTICE_INVISIBILITY_DEACTIVATE "justice_invisibility_deactivate"
	#define COMPONENT_CANCEL_JUSTICE_INVISIBILITY_DEACTIVATE (1<<0)

