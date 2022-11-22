/**
 *Storage component used for RPEDs. Rather than manually setting everything with a get_part_rating() value, we just check if it has the variable required for insertion.
 */

//Maximum amount of an specified stack type[see allowed types below] the RPED can carry
# define MAX_STACK_PICKUP 30

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
	var/static/list/allowed_material_types=list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/cable_coil,
	)

	/**
	 * we check if the user is trying to insert any of these bluespace crystal types into the RPED
	 * at any point the total sum of all these types in the RPED must be 30
	 * for example 10 refined crystals + 15 artifical crystals + 5 sheets=30 or any other combination like this
	 */
	var/static/list/allowed_bluespace_types=list(
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/ore/bluespace_crystal/refined,
		/obj/item/stack/ore/bluespace_crystal/artificial,
		/obj/item/stack/sheet/bluespace_crystal,
	)

/datum/storage/rped/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	. = ..()

	//we check how much of glass,plasteel & cable the user can insert
	if(isstack(to_insert))
		//user tried to insert invalid stacktype
		if(!is_type_in_list(to_insert,allowed_material_types) && !is_type_in_list(to_insert,allowed_bluespace_types))
			return FALSE

		var/obj/item/stack/the_stack = to_insert
		//how much of the stack is the user trying to insert
		var/insert_amount=the_stack.amount
		//how much of this stack type is currently in the stack
		var/present_amount=0
		//how much space is available
		var/available=0
		//stacks type
		var/obj/item/stack/things

		//not a real location so dont bother
		var/obj/item/resolve_location = real_location?.resolve()
		if(!resolve_location)
			return FALSE

		//we try to count & limit how much the user can insert of each type to prevent them from using it as an normal storage medium
		for(var/obj/item/thing in resolve_location.contents)
			//try convert to stack else skip loop as we are only intrested in counting stacks
			if(isstack(thing))
				things=thing
			else
				continue

			//count how many of this stacktype is already in storage. One type of bluespace crystal takes space for all other bluespace types as well
			if(is_type_in_list(to_insert,allowed_bluespace_types))
				if(is_type_in_list(things,allowed_bluespace_types))
					present_amount+=things.amount
			else if(istype(to_insert,things.type))
				present_amount=things.amount
				break

		//no more storage for this specific stack type
		if(MAX_STACK_PICKUP-present_amount==0)
			to_chat(usr,span_alert("No more [to_insert.name] can be added!"))
			return FALSE

		//we want the user to insert the exact stack amount which is available so we dont have to bother subtracting & leaving left overs for the user
		available = MAX_STACK_PICKUP-present_amount
		if(available-insert_amount<0)
			to_chat(usr,span_alert("You can only insert exact [available] more of [to_insert.name]!"))
			return FALSE

	//check normal insertion of other stock parts
	else if(!to_insert.get_part_rating())
		return FALSE

	return TRUE

#undef MAX_STACK_PICKUP
