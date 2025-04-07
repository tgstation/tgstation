/// Will be shared across all obj/item/storage as its only a one time use during Initialize()
GLOBAL_VAR_INIT(initial_storage_config, new /datum/storage_config)

/**
 * Computes atom_storage values based on the initital contents of the storage.
 * Use this only when the initial contents are extremly varied such that accurate values
 * cannot be computed before hand e.g. if the items are randomly generated or you have huge list of stacks & stuff
 * whose weights cannot be calculated correctly so setting the max_total_storage is not feasible and so on
 *
 * Don't use this if you can manually compute the items weights/counts & set max_total_storage or other values
 * correctly yourself as it can lead to balance implications in game e.g. if your storage initially carries
 * a large item and you want to set max_specific_storage to that item weight then it will
 * allow all others items less than or equal to that item weight which may not be ideal.
 *
 * In conclusion use this when the initial contents are too complex for mortal comprehension so you make
 * computing the storage values automatic
 */
/datum/storage_config
	///Computes the total weight of the storage's initial contents & sets max_total_storage to that value
	var/compute_max_total_weight = FALSE
	///Computes the item that has the highest weight in the storage's initial contents & sets max_specific_storage to that value
	var/compute_max_item_weight = FALSE
	///Computes number of items in the storage's initial contents & sets max_slots to that value
	var/compute_max_item_count = FALSE
	///Sets exception_hold to the storage's initial contents meaning they can be carried without max_specific_storage restrictions
	var/contents_are_exceptions = FALSE
	///Sets the storage's initial contents as the only items(i.e. sets can_hold) that can be carried by the storage
	var/whitelist_content_types = FALSE

///Resets all values to their defaults
/datum/storage_config/proc/reset()
	compute_max_total_weight = FALSE
	compute_max_item_weight = FALSE
	compute_max_item_count = FALSE
	contents_are_exceptions = FALSE
	whitelist_content_types = FALSE

///Compute max total weight, max item weight & item count
/datum/storage_config/proc/compute_max_values()
	compute_max_total_weight = TRUE
	compute_max_item_weight = TRUE
	compute_max_item_count = TRUE
