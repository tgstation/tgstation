/**
 *Storage component used for RPEDs. Rather than manually setting everything with a get_part_rating() value, we just check if it has the variable required for insertion.
 */

//Maximum amount of an specified stack type[see allowed types below] the RPED can carry
#define MAX_STACK_PICKUP 30

/datum/storage/rped
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	max_slots = 50
	max_total_storage = 100
	max_specific_storage = WEIGHT_CLASS_NORMAL
	numerical_stacking = TRUE

	/**
	 * as of now only these stack components are required to build machines like[thermomaachine,crystallizer,electrolyzer]
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
		/obj/item/stack/ore/bluespace_crystal/refined,
		/obj/item/stack/ore/bluespace_crystal/artificial,
		/obj/item/stack/sheet/bluespace_crystal,
	)

/datum/storage/rped/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	var/atom/resolve_parent = src.parent?.resolve()
	RegisterSignal(resolve_parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(rped_mass_empty), TRUE)

/datum/storage/rped/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	. = ..()

	//we check how much of glass,plasteel & cable the user can insert
	if(isstack(to_insert))
		//user tried to insert invalid stacktype
		if(!is_type_in_list(to_insert, allowed_material_types) && !is_type_in_list(to_insert, allowed_bluespace_types))
			return FALSE

		var/obj/item/stack/the_stack = to_insert
		var/present_amount = 0

		var/obj/item/resolve_location = real_location?.resolve()
		if(!resolve_location)
			return FALSE

		//we try to count & limit how much the user can insert of each type to prevent them from using it as an normal storage medium
		for(var/obj/item/stack/stack_content in resolve_location.contents)
			//is user trying to insert any of these listed bluespace stuff
			if(is_type_in_list(to_insert,allowed_bluespace_types))
				//if yes count total bluespace stuff is the RPED and then compare the total amount to the value the user is trying to insert
				if(is_type_in_list(stack_content,allowed_bluespace_types))
					present_amount += stack_content.amount
			//count other normal stack stuff
			else if(istype(to_insert,stack_content.type))
				present_amount = stack_content.amount
				break

		//no more storage for this specific stack type
		if(MAX_STACK_PICKUP - present_amount == 0)
			return FALSE

		//we want the user to insert the exact stack amount which is available so we dont have to bother subtracting & leaving left overs for the user
		var/available = MAX_STACK_PICKUP-present_amount
		if(available - the_stack.amount < 0)
			return FALSE

	else if(istype(to_insert, /obj/item/circuitboard/machine) || istype(to_insert, /obj/item/circuitboard/computer))
		return TRUE

	//check normal insertion of other stock parts
	else if(!to_insert.get_part_rating())
		return FALSE

	return .

/// overridden mass_empty, so as to dump only the lowest tier of parts currently in the RPED
/datum/storage/rped/proc/rped_mass_empty(datum/source, atom/location, force)
	SIGNAL_HANDLER

	if(!allow_quick_empty && !force)
		return

	remove_lowest_tier(get_turf(location))

/**
 * Searches through everything currently in storage, calculates the lowest tier of parts inside of it,
 * and then dumps out every part that has the equal tier of parts. Likely a worse implementation of remove_all.
 *
 * @param atom/target where we're placing the item
 */
/datum/storage/rped/proc/remove_lowest_tier(atom/target) // look whatever happens here i'm not proud of this. at all.
	var/obj/item/resolve_parent = parent?.resolve()
	var/obj/item/resolve_location = real_location?.resolve()
	var/list/obj/item/parts_list = list()
	var/current_lowest_tier = INFINITY
	if(!resolve_parent || !resolve_location)
		return

	if(!target)
		target = get_turf(resolve_parent)

	for(var/obj/item/thing in resolve_location)
		if(thing.loc != resolve_location)
			continue
		parts_list.Add(thing)
	if(parts_list.len > 0)
		parts_list = reverse_range(sortTim(parts_list, GLOBAL_PROC_REF(cmp_rped_sort)))
		current_lowest_tier = parts_list[1].get_part_rating()
		resolve_parent.balloon_alert(resolve_parent.loc, "dropping lowest rated parts...")
		for(var/obj/item/part in parts_list)
			if(part.get_part_rating() != current_lowest_tier)
				break
			if(!attempt_remove(part, target, silent = TRUE))
				continue
			part.pixel_x = part.base_pixel_x + rand(-8, 8)
			part.pixel_y = part.base_pixel_y + rand(-8, 8)

#undef MAX_STACK_PICKUP
