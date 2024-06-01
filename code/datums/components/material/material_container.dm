/*!
	This datum should be used for handling mineral contents of machines and whatever else is supposed to hold minerals and make use of them.

	Variables:
		amount - raw amount of the mineral this container is holding, calculated by the defined value SHEET_MATERIAL_AMOUNT=SHEET_MATERIAL_AMOUNT.
		max_amount - max raw amount of mineral this container can hold.
		sheet_type - type of the mineral sheet the container handles, used for output.
		parent - object that this container is being used by, used for output.
		MAX_STACK_SIZE - size of a stack of mineral sheets. Constant.
*/

//The full item was consumed
#define MATERIAL_INSERT_ITEM_SUCCESS 1

/datum/component/material_container
	/// The maximum amount of materials this material container can contain
	var/max_amount
	/// Map of material ref -> amount
	var/list/materials //Map of key = material ref | Value = amount
	/// The list of materials that this material container can accept
	var/list/allowed_materials
	/// The typecache of things that this material container can accept
	var/list/allowed_item_typecache
	/// Whether or not this material container allows specific amounts from sheets to be inserted
	var/precise_insertion = FALSE
	/// The material container flags. See __DEFINES/materials.dm.
	var/mat_container_flags
	/// Signals that are registered with this contained
	var/list/registered_signals

/// Sets up the proper signals and fills the list of materials with the appropriate references.
/datum/component/material_container/Initialize(
	list/init_mats,
	max_amt = 0,
	_mat_container_flags = NONE,
	list/allowed_mats = init_mats,
	list/allowed_items,
	list/container_signals
)

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

	for(var/mat in init_mats) //Make the assoc list material reference -> amount
		var/mat_ref = GET_MATERIAL_REF(mat)
		if(isnull(mat_ref))
			continue
		var/mat_amt = init_mats[mat]
		if(isnull(mat_amt))
			mat_amt = 0
		materials[mat_ref] += mat_amt

	//all user handled signals
	if(length(container_signals))
		for(var/signal in container_signals)
			parent.RegisterSignal(src, signal, container_signals[signal])

	//drop sheets when the object is deconstructed but not deleted
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(drop_sheets))

	if(_mat_container_flags & MATCONTAINER_NO_INSERT)
		return

	var/atom/atom_target = parent
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/component/material_container/Destroy(force)
	materials = null
	allowed_materials = null
	return ..()

/datum/component/material_container/RegisterWithParent()
	. = ..()

	if(!(mat_container_flags & MATCONTAINER_NO_INSERT))
		RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	if(mat_container_flags & MATCONTAINER_EXAMINE)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/material_container/proc/drop_sheets()
	SIGNAL_HANDLER

	retrieve_all()

