/// --Food storage component--
/// This component lets you slide one item into large foods, such as bread, cheese wheels, or cakes.
/// Consuming food storages with an item inside can cause unique interactions, such as eating glass shards.

/datum/component/food_storage
	/// Reference to what we have in our food.
	var/obj/item/stored_item
	/// The amount of volume the food has on creation - Used for probabilities
	var/initial_volume = 10
	/// Minimum size items that can be inserted
	var/minimum_weight_class = WEIGHT_CLASS_SMALL
	/// What are the odds we bite into the stored item?
	var/bad_chance_of_discovery = 0
	/// What are the odds we see the stored item before we bite it?
	var/good_chance_of_discovery = 100
	/// The stored item was found out somehow.
	var/discovered = FALSE

/datum/component/food_storage/Initialize(_minimum_weight_class = WEIGHT_CLASS_SMALL, _bad_chance = 0, _good_chance = 100)

	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, PROC_REF(try_inserting_item))
	RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(try_removing_item))
	RegisterSignal(parent, COMSIG_FOOD_EATEN, PROC_REF(consume_food_storage))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))


	var/atom/food = parent
	initial_volume = food.reagents.total_volume

	minimum_weight_class = _minimum_weight_class
	bad_chance_of_discovery = _bad_chance
	good_chance_of_discovery = _good_chance

	food.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/food_storage/Destroy(force)
	if(stored_item)
		stored_item.forceMove(stored_item.drop_location())
		stored_item.dropped()
		stored_item = null
	. = ..()

/** Begins the process of inserted an item.
 *
 * Clicking on the food storage with an item will begin a do_after, which if successful inserts the item.
 *
 * Arguments
 * inserted_item - the item being placed into the food
 * user - the person inserting the item
 */
/datum/component/food_storage/proc/try_inserting_item(datum/source, mob/living/user, obj/item/inserted_item, list/modifiers)
	SIGNAL_HANDLER

	// No matryoshka-ing food storage
	if(istype(inserted_item, /obj/item/storage) || IS_EDIBLE(inserted_item))
		return NONE

	//Harm intent will bypass inserting for injecting food with syringes and such
	if(user.combat_mode)
		return NONE

	if(inserted_item.w_class > minimum_weight_class)
		to_chat(user, span_warning("\The [inserted_item.name] won't fit in \the [parent]."))
		return ITEM_INTERACT_BLOCKING

	if(!QDELETED(stored_item))
		to_chat(user, span_warning("There's something in \the [parent]."))
		return ITEM_INTERACT_BLOCKING

	if(HAS_TRAIT(inserted_item, TRAIT_NODROP))
		to_chat(user, span_warning("\the [inserted_item] is stuck to your hand, you can't put into \the [parent]!"))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user.name] begins inserting [inserted_item.name] into \the [parent]."), \
					span_notice("You start to insert the [inserted_item.name] into \the [parent]."))

	INVOKE_ASYNC(src, PROC_REF(insert_item), inserted_item, user)
	return ITEM_INTERACT_SUCCESS

/** Begins the process of attempting to remove the stored item.
 *
 * Clicking on food storage on grab intent will begin a do_after, which if successful removes the stored_item.
 *
 * Arguments
 * user - the person removing the item.
 */
/datum/component/food_storage/proc/try_removing_item(datum/source, mob/user)
	SIGNAL_HANDLER

	var/atom/food = parent

	if(QDELETED(stored_item))
		return CLICK_ACTION_BLOCKING

	if(!food.can_interact(user))
		return CLICK_ACTION_BLOCKING

	user.visible_message(span_notice("[user.name] begins tearing at \the [parent]."), \
					span_notice("You start to rip into \the [parent]."))

	INVOKE_ASYNC(src, PROC_REF(begin_remove_item), user)
	return CLICK_ACTION_SUCCESS

/** Inserts the item into the food, after a do_after.
 *
 * Arguments
 * inserted_item - The item being inserted.
 * user - the person inserting the item.
 */
/datum/component/food_storage/proc/insert_item(obj/item/inserted_item, mob/user)
	if(!do_after(user, 1.5 SECONDS, target = parent))
		return

	var/atom/food = parent
	to_chat(user, span_notice("You slip [inserted_item.name] inside \the [parent]."))
	inserted_item.forceMove(food)
	user.log_message("inserted [inserted_item] into [parent].", LOG_ATTACK)
	food.add_fingerprint(user)
	inserted_item.add_fingerprint(user)

	stored_item = inserted_item

