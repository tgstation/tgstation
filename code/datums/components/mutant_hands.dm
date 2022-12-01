/datum/component/mutant_hands
	// First come, first serve
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/signals_which_destroy_us
	var/mutant_hand_path
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
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_NUM_HANDS_CHANGED,
		COMSIG_MOB_UNEQUIPPED_ITEM,
	), PROC_REF(try_reapply_hands))

	if(length(signals_which_destroy_us))
		RegisterSignals(parent, signals_which_destroy_us, PROC_REF(destroy_self))

/datum/component/mutant_hands/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CARBON_ATTACH_LIMB,
		COMSIG_CARBON_REMOVE_LIMB,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_NUM_HANDS_CHANGED,
		COMSIG_MOB_UNEQUIPPED_ITEM,
	))

	if(length(signals_which_destroy_us))
		UnregisterSignal(parent, signals_which_destroy_us)

/datum/component/mutant_hands/proc/apply_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot as anything in human_parent.held_items)
		if(istype(hand_slot, mutant_hand_path))
			continue

		if(!isnull(hand_slot))
			if(HAS_TRAIT(hand_slot, TRAIT_NODROP))
				continue
			human_parent.dropItemToGround(hand_slot)

		human_parent.put_in_hands(new mutant_hand_path(), del_on_fail = TRUE)

	last_held_items_len = length(human_parent.held_items)

/datum/component/mutant_hands/proc/remove_mutant_hands()
	var/mob/living/carbon/human/human_parent = parent
	for(var/obj/item/hand_slot as anything in human_parent.held_items)
		if(!istype(hand_slot, mutant_hand_path))
			continue

		qdel(hand_slot)

/datum/component/mutant_hands/proc/try_reapply_hands(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_parent = parent
	if(last_held_items_len == length(human_parent.held_items))
		return

	INVOKE_ASYNC(src, PROC_REF(apply_mutant_hands))

/datum/component/mutant_hands/proc/destroy_self(datum/source)
	SIGNAL_HANDLER

	qdel(src)
