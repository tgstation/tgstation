///Fired in combat_indicator.dm, used for syncing CI between mech and pilot
#define COMSIG_MOB_CI_TOGGLED "mob_ci_toggled"

// Power signals
/// Sent when an obj/item calls item_use_power: (use_amount, user, check_only)
#define COMSIG_ITEM_POWER_USE "item_use_power"
	#define NO_COMPONENT NONE
	#define COMPONENT_POWER_SUCCESS (1<<0)
	#define COMPONENT_NO_CELL  (1<<1)
	#define COMPONENT_NO_CHARGE (1<<2)

/// For when a Hemophage's pulsating tumor gets added to their body.
#define COMSIG_PULSATING_TUMOR_ADDED "pulsating_tumor_added"
/// For when a Hemophage's pulsating tumor gets removed from their body.
#define COMSIG_PULSATING_TUMOR_REMOVED "pulsating_tumor_removed"
/// From /obj/item/organ/stomach/after_eat(atom/edible)
#define COMSIG_STOMACH_AFTER_EAT "stomach_after_eat"
/// Whenever a baton successfully executes its nonlethal attack. WARNING wonderful FUCKING CODE by niko THIS IS peak AAAAAAAAAAAAH
#define COMSIG_PRE_BATON_FINALIZE_ATTACK "pre_baton_finalize_attack"
// For after a user has sent a say message
#define COMSIG_MOB_POST_SAY "mob_post_say"
/// Whenever we need to check if a mob is currently inside of soulcatcher.
#define COMSIG_SOULCATCHER_CHECK_SOUL "soulcatcher_check_soul"
/// Whenever we need to get the soul of the mob inside of the soulcatcher.
#define COMSIG_SOULCATCHER_SCAN_BODY "soulcatcher_scan_body"
/// For modifying a mob holder based on what it's holding
#define COMSIG_ADDING_MOB_HOLDER_SPECIALS "adding_mob_holder_specials"