/** Removes the item from the food, after a do_after.
 *
 * Arguments
 * user - person removing the item.
 */
/datum/component/food_storage/proc/begin_remove_item(mob/user)
	if(do_after(user, 10 SECONDS, target = parent))
		remove_item(user)

/**
 * Removes the stored item, putting it in user's hands or on the ground, then updates the reference.
 */
/datum/component/food_storage/proc/remove_item(mob/user)
	if(user.put_in_hands(stored_item))
		user.visible_message(span_warning("[user.name] slowly pulls [stored_item.name] out of \the [parent]."), \
							span_warning("You slowly pull [stored_item.name] out of \the [parent]."))
	else
		stored_item.dropped()
		stored_item.visible_message(span_warning("[stored_item.name] falls out of \the [parent]."))

	update_stored_item()

/** Checks for stored items when the food is eaten.
 *
 * If the food is eaten while an item is stored in it, calculates the odds that the item will be found.
 * Then, if the item is found before being bitten, the item is removed.
 * If the item is found by biting into it, calls on_accidental_consumption on the stored item.
 * Afterwards, removes the item from the food if it was discovered.
 *
 * Arguments
 * target - person doing the eating (can be the same as user)
 * user - person causing the eating to happen
 * bitecount - how many times the current food has been bitten
 * bitesize - how large bties are for this food
 */
/datum/component/food_storage/proc/consume_food_storage(datum/source, mob/living/target, mob/living/user, bitecount, bitesize)
	SIGNAL_HANDLER

	if(QDELETED(stored_item)) //if the stored item was deleted/null...
		if(!update_stored_item()) //check if there's a replacement item
			return

	/// Chance of biting the held item = amount of bites / (intitial reagents / reagents per bite) * 100
	bad_chance_of_discovery = (bitecount / (initial_volume / bitesize))*100
	/// Chance of finding the held item = bad chance - 50
	good_chance_of_discovery = bad_chance_of_discovery - 50

	if(prob(good_chance_of_discovery)) //finding the item, without biting it
		discovered = TRUE
		to_chat(target, span_warning("It feels like there's something in \the [parent]...!"))

	else if(prob(bad_chance_of_discovery)) //finding the item, BY biting it
		user.log_message("just fed [key_name(target)] \a [stored_item] which was hidden in [parent].", LOG_ATTACK)
		discovered = stored_item.on_accidental_consumption(target, user, parent)
		update_stored_item() //make sure if the item was changed, the reference changes as well

	if(!QDELETED(stored_item) && discovered)
		INVOKE_ASYNC(src, PROC_REF(remove_item), user)

/** Updates the reference of the stored item.
 *
 * Checks the food's contents for if an alternate item was placed into the food.
 * If there is an alternate item, updates the reference to the new item.
 * If there isn't, updates the reference to null.
 *
 * Returns FALSE if the ref is nulled, or TRUE is another item replaced it.
 */
/datum/component/food_storage/proc/update_stored_item()
	var/atom/food = parent
	if(!food?.contents.len) //if there's no items in the food or food is deleted somehow
		stored_item = null
		return FALSE

	for(var/obj/item/i in food.contents) //search the food's contents for a replacement item
		if(IS_EDIBLE(i))
			continue
		if(QDELETED(i))
			continue

		stored_item = i //we found something to replace it
		return TRUE

	//if there's nothing else in the food, or we found nothing valid
	stored_item = null
	return FALSE

/**
 * Adds context sensitivy directly to the processable file for screentips
 * Arguments:
 * * source - refers to item that will display its screentip
 * * context - refers to, in this case, an item that can be inserted into another item
 * * held_item - refers to item in user's hand, typically the one that will be inserted into the food item
 * * user - refers to user who will see the screentip when the proper context and tool are there
 */

/datum/component/food_storage/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER
	. = NONE

	if(isnull(held_item) || held_item == source)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove embedded item (if any)"
		. = CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item) && held_item.w_class <= WEIGHT_CLASS_SMALL && held_item != source && !IS_EDIBLE(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Embed item"
		. = CONTEXTUAL_SCREENTIP_SET

	return .
