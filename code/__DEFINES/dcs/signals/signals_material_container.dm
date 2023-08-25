//Material Container Signals
/// Called from datum/component/material_container/proc/can_hold_material() : (mat)
#define COMSIG_MATCONTAINER_MAT_CHECK "matcontainer_mat_check"
	#define MATCONTAINER_ALLOW_MAT (1<<0)
/// Called from datum/component/material_container/proc/user_insert() : (held_item, user)
#define COMSIG_MATCONTAINER_PRE_USER_INSERT "matcontainer_pre_user_insert"
	#define MATCONTAINER_BLOCK_INSERT (1<<1)
/// Called from datum/component/material_container/proc/insert_item() : (target, last_inserted_id, material_amount, container)
#define COMSIG_MATCONTAINER_ITEM_CONSUMED "matcontainer_item_consumed"
/// Called from datum/component/material_container/proc/retrieve_sheets() : (sheets)
#define COMSIG_MATCONTAINER_SHEETS_RETRIVED "matcontainer_sheets_retrived"