/datum/component/material_container/proc/on_examine(datum/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	for(var/I in materials)
		var/datum/material/M = I
		var/amt = materials[I] / SHEET_MATERIAL_AMOUNT
		if(amt)
			examine_texts += span_notice("It has [amt] sheets of [LOWER_TEXT(M.name)] stored.")

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

/**
 * 3 Types of Procs
 * Material Insertion  : Insert materials into the container
 * Material Validation : Checks how much materials are available, Extracts materials from items if the container can hold them
 * Material Removal    : Removes material from the container
 *
 * Each Proc furthur belongs to a specific category
 * LOW LEVEL:  Procs that are used internally & should not be used anywhere else unless you know what your doing
 * MID LEVEL:  Procs that can be used by machines(like recycler, stacking machines) to bypass majority of checks
 * HIGH LEVEL: Procs that can be used by anyone publically and guarentees safty checks & limits
 */

//================================Material Insertion procs==============================

//======================================LOW LEVEL=========================================
/**
 * Inserts the relevant materials from an item into this material container.
 * This low level proc should not be used directly by anyone
 *
 * Arguments:
 * - [source][/obj/item]: The source of the materials we are inserting.
 * - multiplier: The multiplier for the materials extract from this item being inserted.
 * - context: the atom performing the operation, this is the last argument sent in COMSIG_MATCONTAINER_ITEM_CONSUMED
 * and is used mostly for silo logging, the silo resends this signal on the context to give it a
 * chance to process the item
 */
/datum/component/material_container/proc/insert_item_materials(obj/item/source, multiplier = 1, atom/context = parent)
	var/primary_mat
	var/max_mat_value = 0
	var/material_amount = 0

	var/list/item_materials = source.get_material_composition()
	var/list/mats_consumed = list()
	for(var/MAT in item_materials)
		if(!can_hold_material(MAT))
			continue
		var/mat_amount = OPTIMAL_COST(item_materials[MAT] * multiplier)
		materials[MAT] += mat_amount
		if(item_materials[MAT] > max_mat_value)
			max_mat_value = item_materials[MAT]
			primary_mat = MAT
		mats_consumed[MAT] = mat_amount
		material_amount += mat_amount
	if(length(mats_consumed))
		SEND_SIGNAL(src, COMSIG_MATCONTAINER_ITEM_CONSUMED, source, primary_mat, mats_consumed, material_amount, context)

	return primary_mat
//===================================================================================


//===============================MID LEVEL===================================================
/**
 * For inserting an amount of material. Use this to add materials to the container directly
 *
 * Arguments:
 * - amt: amount of said material to insert
 * - mat: the material type to insert
 */
/datum/component/material_container/proc/insert_amount_mat(amt, datum/material/mat)
	if(amt <= 0)
		return 0
	amt = OPTIMAL_COST(amt)
	if(!has_space(amt))
		return 0

	var/total_amount_saved = total_amount()
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
	return (total_amount() - total_amount_saved)

/**
 * Proc specifically for inserting items, use this when you want to insert any item into the container
 * this bypasses most of the material flag checks so much be used by machines like recycler, stacking machine etc that
 * does not care for such checks
 *
 * Arguments:
 * - [weapon][obj/item]: the item you are trying to insert
 * - multiplier: The multiplier for the materials being inserted
 * - context: the atom performing the operation, this is the last argument sent in COMSIG_MATCONTAINER_ITEM_CONSUMED and is used mostly for silo logging
 */
/datum/component/material_container/proc/insert_item(obj/item/weapon, multiplier = 1, atom/context = parent)
	if(QDELETED(weapon))
		return MATERIAL_INSERT_ITEM_NO_MATS
	multiplier = CEILING(multiplier, 0.01)

	var/obj/item/target = weapon

	var/material_amount = OPTIMAL_COST(get_item_material_amount(target) * multiplier)
	if(!material_amount)
		return MATERIAL_INSERT_ITEM_NO_MATS
	var/obj/item/stack/item_stack
	if(isstack(weapon) && !has_space(material_amount)) //not enough space split and feed as many sheets possible
		item_stack = weapon
		var/space_left = max_amount - total_amount()
		if(!space_left)
			return MATERIAL_INSERT_ITEM_NO_SPACE
		var/material_per_sheet = material_amount / item_stack.amount
		var/sheets_to_insert = round(space_left / material_per_sheet)
		if(!sheets_to_insert)
			return MATERIAL_INSERT_ITEM_NO_SPACE
		target = fast_split_stack(item_stack, sheets_to_insert)
		material_amount = get_item_material_amount(target) * multiplier
	material_amount = OPTIMAL_COST(material_amount)

	//not enough space, time to bail
	if(!has_space(material_amount))
		return MATERIAL_INSERT_ITEM_NO_SPACE

	//do the insert
	var/last_inserted_id = insert_item_materials(target, multiplier, context)
	if(!isnull(last_inserted_id))
		qdel(target) //item gone
		return material_amount
	else if(!isnull(item_stack) && item_stack != target) //insertion failed, merge the split stack back into the original
		var/obj/item/stack/inserting_stack = target
		item_stack.add(inserting_stack.amount)
		qdel(inserting_stack)

	return MATERIAL_INSERT_ITEM_FAILURE
//============================================================================================


//===================================HIGH LEVEL===================================================
/**
 * inserts an item from the players hand into the container. Loops through all the contents inside reccursively
 * Does all explicit checking for mat flags & callbacks to check if insertion is valid
 * This proc is what you should be using for almost all cases
 *
 * Arguments:
 * * held_item - the item to insert
 * * user - the mob inserting this item
 * * context - the atom performing the operation, this is the last argument sent in COMSIG_MATCONTAINER_ITEM_CONSUMED and is used mostly for silo logging
 */
/datum/component/material_container/proc/user_insert(obj/item/held_item, mob/living/user, atom/context = parent)
	set waitfor = FALSE
	. = 0

	//All items that do not have any contents
	var/list/obj/item/child_items = list()
	//All items that do have contents but they were already processed by the above list
	var/list/obj/item/parent_items = list(held_item)
	//is this the first item we are ever processing
	var/first_checks = TRUE
	//The status of the last insert attempt
	var/inserted = 0
	//All messages to be displayed to chat
	var/list/chat_msgs = list()
	//differs from held_item when using TK
	var/active_held = user.get_active_held_item()
	//storage items to retrive items from
	var/static/list/storage_items
	if(isnull(storage_items))
		storage_items = list(
			/obj/item/storage/backpack,
			/obj/item/storage/bag,
			/obj/item/storage/box,
		)

	//1st iteration consumes all items that do not have contents inside
	//2nd iteration consumes items who do have contents inside(but they were consumed in the 1st iteration so its empty now)
	for(var/i in 1 to 2)
		//no point inserting more items
		if(inserted == MATERIAL_INSERT_ITEM_NO_SPACE)
			break

		//transfer all items for processing
		if(!parent_items.len)
			break
		child_items += parent_items
		parent_items.Cut()

		while(child_items.len)
			//Pop the 1st item out from the list
			var/obj/item/target_item = child_items[1]
			child_items -= target_item

			//e.g. projectiles inside bullets are not objects
			if(!istype(target_item))
				continue
			//can't allow abstract, hologram items
			if((target_item.item_flags & ABSTRACT) || (target_item.flags_1 & HOLOGRAM_1))
				continue
			//user defined conditions
			if(SEND_SIGNAL(src, COMSIG_MATCONTAINER_PRE_USER_INSERT, target_item, user) & MATCONTAINER_BLOCK_INSERT)
				continue
			//item is either indestructible, not allowed for redemption or not in the allowed types
			if((target_item.resistance_flags & INDESTRUCTIBLE) || (target_item.item_flags & NO_MAT_REDEMPTION) || (allowed_item_typecache && !is_type_in_typecache(target_item, allowed_item_typecache)))
				if(!(mat_container_flags & MATCONTAINER_SILENT) && i == 1) //count only child items the 1st time around
					var/list/status_data = chat_msgs["[MATERIAL_INSERT_ITEM_FAILURE]"] || list()
					var/list/item_data = status_data[target_item.name] || list()
					item_data["count"] += 1
					status_data[target_item.name] = item_data
					chat_msgs["[MATERIAL_INSERT_ITEM_FAILURE]"] = status_data

				if(target_item.resistance_flags & INDESTRUCTIBLE)
					if(i == 1 && target_item != active_held) //move it out of any storage medium its in so it doesn't get consumed with its parent, but only if that storage medium is not our hand
						target_item.forceMove(get_turf(context))
					continue
				//storage items usually come here but we make the exception only on the 1st iteration
				//this is so players can insert items from their bags into machines for convinience
				if(!is_type_in_list(target_item, storage_items))
					continue
				else if(!target_item.contents.len || i == 2)
					continue
			//at this point we can check if we have enough for all items & other stuff
			if(first_checks)
				//duffle bags needs to be unzipped
				if(target_item.atom_storage?.locked)
					if(!(mat_container_flags & MATCONTAINER_SILENT))
						to_chat(user, span_warning("[target_item] has its storage locked"))
					return

				//anything that isn't a stack cannot be split so find out if we have enough space, we don't want to consume half the contents of an object & leave it in a broken state
				//for duffle bags and other storage items we can check for space 1 item at a time
				if(!isstack(target_item) && !is_type_in_list(target_item, storage_items))
					var/total_amount = 0
					for(var/obj/item/weapon as anything in target_item.get_all_contents_type(/obj/item))
						total_amount += get_item_material_amount(weapon)
					if(!has_space(total_amount))
						if(!(mat_container_flags & MATCONTAINER_SILENT))
							to_chat(user, span_warning("[parent] does not have enough space for [target_item]!"))
						return

				first_checks = FALSE

			//All hard checks have passed, at this point we can consume the item
			//If it has children then we will process them first and then the item in the 2nd round
			//This is done so we don't delete the children when the parent is consumed
			//We only do this on the 1st iteration so we don't re-iterate through its children again
			if(target_item.contents.len && i == 1)
				if(target_item.atom_storage?.locked) //can't access contents of locked storage(like duffle bags)
					continue
				//process children
				child_items += target_item.contents
				//in the 2nd round only after its children are consumed do we consume this next, FIFO order
				parent_items.Insert(1, target_item)
				//leave it here till we get to its children
				continue

			//if stack, check if we want to read precise amount of sheets to insert
			var/obj/item/stack/item_stack = null
			if(isstack(target_item) && precise_insertion)
				var/atom/current_parent = parent
				item_stack = target_item
				var/requested_amount = tgui_input_number(user, "How much do you want to insert?", "Inserting [item_stack.singular_name]s", item_stack.amount, item_stack.amount)
				if(!requested_amount || QDELETED(target_item) || QDELETED(user) || QDELETED(src))
					continue
				if(parent != current_parent || user.get_active_held_item() != active_held)
					continue
				if(requested_amount != item_stack.amount) //only split if its not the whole amount
					target_item = fast_split_stack(item_stack, requested_amount) //split off the requested amount
				requested_amount = 0

			//is this item a stack and was it split by the player?
			var/was_stack_split = !isnull(item_stack) && item_stack != target_item
			//if it was split then item_stack has the reference to the original stack/item
			var/original_item = was_stack_split ? item_stack : target_item
			//if this item is not the one the player is holding then don't remove it from their hand
			if(original_item != active_held)
				original_item = null
			if(!isnull(original_item) && !user.temporarilyRemoveItemFromInventory(original_item)) //remove from hand(if split remove the original stack else the target)
				return

			//insert the item
			var/item_name = target_item.name
			var/item_count = 1
			var/is_stack = FALSE
			if(isstack(target_item))
				var/obj/item/stack/the_stack = target_item
				item_name = the_stack.singular_name
				item_count = the_stack.amount
				is_stack = TRUE
			inserted = insert_item(target_item, 1, context)
			if(inserted > 0)
				. += inserted
				inserted /= SHEET_MATERIAL_AMOUNT // display units inserted as sheets for improved readability

				//stack was either split by the container(!QDELETED(target_item) means the container only consumed a part of it) or by the player, put whats left back of the original stack back in players hand
				if((!QDELETED(target_item) || was_stack_split))

					//stack was split by player and that portion was not fully consumed, merge whats left back with the original stack
					if(!QDELETED(target_item) && was_stack_split)
						var/obj/item/stack/inserting_stack = target_item
						item_stack.add(inserting_stack.amount)
						qdel(inserting_stack)

					//was this the original item in the players hand? put what's left back in the player's hand
					if(!isnull(original_item))
						user.put_in_active_hand(original_item)

				//collect all messages to print later
				var/list/status_data = chat_msgs["[MATERIAL_INSERT_ITEM_SUCCESS]"] || list()
				var/list/item_data = status_data[item_name] || list()
				item_data["count"] += item_count
				item_data["amount"] += inserted
				item_data["stack"] = is_stack
				status_data[item_name] = item_data
				chat_msgs["[MATERIAL_INSERT_ITEM_SUCCESS]"] = status_data

			else
				//collect all messages to print later
				var/list/status_data = chat_msgs["[inserted]"] || list()
				var/list/item_data = status_data[item_name] || list()
				item_data["count"] += item_count
				status_data[item_name] = item_data
				chat_msgs["[inserted]"] = status_data

				//player split the stack by the requested amount but even that split amount could not be salvaged. merge it back with the original
				if(!isnull(item_stack) && was_stack_split)
					var/obj/item/stack/inserting_stack = target_item
					item_stack.add(inserting_stack.amount)
					qdel(inserting_stack)

				//was this the original item in the players hand? put it back because we coudn't salvage it
				if(!isnull(original_item))
					user.put_in_active_hand(original_item)

				//we can stop here as remaining items will fail to insert as well
				if(inserted == MATERIAL_INSERT_ITEM_NO_SPACE)
					break

	//we now summarize the chat msgs collected
	if(!(mat_container_flags & MATCONTAINER_SILENT))
		for(var/status as anything in chat_msgs)
			var/list/status_data = chat_msgs[status]

			for(var/item_name as anything in status_data)
				//read the params
				var/list/chat_data = status_data[item_name]
				var/count = chat_data["count"]
				var/amount = chat_data["amount"]

				//decode the message
				switch(text2num(status))
					if(MATERIAL_INSERT_ITEM_SUCCESS) //no problems full item was consumed
						if(chat_data["stack"])
							var/sheets = min(count, amount) //minimum between sheets inserted vs sheets consumed(values differ for alloys)
							to_chat(user, span_notice("[sheets > 1 ? sheets : ""] [item_name][sheets > 1 ? "s were" : " was"] added to [parent]."))
						else
							to_chat(user, span_notice("[count > 1 ? count : ""] [item_name][count > 1 ? "s" : ""], worth [amount] sheets, [count > 1 ? "were" : "was"] added to [parent]."))
					if(MATERIAL_INSERT_ITEM_NO_SPACE) //no space
						to_chat(user, span_warning("[parent] has no space to accept [item_name]!"))
					if(MATERIAL_INSERT_ITEM_NO_MATS) //no materials inside these items
						to_chat(user, span_warning("[item_name][count > 1 ? "s have" : " has"] no materials that can be accepted by [parent]!"))
					if(MATERIAL_INSERT_ITEM_FAILURE) //could be because the material type was not accepted or other stuff
						to_chat(user, span_warning("[item_name][count > 1 ? "s were" : " was"] rejected by [parent]!"))

/// Proc that allows players to fill the parent with mats
/datum/component/material_container/proc/on_attackby(datum/source, obj/item/weapon, mob/living/user)
	SIGNAL_HANDLER

	//Allows you to attack the machine with iron sheets for e.g.
	if(!(mat_container_flags & MATCONTAINER_ANY_INTENT) && user.combat_mode)
		return

	user_insert(weapon, user)

	return COMPONENT_NO_AFTERATTACK
//===============================================================================================


//======================================Material Validation=======================================

//=========================================LOW LEVEL===================================
/**
 * Proc that returns TRUE if the container has space
 *
 * Arguments:
 * * amt - can this container hold this much amount of materials
 */
/datum/component/material_container/proc/has_space(amt = 0)
	return (total_amount() + amt) <= max_amount

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
	if(SEND_SIGNAL(src, COMSIG_MATCONTAINER_MAT_CHECK, mat) & MATCONTAINER_ALLOW_MAT)
		allowed_materials += mat
		return TRUE
	return FALSE
//========================================================================================


//===================================MID LEVEL=============================================
/**
 * Returns the amount of a specific material in this container.
 *
 * Arguments:
 * -[mat][datum/material] : the material type to check for 3 cases
 * a) If it's an path its ref is retrieved
 * b) If it's text then its an category material & there is no way to deal with it so return 0
 * c) If normal material proceeds as usual
 */
/datum/component/material_container/proc/get_material_amount(datum/material/mat)
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)
	return materials[mat]

