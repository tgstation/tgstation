/// Passes when the keyed target is a carbon holding a lit item whose type is in a blackboard-keyed type list.
/// Use "invert": true for the opposite.
/datum/bt_node/decorator/target_holding_lit_item
	/// Blackboard key holding the atom to check.
	var/key = BB_CURRENT_TARGET
	/// Blackboard key holding the list of item typepaths we care about.
	var/item_types_key

/datum/bt_node/decorator/target_holding_lit_item/check_condition(datum/ai_controller/controller)
	var/mob/living/carbon/target = controller.blackboard[key]
	if(!iscarbon(target))
		return FALSE
	var/list/item_types = controller.blackboard[item_types_key]
	if(!length(item_types))
		return FALSE
	for(var/obj/item/held_item in target.held_items)
		if(!is_type_in_list(held_item, item_types))
			continue
		if(held_item.light_on)
			return TRUE
	return FALSE
