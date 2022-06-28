/datum/component/slows_when_slot_filed
	/// How much slowdown do we add?
	var/slowdown_to_apply = 1
	var/checked_slot
	var/list/things_which_apply_slowdown
	var/datum/weakref/slowing_us

/datum/component/slows_when_slot_filed/Initialize(slowdown_to_apply = 1, checked_slot, list/things_which_apply_slowdown)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!checked_slot)
		stack_trace("[type] component created without a checked_slot field.")
		return COMPONENT_INCOMPATIBLE

	src.slowdown_to_apply = slowdown_to_apply
	src.checked_slot = checked_slot

	if(islist(things_which_apply_slowdown))
		src.things_which_apply_slowdown = typecacheof(things_which_apply_slowdown)

/datum/component/slows_when_slot_filed/Destroy(force, silent)
	var/obj/item/item_parent = parent
	item_parent.slowdown = initial(item_parent.slowdown)

	slowing_us = null
	return ..()

/datum/component/slows_when_slot_filed/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)

	// The component's being attached to something held or worn by a mob.
	if(ismob(loc))
		var/mob/wearer = loc
		var/obj/item/item_parent = parent
		// Okay, the component's being attached to the correct slot, too.
		// We should register our equip signals, in that case.
		if(item_parent.slot_flags && wearer.get_item_by_slot(item_parent.slot_flags) == item_parent)
			// (Todo: replace this with just "get_slot_by_item()" when that exists.)
			register_equip_signals_on_wearer(wearer, item_parent.slot_flags)

/datum/component/slows_when_slot_filed/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)

	if(ismob(loc))
		unregister_equip_signals_from_wearer(loc)

/datum/component/slows_when_slot_filed/proc/register_equip_signals_on_wearer(mob/wearer, slot)
	var/obj/item/item_parent = parent
	// We're not equipped in the right slot, we're probably in hand or something.
	if(item_parent.slot_flags && slot && !(item_parent.slot_flags & slot))
		return

	RegisterSignal(wearer, COMSIG_MOB_EQUIPPED_ITEM, .proc/on_mob_equip_item)
	RegisterSignal(wearer, COMSIG_MOB_UNEQUIPPED_ITEM, .proc/on_mob_unequip_item)

	// We're registering the signals, but they already have an item equipped in our checked slot.
	// We probably need to update the slowdowns, in that case.
	var/obj/item/existing_equipped = wearer.get_item_by_slot(checked_slot)
	if(existing_equipped)
		on_mob_equip_item(wearer, existing_equipped, checked_slot)

/datum/component/slows_when_slot_filed/proc/unregister_equip_signals_from_wearer(mob/wearer)
	UnregisterSignal(wearer, COMSIG_MOB_EQUIPPED_ITEM)
	UnregisterSignal(wearer, COMSIG_MOB_UNEQUIPPED_ITEM)

/datum/component/slows_when_slot_filed/proc/on_equip(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER

	register_equip_signals_on_wearer(equipper, slot)

/datum/component/slows_when_slot_filed/proc/on_drop(obj/item/source, mob/dropper)
	SIGNAL_HANDLER

	unregister_equip_signals_from_wearer(dropper)

/datum/component/slows_when_slot_filed/proc/on_mob_equip_item(mob/source, obj/item/equipped, slot)
	SIGNAL_HANDLER

	if(!(checked_slot & slot))
		return

	if(length(things_which_apply_slowdown) && !is_type_in_typecache(equipped, things_which_apply_slowdown))
		return

	var/obj/item/item_parent = parent
	item_parent.slowdown = initial(item_parent.slowdown) + slowdown_to_apply
	source.update_equipment_speed_mods()
	slowing_us = WEAKREF(equipped)

/datum/component/slows_when_slot_filed/proc/on_mob_unequip_item(mob/source, obj/item/unequipped)
	SIGNAL_HANDLER

	if(!IS_WEAKREF_OF(unequipped, slowing_us))
		return

	var/obj/item/item_parent = parent
	item_parent.slowdown = initial(item_parent.slowdown)
	source.update_equipment_speed_mods()
	slowing_us = null
