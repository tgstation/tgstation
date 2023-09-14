//Crusher applicant defines - decides which signal should [/datum/element/crusher_damage_applicant] hook into
//for applying [/datum/status_effect/crusher_damage] to a target mob

/// This applicant is used to attack in melee and should listen for `COMSIG_ITEM_PRE_ATTACK`
#define APPLY_WITH_MELEE 0
/// This applicant is a projectile used to attack from range and should listen to `COMSIG_PROJECTILE_SELF_ON_HIT`
#define APPLY_WITH_PROJECTILE 1
/// This applicant is a snowflake spell/effect/other jackshit and should listen to `COMSIG_CRUSHER_SPELL_HIT`
#define APPLY_WITH_SPELL 2
/// This applicant is a crusher trophy-spawned mob and should listen to `COMSIG_HOSTILE_PRE_ATTACKINGTARGET`
#define APPLY_WITH_MOB_ATTACK 3
