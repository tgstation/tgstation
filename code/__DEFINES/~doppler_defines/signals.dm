///Fired in combat_indicator.dm, used for syncing CI between mech and pilot
#define COMSIG_MOB_CI_TOGGLED "mob_ci_toggled"

// Power signals
/// Sent when an obj/item calls item_use_power: (use_amount, user, check_only)
#define COMSIG_ITEM_POWER_USE "item_use_power"
	#define NO_COMPONENT NONE
	#define COMPONENT_POWER_SUCCESS (1<<0)
	#define COMPONENT_NO_CELL  (1<<1)
	#define COMPONENT_NO_CHARGE (1<<2)
