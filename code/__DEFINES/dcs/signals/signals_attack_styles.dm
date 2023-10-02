/// Sent from /datum/attack_style/proc/process_attack, to the attacking mob, before finalizing the process.
/// (mob/living/attacker, datum/attack_style/source, obj/item/weapon_used, list/affected_turfs)
#define COMSIG_LIVING_ATTACK_STYLE_PREPROCESS "living_attack_style_preprocess"
/// Return this to cancel the attack before executing it
	#define CANCEL_ATTACK_PREPROCESS (1 << 0)
/// Sent from /datum/attack_style/proc/process_attack, to the attacking mob, after finalizing the process.
/// (mob/living/source, obj/item/weapon_used, attack_result)
#define COMSIG_LIVING_ATTACK_STYLE_PROCESSED "living_attack_style_executed"
#define COMSIG_ITEM_ATTACK_STYLE_PROCESESD "item_attack_style_executed"

#define COMSIG_ITEM_ATTACK_STYLE_CHECK "item_attack_style_check"

/// Sent to an item when it is swinging and enters a new turf
#define COMSIG_ITEM_SWING_ENTERS_TURF "item_attack_style_enters_turf"
