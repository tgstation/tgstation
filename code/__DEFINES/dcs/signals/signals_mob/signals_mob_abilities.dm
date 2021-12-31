// Mob ability signals

/// from base of /datum/action/cooldown/proc/PreActivate(): (datum/action/cooldown/activated)
#define COMSIG_ABILITY_STARTED "mob_ability_base_started"
	#define COMPONENT_BLOCK_ABILITY_START (1<<0)
/// from base of /datum/action/cooldown/proc/PreActivate(): (datum/action/cooldown/finished)
#define COMSIG_ABILITY_FINISHED "mob_ability_base_finished"

/// from base of /datum/action/cooldown/mob_cooldown/blood_warp/proc/blood_warp(): ()
#define COMSIG_BLOOD_WARP "mob_ability_blood_warp"
/// from base of /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_STARTED_CHARGE "mob_ability_charge_started"
/// from base of /datum/action/cooldown/mob_cooldown/charge/proc/on_bump(): (atom/target)
#define COMSIG_BUMPED_CHARGE "mob_ability_charge_bumped"
	#define COMPONENT_OVERRIDE_CHARGE_BUMP (1<<0)
/// from base of /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define COMSIG_FINISHED_CHARGE "mob_ability_charge_finished"
/// from base of /datum/action/cooldown/mob_cooldown/lava_swoop/proc/swoop_attack(): ()
#define COMSIG_SWOOP_INVULNERABILITY_STARTED "mob_swoop_invulnerability_started"
/// from base of /datum/action/cooldown/mob_cooldown/lava_swoop/proc/swoop_attack(): ()
#define COMSIG_LAVA_ARENA_FAILED "mob_lava_arena_failed"
