/// Give to a human or other dextrous mob to have them only be able to pick up and drop items, and not use them on anything
/datum/element/pick_and_drop_only
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/pick_and_drop_only/Attach(datum/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(on_picked_up))

/datum/element/pick_and_drop_only/proc/on_picked_up(mob/living/liver, obj/item/item)
	SIGNAL_HANDLER

	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

	RegisterSignals(item, list(COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_SECONDARY,
		COMSIG_ITEM_ATTACK_ATOM,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK_SELF_SECONDARY,
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
		COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
		), \
	PROC_REF(on_item_use))

/datum/element/pick_and_drop_only/proc/on_dropped(obj/item/item, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(item, list(
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_SECONDARY,
		COMSIG_ITEM_ATTACK_ATOM,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK_SELF_SECONDARY,
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
		COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY,
	))

/datum/element/pick_and_drop_only/proc/on_item_use()
	SIGNAL_HANDLER
	// CANCEL EVERYTHING, WAHAHAHA!!
	return COMPONENT_CANCEL_ATTACK_CHAIN
