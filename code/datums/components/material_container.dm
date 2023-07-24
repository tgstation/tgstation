/*!
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.

	Variables:
		amount - raw amount of the mineral this container is holding, calculated by the defined value SHEET_MATERIAL_AMOUNT=SHEET_MATERIAL_AMOUNT.
		max_amount - max raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		parent - object that this container is being used by, used for output.
		MAX_STACK_SIZE - size of a stack of mineral sheets. Constant.
*/

/datum/component/material_container
	/// The total amount of materials this material container contains
	var/total_amount = 0
	/// The maximum amount of materials this material container can contain
	var/max_amount
	/// Map of material ref -> amount
	var/list/materials //Map of key = material ref | Value = amount
	/// The list of materials that this material container can accept
	var/list/allowed_materials
	/// The typecache of things that this material container can accept
	var/list/allowed_item_typecache
	/// The last main material that was inserted into this container
	var/last_inserted_id
	/// Whether or not this material container allows specific amounts from sheets to be inserted
	var/precise_insertion = FALSE
	/// A callback for checking wheter we can insert a material into this container
	var/datum/callback/insertion_check
	/// A callback invoked before materials are inserted into this container
	var/datum/callback/precondition
	/// A callback invoked after materials are inserted into this container
	var/datum/callback/after_insert
	/// A callback invoked after sheets are retrieve from this container
	var/datum/callback/after_retrieve
	/// The material container flags. See __DEFINES/materials.dm.
	var/mat_container_flags

/// Sets up the proper signals and fills the list of materials with the appropriate references.
/datum/component/material_container/Initialize(list/init_mats,
			max_amt = 0,
			_mat_container_flags=NONE,
			list/allowed_mats=init_mats,
			list/allowed_items,
			datum/callback/_insertion_check,
			datum/callback/_precondition,
			datum/callback/_after_insert,
			datum/callback/_after_retrieve)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	materials = list()
	max_amount = max(0, max_amt)
	mat_container_flags = _mat_container_flags

	allowed_materials = allowed_mats || list()
	if(allowed_items)
		if(ispath(allowed_items) && allowed_items == /obj/item/stack)
			allowed_item_typecache = GLOB.typecache_stack
		else
			allowed_item_typecache = typecacheof(allowed_items)

	insertion_check = _insertion_check
	precondition = _precondition
	after_insert = _after_insert
	after_retrieve = _after_retrieve

	for(var/mat in init_mats) //Make the assoc list material reference -> amount
		var/mat_ref = GET_MATERIAL_REF(mat)
		if(isnull(mat_ref))
			continue
		var/mat_amt = init_mats[mat]
		if(isnull(mat_amt))
			mat_amt = 0
		materials[mat_ref] += mat_amt

	if(_mat_container_flags & MATCONTAINER_NO_INSERT)
		return

	var/atom/atom_target = parent
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/component/material_container/Destroy(force, silent)
	materials = null
	allowed_materials = null
	if(insertion_check)
		QDEL_NULL(insertion_check)
	if(precondition)
		QDEL_NULL(precondition)
	if(after_insert)
		QDEL_NULL(after_insert)
	if(after_retrieve)
		QDEL_NULL(after_retrieve)
	return ..()


/datum/component/material_container/RegisterWithParent()
	. = ..()

	if(!(mat_container_flags & MATCONTAINER_NO_INSERT))
		RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	if(mat_container_flags & MATCONTAINER_EXAMINE)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))


/datum/component/material_container/vv_edit_var(var_name, var_value)
	var/old_flags = mat_container_flags
	. = ..()
	if(var_name == NAMEOF(src, mat_container_flags) && parent)
		if(!(old_flags & MATCONTAINER_EXAMINE) && mat_container_flags & MATCONTAINER_EXAMINE)
			RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
		else if(old_flags & MATCONTAINER_EXAMINE && !(mat_container_flags & MATCONTAINER_EXAMINE))
			UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

		if(old_flags & MATCONTAINER_NO_INSERT && !(mat_container_flags & MATCONTAINER_NO_INSERT))
			RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
		else if(!(old_flags & MATCONTAINER_NO_INSERT) && mat_container_flags & MATCONTAINER_NO_INSERT)
			UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)


