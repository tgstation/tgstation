/// Heretic signals

/// From /obj/item/clothing/mask/madness_mask/process : (amount)
#define COMSIG_HERETIC_MASK_ACT "void_mask_act"

/// From /obj/item/melee/touch_attack/mansus_fist/on_mob_hit : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK "mansus_grasp_attack"
  /// Blocks the mansus fist from being consumed after use.
  #define COMPONENT_BLOCK_CHARGE_USE (1<<0)
/// From /obj/item/melee/touch_attack/mansus_fist/afterattack_secondary : (mob/living/source, atom/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY "mansus_grasp_attack_secondary"

/// From /obj/item/melee/sickly_blade/afterattack (with proximity) : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_BLADE_ATTACK "blade_attack"
/// From /obj/item/melee/sickly_blade/afterattack (without proximity) : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_RANGED_BLADE_ATTACK "ranged_blade_attack"
