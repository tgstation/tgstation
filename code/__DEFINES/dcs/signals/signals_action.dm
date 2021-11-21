// /datum/action signals

///from base of datum/action/proc/Trigger(): (datum/action)
#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER (1<<0)
// /datum/component/container_item
/// (atom/container, mob/user) - returns bool
#define COMSIG_CONTAINER_TRY_ATTACH "container_try_attach"
