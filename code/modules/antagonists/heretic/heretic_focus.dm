/// Heretic focus element, simple element for making an item a heretic focus,
/// allowing heretics to cast advanced spells (examine message included).
/datum/element/heretic_focus

/datum/element/heretic_focus/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

	var/obj/item/item_target = target
	// If our loc is a mob, it's possible we already have it equippied
	if(ismob(item_target.loc))
		var/mob/wearer = item_target.loc
		if(!item_target.slot_flags || wearer.get_item_by_slot(item_target.slot_flags) == item_target)
			ADD_TRAIT(wearer, TRAIT_ALLOW_HERETIC_CASTING, ELEMENT_TRAIT(target))

/datum/element/heretic_focus/Detach(obj/item/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(isliving(source.loc))
		REMOVE_TRAIT(source.loc, TRAIT_ALLOW_HERETIC_CASTING, ELEMENT_TRAIT(source))

/**
 * Signal proc for [COMSIG_ATOM_EXAMINE].
 * Let's the examiner see that this item is a heretic focus
 */
/datum/element/heretic_focus/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!IS_HERETIC(user))
		return

	examine_list += span_notice("Allows you to cast advanced heretic spells when worn.")

/**
 * Signal proc for [COMSIG_ITEM_EQUIPPED].
 * When equipped in a right slot, give user our trait
 */
/datum/element/heretic_focus/proc/on_equip(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!IS_HERETIC(user))
		return

	if(!(source.slot_flags & slot))
		return

	ADD_TRAIT(user, TRAIT_ALLOW_HERETIC_CASTING, ELEMENT_TRAIT(source))

/**
 * Signal proc for [COMSIG_ITEM_DROPPED].
 * Remove our trait when we drop (unequip) our item
 */
/datum/element/heretic_focus/proc/on_drop(obj/item/source, mob/user)
	SIGNAL_HANDLER

	REMOVE_TRAIT(user, TRAIT_ALLOW_HERETIC_CASTING, ELEMENT_TRAIT(source))