/datum/component/material_container/proc/on_examine(datum/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	for(var/I in materials)
		var/datum/material/M = I
		var/amt = materials[I]
		if(amt)
			examine_texts += span_notice("It has [amt] units of [lowertext(M.name)] stored.")

/// Proc that allows players to fill the parent with mats
/datum/component/material_container/proc/on_attackby(datum/source, obj/item/weapon, mob/living/user)
	SIGNAL_HANDLER

	user_insert(weapon, user)

	return COMPONENT_NO_AFTERATTACK

/**
 * inserts an item from the players hand into the container. Loops through all the contents inside reccursively
 * Arguments
 * * held_item - the item to insert
 * * user - the mob inserting this item
 * * breakdown_flags - how this item and all it's contents inside are broken down during insertion. This is unique to the machine doing the insertion
 */
/datum/component/material_container/proc/user_insert(obj/item/held_item, mob/living/user, breakdown_flags = mat_container_flags)
	set waitfor = FALSE
	. = 0

	//differs from held_item when using TK
	var/active_held = user.get_active_held_item()
	//don't attack the machine
	if(!(mat_container_flags & MATCONTAINER_ANY_INTENT) && user.combat_mode)
		return
	//can't allow abstract, hologram items
	if((held_item.item_flags & ABSTRACT) || (held_item.flags_1 & HOLOGRAM_1))
		return
	//untouchable
	if(held_item.resistance_flags & INDESTRUCTIBLE)
		return
	//user defined conditions
	if(precondition && !precondition.Invoke(user))
		return

	//get all contents of this item reccursively
	var/list/contents = held_item.get_all_contents_type(/obj/item)
	//anything that isn't a stack cannot be split so find out if we have enough space, we don't want to consume half the contents of an object & leave it in a broken state
	if(!isstack(held_item))
		var/total_amount = 0
		for(var/obj/item/weapon in contents)
			total_amount += get_item_material_amount(weapon, breakdown_flags)
		if(!has_space(total_amount))
			to_chat(user, span_warning("[parent] doesn't have enough space for [held_item] [contents.len > 1 ? "And it's contents" : ""]!"))
			return

	/**
	 * to reduce chat spams we group all messages and print them after everything is over
	 * usefull when we are trying to insert all stock parts of an RPED into the autolathe for example
	 */
	var/list/inserts = list()
	var/list/errors = list()

	//loop through all contents inside this atom and salvage their material as well but in reverse so we don't delete parents before processing their children
	for(var/i = length(contents); i >= 1 ; i--)
		var/obj/item/target = contents[i]

		//not a solid subtype or an hologram
		if((target.item_flags & ABSTRACT) || (target.flags_1 & HOLOGRAM_1))
			if(target == active_held) //was this the original item in the players hand? put it back because we coudn't salvage it
				user.put_in_active_hand(target)
			continue

		//item is either not allowed for redemption, not in the allowed types
		if((target.item_flags & NO_MAT_REDEMPTION) || (allowed_item_typecache && !is_type_in_typecache(target, allowed_item_typecache)))
			if(!(mat_container_flags & MATCONTAINER_SILENT))
				to_chat(user, span_warning("[parent] won't accept [target]!"))
			if(target == active_held) //was this the original item in the players hand? put it back because we coudn't salvage it
				user.put_in_active_hand(target)
			continue

		//untouchable, move it out the way, code copied from recycler
		if(target.resistance_flags & INDESTRUCTIBLE)
			if(!isturf(target.loc) && !isliving(target.loc))
				target.forceMove(get_turf(parent))
			continue

		//if stack, check if we want to read precise amount of sheets to insert
		var/obj/item/stack/item_stack = null
		if(isstack(target) && precise_insertion)
			var/atom/current_parent = parent
			item_stack = target
			var/requested_amount = tgui_input_number(user, "How much do you want to insert?", "Inserting [item_stack.singular_name]s", item_stack.amount, item_stack.amount)
			if(!requested_amount || QDELETED(target) || QDELETED(user) || QDELETED(src))
				continue
			if(parent != current_parent || user.get_active_held_item() != active_held)
				continue
			if(requested_amount != item_stack.amount) //only split if its not the whole amount
				target = split_stack(item_stack, requested_amount) //split off the requested amount
			requested_amount = 0

		//is this item a stack and was it split by the player?
		var/was_stack_split = !isnull(item_stack) && item_stack != target
		//if it was split then item_stack has the reference to the original stack/item
		var/original_item = was_stack_split ? item_stack : target
		//if this item is not the one the player is holding then don't remove it from their hand
		if(original_item != active_held)
			original_item = null
		if(!isnull(original_item) && !user.temporarilyRemoveItemFromInventory(original_item)) //remove from hand(if split remove the original stack else the target)
			to_chat(user, span_warning("[held_item] is stuck to you and cannot be placed into [parent]."))
			return

		//insert the item
		var/item_name = target.name
		var/inserted = insert_item(target, breakdown_flags = mat_container_flags)
		if(inserted > 0)
			. += inserted
			var/message = null

			//stack was either split by the container(!QDELETED(target) means the container only consumed a part of it) or by the player, put whats left back of the original stack back in players hand
			if((!QDELETED(target) || was_stack_split))

				//stack was split by player and that portion was not fully consumed, merge whats left back with the original stack
				if(!QDELETED(target) && was_stack_split)
					var/obj/item/stack/inserting_stack = target
					item_stack.add(inserting_stack.amount)
					qdel(inserting_stack)

				//was this the original item in the players hand? put what's left back in the player's hand
				if(!isnull(original_item))
					user.put_in_active_hand(original_item)
					message = "Only [inserted] amount of [item_name] was consumed by [parent]."

			//collect all messages to print later
			if(!message)
				message = "[item_name] worth [inserted] material was consumed by [parent]."
			if(inserts[message])
				inserts[message] += 1
			else
				inserts[message] = 1
		else
			var/error_msg
			if(inserted == -2)
				error_msg = "[parent] has insufficient space to accept [target]"
			else
				error_msg = "[target] has insufficient materials to be accepted by [parent]"

			//collect all messages to print later
			if(errors[error_msg])
				errors[error_msg] += 1
			else
				errors[error_msg] = 1

			//player split the stack by the requested amount but even that split amount could not be salvaged. merge it back with the original
			if(!isnull(item_stack) && was_stack_split)
				var/obj/item/stack/inserting_stack = target
				item_stack.add(inserting_stack.amount)
				qdel(inserting_stack)

			//was this the original item in the players hand? put it back because we coudn't salvage it
			if(!isnull(original_item))
				user.put_in_active_hand(original_item)

	//print successfull inserts
	for(var/success_msg in inserts)
		var/count = inserts[success_msg]
		for(var/i in 1 to count)
			to_chat(user, span_notice(success_msg))

	//print errors last
	for(var/error_msg in errors)
		var/count = errors[error_msg]
		for(var/i in 1 to count)
			to_chat(user, span_warning(error_msg))

/**
 * Splits a stack. we don't use /obj/item/stack/proc/split_stack because Byond complains that should only be called asynchronously.
 * This proc is also more faster because it doesn't deal with mobs, copying evidences or refreshing atom storages
 */
/datum/component/material_container/proc/split_stack(obj/item/stack/target, amount)
	if(!target.use(amount, TRUE, FALSE))
		return null

	. = new target.type(target.drop_location(), amount, FALSE, target.mats_per_unit)
	target.loc.atom_storage?.refresh_views()

	target.is_zero_amount(delete_if_zero = TRUE)

/// Proc specifically for inserting items, returns the amount of materials entered.
/datum/component/material_container/proc/insert_item(obj/item/weapon, multiplier = 1, breakdown_flags = mat_container_flags)
	if(QDELETED(weapon))
		return MATERIAL_INSERT_ITEM_NO_MATS
	multiplier = CEILING(multiplier, 0.01)

	var/obj/item/target = weapon

	var/material_amount = get_item_material_amount(target, breakdown_flags) * multiplier
	if(!material_amount)
		return MATERIAL_INSERT_ITEM_NO_MATS
	var/obj/item/stack/item_stack
	if(isstack(weapon) && !has_space(material_amount)) //not enugh space split and feed as many sheets possible
		item_stack = weapon
		var/space_left = max_amount - total_amount
		if(!space_left)
			return MATERIAL_INSERT_ITEM_NO_SPACE
		var/material_per_sheet = material_amount / item_stack.amount
		var/sheets_to_insert = round(space_left / material_per_sheet)
		if(!sheets_to_insert)
			return MATERIAL_INSERT_ITEM_NO_SPACE
		target = split_stack(item_stack, sheets_to_insert)
		material_amount = get_item_material_amount(target, breakdown_flags) * multiplier
	if(!has_space(material_amount))
		return MATERIAL_INSERT_ITEM_NO_SPACE

	last_inserted_id = insert_item_materials(target, multiplier, breakdown_flags)
	if(!isnull(last_inserted_id))
		if(after_insert)
			after_insert.Invoke(target, last_inserted_id, material_amount, src)
		qdel(target) //item gone
		return material_amount
	else if(!isnull(item_stack) && item_stack != target) //insertion failed, merge the split stack back into the original
		var/obj/item/stack/inserting_stack = target
		item_stack.add(inserting_stack.amount)
		qdel(inserting_stack)
	return MATERIAL_INSERT_ITEM_FAILURE

/**
 * Inserts the relevant materials from an item into this material container.
 *
 * Arguments:
 * - [source][/obj/item]: The source of the materials we are inserting.
 * - multiplier: The multiplier for the materials being inserted.
 * - breakdown_flags: The breakdown bitflags that will be used to retrieve the materials from the source
 */
/datum/component/material_container/proc/insert_item_materials(obj/item/source, multiplier = 1, breakdown_flags = mat_container_flags)
	var/primary_mat
	var/max_mat_value = 0
	var/list/item_materials = source.get_material_composition(breakdown_flags)
	for(var/MAT in item_materials)
		if(!can_hold_material(MAT))
			continue
		materials[MAT] += item_materials[MAT] * multiplier
		total_amount += item_materials[MAT] * multiplier
		if(item_materials[MAT] > max_mat_value)
			max_mat_value = item_materials[MAT]
			primary_mat = MAT

	return primary_mat

/**
 * The default check for whether we can add materials to this material container.
 *
 * Arguments:
 * - [mat][/atom/material]: The material we are checking for insertability.
 */
/datum/component/material_container/proc/can_hold_material(datum/material/mat)
	if(mat in allowed_materials)
		return TRUE
	if(istype(mat) && ((mat.id in allowed_materials) || (mat.type in allowed_materials)))
		allowed_materials += mat // This could get messy with passing lists by ref... but if you're doing that the list expansion is probably being taken care of elsewhere anyway...
		return TRUE
	if(insertion_check?.Invoke(mat))
		allowed_materials += mat
		return TRUE
	return FALSE

/// For inserting an amount of material
/datum/component/material_container/proc/insert_amount_mat(amt, datum/material/mat)
	if(amt <= 0 || !has_space(amt))
		return 0

	var/total_amount_saved = total_amount
	if(mat)
		if(!istype(mat))
			mat = GET_MATERIAL_REF(mat)
		materials[mat] += amt
	else
		var/num_materials = length(materials)
		if(!num_materials)
			return 0

		amt /= num_materials
		for(var/i in materials)
			materials[i] += amt
			total_amount += amt
	return (total_amount - total_amount_saved)

/// Uses an amount of a specific material, effectively removing it.
/datum/component/material_container/proc/use_amount_mat(amt, datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)

	if(!mat)
		return 0
	var/amount = materials[mat]
	if(amount < amt)
		return 0

	materials[mat] -= amt
	total_amount -= amt
	return amt

/// Proc for transfering materials to another container.
/datum/component/material_container/proc/transer_amt_to(datum/component/material_container/T, amt, datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)
	if((amt == 0) || (!T) || (!mat))
		return FALSE
	if(amt<0)
		return T.transer_amt_to(src, -amt, mat)
	var/tr = min(amt, materials[mat], T.can_insert_amount_mat(amt, mat))
	if(tr)
		use_amount_mat(tr, mat)
		T.insert_amount_mat(tr, mat)
		return tr
	return FALSE

/// Proc for checking if there is room in the component, returning the amount or else the amount lacking.
/datum/component/material_container/proc/can_insert_amount_mat(amt, datum/material/mat)
	if(!amt || !mat)
		return 0

	if((total_amount + amt) <= max_amount)
		return amt
	else
		return (max_amount - total_amount)


/// For consuming a dictionary of materials. mats is the map of materials to use and the corresponding amounts, example: list(M/datum/material/glass =100, datum/material/iron=SMALL_MATERIAL_AMOUNT * 2)
/datum/component/material_container/proc/use_materials(list/mats, multiplier=1)
	if(!mats || !length(mats))
		return FALSE

	var/list/mats_to_remove = list() //Assoc list MAT | AMOUNT

	for(var/x in mats) //Loop through all required materials
		var/datum/material/req_mat = x
		if(!istype(req_mat))
			req_mat = GET_MATERIAL_REF(req_mat) //Get the ref if necesary
		if(!materials[req_mat]) //Do we have the resource?
			return FALSE //Can't afford it
		var/amount_required = mats[x] * multiplier
		if(amount_required < 0)
			return FALSE //No negative mats
		if(!(materials[req_mat] >= amount_required)) // do we have enough of the resource?
			return FALSE //Can't afford it
		mats_to_remove[req_mat] += amount_required //Add it to the assoc list of things to remove
		continue

	var/total_amount_save = total_amount

	for(var/i in mats_to_remove)
		total_amount_save -= use_amount_mat(mats_to_remove[i], i)

	return total_amount_save - total_amount

/// For spawning mineral sheets at a specific location. Used by machines to output sheets.
/datum/component/material_container/proc/retrieve_sheets(sheet_amt, datum/material/material, atom/target = null)
	if(!material.sheet_type)
		return 0 //Add greyscale sheet handling here later
	if(sheet_amt <= 0)
		return 0

	if(!target)
		var/atom/parent_atom = parent
		target = parent_atom.drop_location()
	if(materials[material] < (sheet_amt * SHEET_MATERIAL_AMOUNT))
		sheet_amt = round(materials[material] / SHEET_MATERIAL_AMOUNT)
	var/count = 0
	while(sheet_amt > MAX_STACK_SIZE)
		var/obj/item/stack/sheet/new_sheets = new material.sheet_type(target, MAX_STACK_SIZE, null, list((material) = SHEET_MATERIAL_AMOUNT))
		after_retrieve?.Invoke(new_sheets)
		count += MAX_STACK_SIZE
		use_amount_mat(sheet_amt * SHEET_MATERIAL_AMOUNT, material)
		sheet_amt -= MAX_STACK_SIZE
	if(sheet_amt >= 1)
		var/obj/item/stack/sheet/new_sheets = new material.sheet_type(target, sheet_amt, null, list((material) = SHEET_MATERIAL_AMOUNT))
		after_retrieve?.Invoke(new_sheets)
		count += sheet_amt
		use_amount_mat(sheet_amt * SHEET_MATERIAL_AMOUNT, material)
	return count


/// Proc to get all the materials and dump them as sheets
/datum/component/material_container/proc/retrieve_all(target = null)
	var/result = 0
	for(var/MAT in materials)
		var/amount = materials[MAT]
		result += retrieve_sheets(amount2sheet(amount), MAT, target)
	return result

/// Proc that returns TRUE if the container has space
/datum/component/material_container/proc/has_space(amt = 0)
	return (total_amount + amt) <= max_amount

/// Checks if its possible to afford a certain amount of materials. Takes a dictionary of materials.
/datum/component/material_container/proc/has_materials(list/mats, multiplier=1)
	if(!mats || !mats.len)
		return FALSE

	for(var/x in mats) //Loop through all required materials
		var/datum/material/req_mat = x
		if(!istype(req_mat))
			if(ispath(req_mat)) //Is this an actual material, or is it a category?
				req_mat = GET_MATERIAL_REF(req_mat) //Get the ref

			else // Its a category. (For example MAT_CATEGORY_RIGID)
				if(!has_enough_of_category(req_mat, mats[x], multiplier)) //Do we have enough of this category?
					return FALSE
				else
					continue

		if(!has_enough_of_material(req_mat, mats[x], multiplier))//Not a category, so just check the normal way
			return FALSE

	return TRUE

/// Returns all the categories in a recipe.
/datum/component/material_container/proc/get_categories(list/mats)
	var/list/categories = list()
	for(var/x in mats) //Loop through all required materials
		if(!istext(x)) //This means its not a category
			continue
		categories += x
	return categories

/// Returns TRUE if you have enough of the specified material.
/datum/component/material_container/proc/has_enough_of_material(datum/material/req_mat, amount, multiplier=1)
	if(!materials[req_mat]) //Do we have the resource?
		return FALSE //Can't afford it
	var/amount_required = amount * multiplier
	if(materials[req_mat] >= amount_required) // do we have enough of the resource?
		return TRUE
	return FALSE //Can't afford it

/// Returns TRUE if you have enough of a specified material category (Which could be multiple materials)
/datum/component/material_container/proc/has_enough_of_category(category, amount, multiplier=1)
	for(var/i in SSmaterials.materials_by_category[category])
		var/datum/material/mat = i
		if(materials[mat] >= amount) //we have enough
			return TRUE
	return FALSE

/// Turns a material amount into the amount of sheets it should output
/datum/component/material_container/proc/amount2sheet(amt)
	if(amt >= SHEET_MATERIAL_AMOUNT)
		return round(amt / SHEET_MATERIAL_AMOUNT)
	return FALSE

/// Turns an amount of sheets into the amount of material amount it should output
/datum/component/material_container/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * SHEET_MATERIAL_AMOUNT
	return FALSE


///returns the amount of material relevant to this container; if this container does not support glass, any glass in 'I' will not be taken into account
/datum/component/material_container/proc/get_item_material_amount(obj/item/I, breakdown_flags = mat_container_flags)
	if(!istype(I) || !I.custom_materials)
		return 0
	var/material_amount = 0
	var/list/item_materials = I.get_material_composition(breakdown_flags)
	for(var/MAT in item_materials)
		if(!can_hold_material(MAT))
			continue
		material_amount += item_materials[MAT]
	return material_amount

/// Returns the amount of a specific material in this container.
/datum/component/material_container/proc/get_material_amount(datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)
	return materials[mat]

/datum/component/material_container/ui_static_data(mob/user)
	var/list/data = list()
	data["SHEET_MATERIAL_AMOUNT"] = SHEET_MATERIAL_AMOUNT
	return data

/// List format is list(material_name = list(amount = ..., ref = ..., etc.))
/datum/component/material_container/ui_data(mob/user)
	var/list/data = list()

	for(var/datum/material/material as anything in materials)
		var/amount = materials[material]

		data += list(list(
			"name" = material.name,
			"ref" = REF(material),
			"amount" = amount,
			"sheets" = round(amount / SHEET_MATERIAL_AMOUNT),
			"removable" = amount >= SHEET_MATERIAL_AMOUNT,
			"color" = material.greyscale_colors
		))

	return data

/**
 * Adds context sensitivy directly to the material container file for screentips
 * Arguments:
 * * source - refers to item that will display its screentip
 * * context - refers to, in this case, an item in the users hand hovering over the material container, such as an autolathe
 * * held_item - refers to the item that has materials accepted by the material container
 * * user - refers to user who will see the screentip when the proper context and tool are there
 */
/datum/component/material_container/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER

	if(isnull(held_item))
		return NONE
	if(!(mat_container_flags & MATCONTAINER_ANY_INTENT) && user.combat_mode)
		return NONE
	if(held_item.item_flags & ABSTRACT)
		return NONE
	if((held_item.flags_1 & HOLOGRAM_1) || (held_item.item_flags & NO_MAT_REDEMPTION) || (allowed_item_typecache && !is_type_in_typecache(held_item, allowed_item_typecache)))
		return NONE
	var/list/item_materials = held_item.get_material_composition(mat_container_flags)
	if(!length(item_materials))
		return NONE
	for(var/material in item_materials)
		if(can_hold_material(material))
			continue
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "Insert"

	return CONTEXTUAL_SCREENTIP_SET
