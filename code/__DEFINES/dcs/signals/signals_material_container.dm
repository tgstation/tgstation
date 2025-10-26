//Material Container Signals
/// Called from datum/component/material_container/proc/can_hold_material() : (mat)
#define COMSIG_MATCONTAINER_MAT_CHECK "matcontainer_mat_check"
	#define MATCONTAINER_ALLOW_MAT (1<<0)
/// Called from datum/component/material_container/proc/user_insert() : (target_item, user)
#define COMSIG_MATCONTAINER_PRE_USER_INSERT "matcontainer_pre_user_insert"
	#define MATCONTAINER_BLOCK_INSERT (1<<1)
/// Called from datum/component/material_container/proc/insert_item() : (item, primary_mat, mats_consumed, material_amount, context)
#define COMSIG_MATCONTAINER_ITEM_CONSUMED "matcontainer_item_consumed"
/// Called from datum/component/material_container/proc/retrieve_stack() : (new_stack, context)
#define COMSIG_MATCONTAINER_STACK_RETRIEVED "matcontainer_stack_retrieved"

//mat container signals but from the ore silo's perspective
/// Called from /obj/machinery/ore_silo/on_item_consumed() : (container, item_inserted, last_inserted_id, mats_consumed, amount_inserted)
#define COMSIG_SILO_ITEM_CONSUMED "silo_item_consumed"
