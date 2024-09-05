// Any item with this component can have its storage accessed by alt clicking the wearer.
/datum/component/accessable_storage

/datum/component/accessable_storage/Initialize()
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/accessable_storage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(parent_equipped))
	RegisterSignal(parent, COMSIG_ATOM_STORED_ITEM, PROC_REF(parent_stored_item))
	RegisterSignal(parent, COMSIG_ATOM_REMOVED_ITEM, PROC_REF(parent_removed_item))

/datum/component/accessable_storage/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_STORED_ITEM, COMSIG_ATOM_REMOVED_ITEM))

/datum/component/accessable_storage/organ

/datum/component/accessable_storage/organ/Initialize()
	. = ..()
	var/obj/item/organ/organ_target = parent
	if(!isorgan(organ_target))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(organ_target, COMSIG_ORGAN_IMPLANTED, PROC_REF(parent_equipped))

/datum/component/accessable_storage/organ/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_STORED_ITEM, PROC_REF(parent_stored_item))
	RegisterSignal(parent, COMSIG_ATOM_REMOVED_ITEM, PROC_REF(parent_removed_item))

/datum/component/accessable_storage/organ/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_STORED_ITEM, COMSIG_ATOM_REMOVED_ITEM))

/// Signal handler for COMSIG_ITEM_EQUIPPED. Handles registering signals.
/datum/component/accessable_storage/proc/parent_equipped(datum/signal_source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (isliving(equipper) && !(equipper.get_slot_by_item(parent) & (ITEM_SLOT_HANDS|ITEM_SLOT_POCKETS)))
		RegisterSignal(equipper, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(mob_unequipped_item), override = TRUE)
		RegisterSignal(equipper, COMSIG_CLICK_ALT, PROC_REF(mob_alt_clicked_on))

/// Signal handler for COMSIG_CLICK_ALT. Handles the actual opening of storage.
/datum/component/accessable_storage/proc/mob_alt_clicked_on(mob/signal_source, mob/clicker)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	item_parent.atom_storage?.open_storage(clicker, signal_source)
	animate_target(signal_source)
	return CLICK_ACTION_SUCCESS

/// Signal handler for COMSIG_MOB_UNEQUIPPED_ITEM. Handles unregistering signals.
/datum/component/accessable_storage/proc/mob_unequipped_item(mob/signal_source, obj/item/item, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	if (item == parent)
		UnregisterSignal(signal_source, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_CLICK_ALT))

/// Signal handler for COMSIG_ATOM_STORED_ITEM. Handles animating our parent's wearer.
/datum/component/accessable_storage/proc/parent_stored_item(obj/item/signal_source, obj/item/inserted, mob/user, force)
	SIGNAL_HANDLER

	if(isorgan(signal_source))
		var/obj/item/organ/visible_organ = signal_source
		RegisterSignal(visible_organ.owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_receiver_examine))
	if (isliving(signal_source.loc))
		animate_target(signal_source.loc)

/// Signal handler for COMSIG_ATOM_REMOVED_ITEM. Handles animating our parent's wearer.
/datum/component/accessable_storage/proc/parent_removed_item(obj/item/signal_source, obj/item/thing, atom/remove_to_loc, silent)
	SIGNAL_HANDLER

	if(isorgan(signal_source))
		var/obj/item/organ/visible_organ = signal_source
		UnregisterSignal(visible_organ.owner, COMSIG_ATOM_EXAMINE)
	if (isliving(signal_source.loc))
		animate_target(signal_source.loc)

/// Gives a spiffy animation to the target to represent opening and closing. Copy pasted from storage.dm, please change if that proc ever changes
/datum/component/accessable_storage/proc/animate_target(atom/target = parent)
	var/matrix/old_matrix = target.transform
	animate(target, time = 1.5, loop = 0, transform = target.transform.Scale(1.07, 0.9))
	animate(time = 2, transform = old_matrix)

/datum/component/accessable_storage/proc/on_receiver_examine(mob/living/carbon/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/organ/visible_organ = parent
	var/examine_text = span_notice("[user.p_Theyre()] holding [icon2html(visible_organ.contents[1], examined)] a <b>[visible_organ.contents[1].name]</b> with [user.p_their()] tail.")

	examine_list += examine_text
