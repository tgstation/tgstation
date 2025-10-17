/// Heretic signals

/// From /datum/action/cooldown/spell/touch/mansus_grasp/cast_on_hand_hit : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK "mansus_grasp_attack"
	/// Default behavior is to use the hand, so return this to blocks the mansus fist from being consumed after use.
	#define COMPONENT_BLOCK_HAND_USE (1<<0)
/// From /datum/action/cooldown/spell/touch/mansus_grasp/cast_on_secondary_hand_hit : (mob/living/source, atom/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY "mansus_grasp_attack_secondary"
	/// Default behavior is to continue attack chain and do nothing else, so return this to use up the hand after use.
	#define COMPONENT_USE_HAND (1<<0)

/// From /obj/item/melee/sickly_blade/afterattack : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_BLADE_ATTACK "blade_attack"
/// From /obj/item/melee/sickly_blade/ranged_interact_with_atom (without proximity) : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_RANGED_BLADE_ATTACK "ranged_blade_attack"

/// For [/datum/status_effect/protective_blades] to signal when it is triggered
#define COMSIG_BLADE_BARRIER_TRIGGERED "blade_barrier_triggered"

/// at the end of determine_drafted_knowledge
#define COMSIG_HERETIC_SHOP_SETUP "heretic_shop_finished"

/// called on the antagonist datum, upgrades the passive to level 2
#define COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST "heretic_passive_upgrade_first"
/// called on the antagonist datum, upgrades the passive to level 3
#define COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL "heretic_passive_upgrade_final"
