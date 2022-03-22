// /datum/component/storage signals
///() - returns bool.
#define COMSIG_CONTAINS_STORAGE "is_storage"
///(obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"
///(mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"
///(mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"
///returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"
///(newstate)
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"
///() - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"
///(type, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - type can be a list of types.
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"
///(type, amount = INFINITY, force = FALSE). Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"
///(obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"
///(loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"
///(list/list_to_inject_results_into, recursively_search_inside_storages = TRUE)
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"
///(obj/item/insertion_candidate, mob/user, silent) - returns bool
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"

//from base of atom/movable/on_enter_storage(): (datum/component/storage/concrete/master_storage)
#define COMSIG_STORAGE_ENTERED "storage_entered"
//from base of atom/movable/on_exit_storage(): (datum/component/storage/concrete/master_storage)
#define COMSIG_STORAGE_EXITED "storage_exited"