/**
 * Returns the amount of material relevant to this container;
 * if this container does not support glass, any glass in 'I' will not be taken into account
 *
 * Arguments:
 * - [I][obj/item]: the item whos materials must be retrieved
 */
/datum/component/material_container/proc/get_item_material_amount(obj/item/I)
	if(!istype(I) || !I.custom_materials)
		return 0
	var/material_amount = 0
	var/list/item_materials = I.get_material_composition()
	for(var/MAT in item_materials)
		if(!can_hold_material(MAT))
			continue
		material_amount += item_materials[MAT]
	return material_amount
//================================================================================================


//=========================================HIGH LEVEL==========================================
/// returns the total amount of material in the container
/datum/component/material_container/proc/total_amount()
	. = 0
	for(var/i in materials)
		. += get_material_amount(i)

/**
 * Returns TRUE if you have enough of the specified material.
 *
 * Arguments:
 * - [req_mat][datum/material]: the material to check for
 * - amount: how much material do we need
 */
/datum/component/material_container/proc/has_enough_of_material(datum/material/req_mat, amount = 1)
	return get_material_amount(req_mat) >= OPTIMAL_COST(amount)


/**
 * Checks if its possible to afford a certain amount of materials. Takes a dictionary of materials.
 * coefficient can be thought of as the machines efficiency & multiplier as the print quantity
 *
 * Arguments:
 * - mats: list of materials(key=material, value= 1 unit of material) to check for
 * - coefficient: scaling applied to 1 unit of material in the mats list
 * - multiplier: how many units(after scaling) do we require
 */
