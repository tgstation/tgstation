/// Allows you to modify an item's icon state when it is used as a prosthetic limb.
/datum/element/prosthetic_icon
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Prefix to use for the icon state of the prosthetic limb.
	var/icon_state_prefix = ""

/datum/element/prosthetic_icon/Attach(obj/item/target, icon_state_prefix)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.icon_state_prefix = icon_state_prefix

	RegisterSignal(target, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_update_icon))
	RegisterSignals(target, list(COMSIG_ITEM_USED_AS_PROSTHETIC, COMSIG_ITEM_DROPPED_FROM_PROSTHETIC), PROC_REF(update_source))
	target.update_appearance()

/datum/element/prosthetic_icon/Detach(obj/item/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ATOM_UPDATE_ICON, COMSIG_ITEM_USED_AS_PROSTHETIC, COMSIG_ITEM_DROPPED_FROM_PROSTHETIC))
	target.update_appearance()

/datum/element/prosthetic_icon/proc/on_update_icon(obj/item/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT_FROM(source, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT))
		return NONE

	source.icon_state = "[icon_state_prefix]_[source.base_icon_state]"
	return COMSIG_ATOM_NO_UPDATE_ICON_STATE

/datum/element/prosthetic_icon/proc/update_source(obj/item/source)
	SIGNAL_HANDLER
	source.update_appearance()
