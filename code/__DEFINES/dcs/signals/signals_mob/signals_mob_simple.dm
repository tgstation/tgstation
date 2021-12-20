// simple_animal signals
/// called when a simplemob is given sentience from a potion (target = person who sentienced)
#define COMSIG_SIMPLEMOB_SENTIENCEPOTION "simplemob_sentiencepotion"

// /mob/living/simple_animal/hostile signals
///before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK (1<<0) //cancel the attack, only works before attack happens
///after attackingtarget has happened, source is the attacker and target is the attacked, extra argument for if the attackingtarget was successful
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"
///from base of mob/living/simple_animal/hostile/regalrat: (mob/living/simple_animal/hostile/regalrat/king)
#define COMSIG_RAT_INTERACT "rat_interaction"
///FROM mob/living/simple_animal/hostile/ooze/eat_atom(): (atom/target, edible_flags)
#define COMSIG_OOZE_EAT_ATOM "ooze_eat_atom"
	#define COMPONENT_ATOM_EATEN  (1<<0)

//Mob ability signals /datum/action/cooldown/mob_cooldown
/// Called when a mob attempts to blood warp
#define COMSIG_BLOOD_WARP "mob_ability_blood_warp"
/// Called when a mob attempts to start a charge
#define COMSIG_STARTED_CHARGE "mob_ability_charge_started"
/// Called when a mob bumps into something while charging, send override to cancel damage / effects
#define COMSIG_BUMPED_CHARGE "mob_ability_charge_bumped"
	#define COMPONENT_OVERRIDE_CHARGE_BUMP (1<<0)
/// Called when a mobs charge has ended
#define COMSIG_FINISHED_CHARGE "mob_ability_charge_finished"
/// Called when a projectile sequence has started in a mob ability
#define COMSIG_PROJECTILE_FIRING_STARTED "mob_ability_started_projectile"
/// Called when a projectile sequence has ended
#define COMSIG_PROJECTILE_FIRING_FINISHED "mob_ability_fired_projectile"
/// Called when a projectile spiral attack has started
#define COMSIG_SPIRAL_ATTACK_START "mob_spiral_attack_start"
/// Called when a projectile spiral attack has ended
#define COMSIG_SPIRAL_ATTACK_FINISHED "mob_spiral_attack_finished"
/// Called when a mob activates the swooping ability
#define COMSIG_SWOOP_ATTACK_STARTED "mob_swoop_attack_started"
/// Called when a mob is actually in the air while swooping and is invulnerable to damage
#define COMSIG_SWOOP_INVULNERABILITY_STARTED "mob_swoop_invulnerability_started"
/// Called when a mob has landed and invulnerability has ended from swooping
#define COMSIG_SWOOP_ATTACK_FINISHED "mob_swoop_attack_finished"
/// Called when a mob attempted to use the lava arena ability but had no valid targets or all targets have died before the ability should end
#define COMSIG_LAVA_ARENA_FAILED "mob_lava_arena_failed"
