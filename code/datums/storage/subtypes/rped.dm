/**
 *Storage component used for RPEDs. Rather than manually setting everything with a get_part_rating() value, we just check if it has the variable required for insertion.
 */
/datum/storage/rped
	allow_quick_empty = TRUE
	allow_quick_gather = TRUE
	max_slots = 50
	max_total_storage = 100
	max_specific_storage = WEIGHT_CLASS_NORMAL
	numerical_stacking = TRUE

/datum/storage/rped/can_insert(obj/item/to_insert, mob/user, messages = TRUE, force = FALSE)
	. = ..()

	///we check how much of glass,plasteel & cable the user can insert
	if(isstack(to_insert))
		var/obj/item/stack/the_stack=to_insert
		//how much of the stack is the user trying to insert
		var/insert_amount=the_stack.amount
		//how much of this stack type is currently in the stack
		var/present_amount=0
		//what is the maximum allowed amount for this stack type in storage
		var/max_amount=0

		//not a real location so dont bother
		var/obj/item/resolve_location = real_location?.resolve()
		if(!resolve_location)
			return FALSE

		///we try to count & limit how much the user can insert of each type to prevent them from using it as an normal storage medium
		for(var/obj/item/thing in resolve_location.contents)
			///try convert to stack else skip loop as we are only intrested in counting stacks
			var/obj/item/stack/things
			if(isstack(thing))
				things=thing
			else
				continue

			///if user is adding normal glass check how many glass sheets are in storage
			if(is_normal_glass(to_insert) && is_normal_glass(things))
				present_amount=things.amount
				break

			///if user is adding plasteel check how many plasteel sheets are in storage
			if(is_plasteel(to_insert) && is_plasteel(things))
				present_amount=things.amount
				break

			///if user is adding cable coil check  how much cable coil is in storage
			if(is_cable_coil(to_insert) && is_cable_coil(thing))
				present_amount=things.amount
				break

		///max limits for each stack type
		if(is_normal_glass(to_insert))
			max_amount=20
		else if(is_plasteel(to_insert))
			max_amount=20
		else if(is_cable_coil(to_insert))
			max_amount=30

		///user tired to insert someother stack type which is not allowed
		if(max_amount==0)
			to_chat(usr,span_alert("Only glass,plasteel & cable stacks can be added!"))
			return FALSE

		///no more storage for this specific stack type
		if(max_amount-present_amount==0)
			to_chat(usr,span_alert("No more [to_insert.name] can be added!"))
			return FALSE

		//we want the user to insert the exact stack amount which is available so we dont have to bother subtracting & leaving left overs for the user
		var/available=max_amount-present_amount
		if(available-insert_amount<0)
			to_chat(usr,span_alert("You can only insert exact [available] more of [to_insert.name]!"))
			return FALSE


	///check normal insertion of other stock parts
	else if(!to_insert.get_part_rating())
		return FALSE

	return TRUE
