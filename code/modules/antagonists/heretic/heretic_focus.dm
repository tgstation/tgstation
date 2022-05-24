/// Heretic focus element, simple element for making an item a heretic focus,
/// allowing heretics to cast advanced spells (examine message included).
/datum/element/heretic_focus

/datum/element/heretic_focus/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/on_drop)

/datum/element/heretic_focus/Detach(obj/item/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(isliving(source.loc))
		REMOVE_TRAIT(source.loc, TRAIT_ALLOW_HERETIC_CASTING, ELEMENT_TRAIT(source))

/**
 * Signal proc for [COMSIG_PARENT_EXAMINE].
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
