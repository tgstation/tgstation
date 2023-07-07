// Action signals

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	// Return to block the trigger from occuring
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
/// From /datum/action/Grant(): (mob/grant_to)
#define COMSIG_ACTION_GRANTED "action_grant"
/// From /datum/action/Grant(): (datum/action)
#define COMSIG_MOB_GRANTED_ACTION "mob_action_grant"
/// From /datum/action/Remove(): (mob/removed_from)
#define COMSIG_ACTION_REMOVED "action_removed"
/// From /datum/action/Remove(): (datum/action)
#define COMSIG_MOB_REMOVED_ACTION "mob_action_removed"
/// From /datum/action/apply_button_overlay()
#define COMSIG_ACTION_OVERLAY_APPLY "action_overlay_applied"

// Cooldown action signals

/// From base of /datum/action/cooldown/proc/PreActivate(), sent to the action owner: (datum/action/cooldown/activated)
#define COMSIG_MOB_ABILITY_STARTED "mob_ability_base_started"
	/// Return to block the ability from starting / activating
	#define COMPONENT_BLOCK_ABILITY_START (1<<0)
/// From base of /datum/action/cooldown/proc/PreActivate(), sent to the action owner: (datum/action/cooldown/finished)
#define COMSIG_MOB_ABILITY_FINISHED "mob_ability_base_finished"

/// From base of /datum/action/cooldown/proc/set_statpanel_format(): (list/stat_panel_data)
#define COMSIG_ACTION_SET_STATPANEL "ability_set_statpanel"

// Specific cooldown action signals

/// From base of /datum/action/cooldown/mob_cooldown/blood_warp/proc/blood_warp(): ()
#define COMSIG_BLOOD_WARP "mob_ability_blood_warp"
/// From base of /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_STARTED_CHARGE "mob_ability_charge_started"
/// From base of /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_FINISHED_CHARGE "mob_ability_charge_finished"
/// From base of /datum/action/cooldown/mob_cooldown/lava_swoop/proc/swoop_attack(): ()
#define COMSIG_SWOOP_INVULNERABILITY_STARTED "mob_swoop_invulnerability_started"
/// From base of /datum/action/cooldown/mob_cooldown/lava_swoop/proc/swoop_attack(): ()
#define COMSIG_LAVA_ARENA_FAILED "mob_lava_arena_failed"

///From /datum/action/vehicle/sealed/mecha/mech_toggle_safeties/proc/update_action_icon(): ()
#define COMSIG_MECH_SAFETIES_TOGGLE "mech_safeties_toggle"