/datum/component/material_container/proc/has_materials(list/mats, coefficient = 1, multiplier = 1)
	if(!length(mats))
		return FALSE

	for(var/x in mats) //Loop through all required materials
		var/wanted = OPTIMAL_COST(mats[x] * coefficient) * multiplier
		if(!has_enough_of_material(x, wanted))//Not a category, so just check the normal way
			testing("didnt have: [x] wanted: [wanted]")
			return FALSE

	return TRUE
//==========================================================================================================


//================================================Material Usage============================================

//==================================================LOW LEVEL=======================================
/**
 * Uses an amount of a specific material, effectively removing it.
 *
 * Arguments:
 * - amt: amount of said material to use
 * - [mat][datum/material]: type of mat to use
 */
/datum/component/material_container/proc/use_amount_mat(amt, datum/material/mat)
	//round amount
	amt = OPTIMAL_COST(amt)

	//get ref if nessassary
	if(!istype(mat))
		mat = GET_MATERIAL_REF(mat)

	//check if sufficient is available
	if(materials[mat] < amt)
		return 0

	//consume & return amount consumed
	materials[mat] -= amt
	return amt
//==============================================================================================

//=========================================MID LEVEL==========================================
/**
 * For consuming a dictionary of materials.
 *
 * Arguments:
 * - mats: map of materials to consume(key = material type, value = amount)
 * - coefficient: how much fraction of unit material in the mats list must be consumed. This is usually your machines efficiency
 * - multiplier: how many units of material in the mats list(after each unit is multiplied and rounded with coefficient) must be consumed, This is usually your print quantity
 */
