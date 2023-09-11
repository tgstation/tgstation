/// Sent from /datum/attack_style/proc/process_attack, to the attacking mob, after finalizing the process.
/// (mob/living/source, obj/item/weapon_used, attack_result)
#define COMSIG_LIVING_ATTACK_STYLE_PROCESSED "living_attack_style_executed"
#define COMSIG_ITEM_ATTACK_STYLE_PROCESESD "item_attack_style_executed"

#define COMSIG_ITEM_ATTACK_STYLE_CHECK "item_attack_style_check"

/// Sent to an item when it is swinging and enters a new turf
#define COMSIG_ITEM_SWING_ENTERS_TURF "item_attack_style_enters_turf"
