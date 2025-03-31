/**
 *Storage component used for RPEDs. Rather than manually setting everything with a get_part_rating() value, we just check if it has the variable required for insertion.
 */

//Maximum amount of an specified stack type[see allowed types below] the RPED can carry
#define MAX_STACK_PICKUP 30

/datum/storage/rped
	allow_quick_gather = TRUE
	max_slots = 50
	max_total_storage = 100
	max_specific_storage = WEIGHT_CLASS_NORMAL
	numerical_stacking = TRUE

	/**
	 * as of now only these stack components are required to build machines like[thermomachine,crystallizer,electrolyzer]
	 * so we limit the rped to pick up only these stack types so players dont cheat and use this as a general storage medium
	 */
	var/static/list/allowed_material_types = list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/cable_coil,
	)

	/**
	 * we check if the user is trying to insert any of these bluespace crystal types into the RPED
	 * at any point the total sum of all these types in the RPED must be <= MAX_STACK_PICKUP
	 */
	var/static/list/allowed_bluespace_types = list(
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/sheet/bluespace_crystal,
	)

/datum/storage/rped/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	//only stock parts permited
	if(to_insert.get_part_rating())
		return ..()

	//some exceptions to non stock parts
	var/static/list/obj/item/exceptions = list(
		/obj/item/stack,
		/obj/item/circuitboard/machine,
		/obj/item/circuitboard/computer,
	)

	return is_type_in_list(to_insert, exceptions) ? ..() : FALSE

/datum/storage/rped/attempt_insert(obj/item/to_insert, mob/user, override, force, messages)
	if(isstack(to_insert))
		//user tried to insert invalid stacktype
		if(!is_type_in_list(to_insert, allowed_material_types) && !is_type_in_list(to_insert, allowed_bluespace_types))
			return FALSE

		var/obj/item/stack/the_stack = to_insert
		var/present_amount = 0

		//we try to count & limit how much the user can insert of each type to prevent them from using it as an normal storage medium
		for(var/obj/item/stack/stack_content in real_location)
			//is user trying to insert any of these listed bluespace stuff
			if(is_type_in_list(to_insert, allowed_bluespace_types))
				//if yes count total bluespace stuff is the RPED and then compare the total amount to the value the user is trying to insert
				if(is_type_in_list(stack_content, allowed_bluespace_types))
					present_amount += stack_content.amount

			//count other normal stack stuff
			else if(the_stack.merge_type == stack_content.merge_type)
				present_amount = stack_content.amount
				break

		var/available = MAX_STACK_PICKUP - present_amount

		//no more storage for this specific stack type
		if(!available)
			return FALSE

		var/obj/item/stack/target = the_stack
		if(the_stack.amount > available) //take in only a portion of the stack that can fit in our quota
			target = fast_split_stack(the_stack, available)
			target.copy_evidences(the_stack)

		. = ..(target, user, override, force, messages)
		if(!. && target != the_stack) //in case of failure merge back the split amount into the original
			the_stack.add(target.amount)
			qdel(target)

		return

	return ..()

/datum/storage/rped/mass_empty(datum/source, mob/user)
	var/list/obj/item/parts_list = list()
	for(var/obj/item/thing in real_location)
		parts_list += thing
	if(!parts_list.len)
		return

	var/current_lowest_tier = INFINITY
	parts_list = reverse_range(sortTim(parts_list, GLOBAL_PROC_REF(cmp_rped_sort)))
	current_lowest_tier = parts_list[1].get_part_rating()
	if(ismob(parent.loc))
		parent.balloon_alert(parent.loc, "dropping lowest rated parts...")

	var/dump_loc = user.drop_location()
	for(var/obj/item/part in parts_list)
		if(part.get_part_rating() != current_lowest_tier)
			break
		if(!attempt_remove(part, dump_loc, silent = TRUE))
			continue
		part.pixel_x = part.base_pixel_x + rand(-8, 8)
		part.pixel_y = part.base_pixel_y + rand(-8, 8)

///bluespace variant
/datum/storage/rped/bluespace
	max_slots = 400
	max_total_storage = 800
	max_specific_storage = WEIGHT_CLASS_GIGANTIC

#undef MAX_STACK_PICKUP
