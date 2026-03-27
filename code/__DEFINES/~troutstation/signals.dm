/// Called by mob/living/basic/flock/agent when it finishes eating an item: (mob/living/basic/flock/agent/agent, obj/item/consumed, new_resource_total)
#define COMSIG_FLOCK_ITEM_CONSUMED "flock_item_consumed"
/// Called by mob/living/basic/flock/agent when its resources change for any reason: (mob/living/basic/flock/agent/agent, new_resource_total, resources_added)
#define COMSIG_FLOCK_RESOURCES_CHANGED "flock_resources_changed"