/datum/component/material_container/proc/use_materials(list/mats, coefficient = 1, multiplier = 1)
	if(!mats || !length(mats))
		return FALSE

	var/amount_removed = 0
	for(var/i in mats)
		amount_removed += use_amount_mat(OPTIMAL_COST(mats[i] * coefficient) * multiplier, i)

	return amount_removed
//============================================================================================


//===========================================HIGH LEVEL=======================================

/**
 * For spawning mineral sheets at a specific location. Used by machines to output sheets.
 *
 * Arguments:
 * sheet_amt: number of sheets to extract
 * [material][datum/material]: type of sheets present in this container to extract
 * [target][atom]: drop location
 * [atom][context]: context - the atom performing the operation, this is the last argument sent in COMSIG_MATCONTAINER_SHEETS_RETRIEVED and is used mostly for silo logging
 */
/datum/component/material_container/proc/retrieve_sheets(sheet_amt, datum/material/material, atom/target = null, atom/context = parent)
	//do we support sheets of this material
	if(!material.sheet_type)
		return 0 //Add greyscale sheet handling here later
	if(!can_hold_material(material))
		return 0

	//requested amount greater than available amount or just an invalid value
	sheet_amt = min(round(materials[material] / SHEET_MATERIAL_AMOUNT), sheet_amt)
	if(sheet_amt <= 0)
		return 0
	//auto drop location
	if(!target)
		var/atom/parent_atom = parent
		target = parent_atom.drop_location()
		if(!target)
			return 0

	//eject sheets based on available amount after each iteration
	var/count = 0
	while(sheet_amt > 0)
		//don't merge yet. we need to do stuff with it first
		var/obj/item/stack/sheet/new_sheets = new material.sheet_type(target, min(sheet_amt, MAX_STACK_SIZE), FALSE)
		new_sheets.manufactured = TRUE
		count += new_sheets.amount
		//use material & deduct work needed
		use_amount_mat(new_sheets.amount * SHEET_MATERIAL_AMOUNT, material)
		sheet_amt -= new_sheets.amount
		//send signal
		SEND_SIGNAL(src, COMSIG_MATCONTAINER_SHEETS_RETRIEVED, new_sheets, context)
		//no point merging anything into an already full stack
		if(new_sheets.amount == new_sheets.max_amount)
			continue
		//now we can merge since we are done with it
		for(var/obj/item/stack/item_stack in target)
			if(item_stack == new_sheets || item_stack.type != material.sheet_type) //don't merge with self or different type
				continue
			//speed merge
			var/merge_amount = min(item_stack.amount, new_sheets.max_amount - new_sheets.get_amount())
			item_stack.use(merge_amount)
			new_sheets.add(merge_amount)
			break
	return count

/**
 * Proc to get all the materials and dump them as sheets
 *
 * Arguments:
 * - target: drop location of the sheets
 * - context: the atom which is ejecting the sheets. Used mostly in silo logging
 */
/datum/component/material_container/proc/retrieve_all(target = null, atom/context = parent)
	var/result = 0
	for(var/MAT in materials)
		result += retrieve_sheets(amount2sheet(materials[MAT]), MAT, target, context)
	return result
//============================================================================================


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
	var/list/item_materials = held_item.get_material_composition()
	if(!length(item_materials))
		return NONE
	for(var/material in item_materials)
		if(can_hold_material(material))
			continue
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "Insert"

	return CONTEXTUAL_SCREENTIP_SET

#undef MATERIAL_INSERT_ITEM_SUCCESS
