/**
 * ## Mutant hands component
 *
 * This component applies to humans, and forces them to hold
 * a certain typepath item in every hand no matter what*.
 *
 * For example, zombies being forced to hold "zombie claws" - disallowing them from holding items
 * but giving them powerful weapons to infect people
 *
 * It is suggested that the item path supplied has NODROP (and likely DROPDEL),
 * but nothing's preventing you from not having that.
 *
 * If they lose or gain hands, new mutant hands will be created immediately.
 *
 * Does not override nodrop items that already exist in hand slots.
 * However if those nodrop items are lost, will immediately create a new mutant hand.
 */
/datum/component/mutant_hands
	// First come, first serve
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The item typepath that we insert into the parent's hands
	var/obj/item/mutant_hand_path
	/// Optional, a list of signals which - when recieved - results in us self terminating
	var/list/signals_which_destroy_us
	/// Used to prevent un-necessary updates, this was the length of the mob's held_items list the last time we updated
	var/last_held_items_len = -1

/datum/component/mutant_hands/Initialize(obj/item/mutant_hand_path, list/signals_which_destroy_us)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	src.mutant_hand_path = mutant_hand_path
	src.signals_which_destroy_us = signals_which_destroy_us

/datum/component/mutant_hands/RegisterWithParent()
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

	RegisterSignals(parent, list(
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_MOB_NUM_HANDS_CHANGED,
	), PROC_REF(try_reapply_hands))

	if(length(signals_which_destroy_us))
		RegisterSignals(parent, signals_which_destroy_us, PROC_REF(destroy_self))

/datum/component/mutant_hands/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_MOB_NUM_HANDS_CHANGED,
	))

	if(length(signals_which_destroy_us))
		UnregisterSignal(parent, signals_which_destroy_us)

	INVOKE_ASYNC(src, PROC_REF(remove_mutant_hands))

/**
 * Tries to give the parent mob mutant hands.
 *
 * * If a hand slot is empty, places the mutanthand type into their hand.
 * * If a hand slot is filled with a nodrop item, it will instead hook a signal onto that item to check if / when it disappears.
 * * If a hand slot is filled with a non-nodrop item, drops the item to the ground.
 * * If a hand slot is filled with a hand already, does nothing.
 */
/datum/component/mutant_hands/proc/apply_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot as anything in human_parent.held_items)
		// This slot is already a mutant hand
		if(istype(hand_slot, mutant_hand_path))
			continue
		// This slot is not empty
		// Yes the held item lists contains nulls to represent empty hands
		// Save us a cast to use as anything in the loop
		if(!isnull(hand_slot))
			if(HAS_TRAIT(hand_slot, TRAIT_NODROP))
				// There's a nodrop item in the way of putting a mutant hand in
				// We'll register some signals such that, if the item is removed at some point,
				// We can instantly jump in and replace it with a new mutant hand
				// But we need to override existing signals here - as the nodrop item could persist through multiple attempts
				RegisterSignals(hand_slot, list(COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETING), PROC_REF(on_nodrop_item_lost), override = TRUE)
				continue
			// Drop any existing non-nodrop items to the ground
			human_parent.dropItemToGround(hand_slot)

		// Put in hands has a sleep somewhere in there
		human_parent.put_in_hands(new mutant_hand_path(), del_on_fail = TRUE)

	// Record how many hands we ended up iterating over, to prevent un-necessary updates going forward
	last_held_items_len = length(human_parent.held_items)

/**
 * Removes all mutant idems from the parent's hand slots
 */
/datum/component/mutant_hands/proc/remove_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot as anything in human_parent.held_items)
		// Not a mutant hand, don't need to delete it
		if(!istype(hand_slot, mutant_hand_path))
			continue

		// Just send it to the shadow realm, this will handle unequipping and remove it for us
		qdel(hand_slot)

/**
 * Signal proc for any signals that may result in the number of hands of the parent mob changing
 *
 * If the length of the parent's hand indexes changes from our last hand application,
 * attempts to insert new  mutant hands into new slots.
 */
/datum/component/mutant_hands/proc/try_reapply_hands(datum/source)
	SIGNAL_HANDLER

	if(QDELING(src) || QDELING(parent))
		return

	// When any of these events occur, check to see if the number of held slots have changed
	// If not, then we likely don't need to attempt to apply the hands again
	// And if so, then we'll try to put new hands in
	var/mob/living/carbon/human/human_parent = parent
	if(last_held_items_len == length(human_parent.held_items))
		return

	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * Signal proc when a nodrop item is dropped or deleted from our parent mob
 *
 * After having a pesky nodrop item disappear, we should replcace the slot with a mutant hand as intended
 */
/datum/component/mutant_hands/proc/on_nodrop_item_lost(datum/source, obj/item/unequipped)
	SIGNAL_HANDLER

	UnregisterSignal(unequipped, list(COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETING))

	if(QDELING(src) || QDELING(parent))
		return
	// Just do a full re-application
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * General signal proc for when we recieve a signal that tells us to self delete
 */
/datum/component/mutant_hands/proc/destroy_self(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/**
 * Generic mutant hand type for use with the mutant hands component
 * (Well the component doesn't require you use this type, but it's here for posterity)
 *
 * Does nothing except change its icon state between left and right depending on hand slot equipped in
 * Implement var overrides and proc extension to make your hands to special things
 */
/obj/item/mutant_hand
	name = "mutant hand"
	desc = "Won't somebody give me a hand?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	base_icon_state = "bloodhand"
	item_flags = ABSTRACT | DROPDEL | HAND_ITEM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/mutant_hand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mutant_hand/visual_equipped(mob/user, slot)
	. = ..()

	if(!base_icon_state)
		return

	// Even hand indexes are right hands,
	// Odd hand indexes are left hand
	// ...But also, we swap it intentionally here,
	// so right icon is shown on the left (Because hands)
	if(user.get_held_index_of_item(src) % 2 == 1)
		icon_state = "[base_icon_state]_right"
	else
		icon_state = "[base_icon_state]_left"
