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
	var/obj/item/mutant_hand_path = /obj/item/mutant_hand

/datum/component/mutant_hands/Initialize(obj/item/mutant_hand_path = /obj/item/mutant_hand)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	src.mutant_hand_path = mutant_hand_path

/datum/component/mutant_hands/RegisterWithParent()
	// Give them a hand before registering ANYTHING just so it's clean
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

	RegisterSignals(parent, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_CARBON_POST_REMOVE_LIMB), PROC_REF(try_reapply_hands))
	RegisterSignal(parent, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(mob_equipped_item))
	RegisterSignal(parent, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(mob_dropped_item))

/datum/component/mutant_hands/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CARBON_POST_ATTACH_LIMB,
		COMSIG_CARBON_POST_REMOVE_LIMB,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_UNEQUIPPED_ITEM,
	))

	// Remove all their hands after unregistering everything so they don't return
	INVOKE_ASYNC(src, PROC_REF(remove_mutant_hands))

/**
 * Tries to give the parent mob mutant hands.
 *
 * * If a hand slot is empty, places the mutanthand type into their hand.
 * * If a hand slot is filled with a nodrop item, it will do nothing.
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
		// It saves us a /item cast by using as anything in the loop
		if(!isnull(hand_slot))
			if(HAS_TRAIT(hand_slot, TRAIT_NODROP) || (hand_slot.item_flags & ABSTRACT))
				// There's a nodrop / abstract item in the way of putting a mutant hand in
				// It can stay, for now, but if it gets dropped / unequipped we'll swoop in to replace the slot
				continue
			// Drop any existing non-nodrop items to the ground
			human_parent.dropItemToGround(hand_slot)

		// Put in hands has a sleep somewhere in there
		human_parent.put_in_hands(new mutant_hand_path(), del_on_fail = TRUE)

/**
 * Removes all mutant idems from the parent's hand slots
 */
/datum/component/mutant_hands/proc/remove_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot in human_parent.held_items)
		// Not a mutant hand, don't need to delete it
		if(!istype(hand_slot, mutant_hand_path))
			continue

		// Just send it to the shadow realm, this will handle unequipping and remove it for us
		qdel(hand_slot)

/**
 * Signal proc for any signals that may result in the number of hands of the parent mob changing
 *
 * Always try to re-insert mutanthands if we gain or lose hands
 */
/datum/component/mutant_hands/proc/try_reapply_hands(datum/source)
	SIGNAL_HANDLER

	if(QDELING(src) || QDELING(parent))
		return

	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * Signal proc for [COMSIG_MOB_EQUIPPED_ITEM]
 *
 * This is a failsafe - the mob managed to pick up something that isn't a mutant hand
 */
/datum/component/mutant_hands/proc/mob_equipped_item(mob/living/carbon/human/source, obj/item/thing, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS)) // Who cares
		return

	if(istype(thing, mutant_hand_path)) // This is definitely meant to be here
		return

	if(HAS_TRAIT(thing, TRAIT_NODROP) || (thing.item_flags & ABSTRACT)) // This is meant to be here
		return

	// We equipped something to hands that wasn't a mutant hand, and wasn't abstract!
	// This means they're meant to have a mutant hand. So help them out.
	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * Signal proc for [COMSIG_MOB_UNEQUIPPED_ITEM]
 *
 * This is another failsafe - the mob dropped something, maybe from their hands, so try to re-equip
 */
/datum/component/mutant_hands/proc/mob_dropped_item(mob/living/carbon/human/source, obj/item/thing)
	SIGNAL_HANDLER

	if(QDELING(src) || QDELING(parent))
		return

	if(null in source.held_items)
		INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/**
 * Generic mutant hand type for use with the mutant hands component
 * (Technically speaking, the component doesn't require you use this type. But it's here for posterity)
 *
 * Implements nothing except changing its icon state between left and right depending on hand slot equipped in
 */
/obj/item/mutant_hand
	name = "mutant hand"
	desc = "Won't somebody give me a hand?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	base_icon_state = "bloodhand"
	icon_angle = 90
	item_flags = ABSTRACT | DROPDEL | HAND_ITEM
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/mutant_hand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/mutant_hand/visual_equipped(mob/user, slot)
	. = ..()

	if(!base_icon_state)
		return

	// We swap it intentionally here,
	// so right icon is shown on the left (Because hands)
	if(IS_LEFT_INDEX(user.get_held_index_of_item(src)))
		icon_state = "[base_icon_state]_right"
	else
		icon_state = "[base_icon_state]_left"
