/// Offsets parent's worn overlay based on their wearer's taur body.
/datum/component/taur_clothing_offset

/datum/component/taur_clothing_offset/RegisterWithParent()
	. = ..()

	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_GET_WORN_OVERLAYS, PROC_REF(modify_overlays))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(parent_equipped))

/datum/component/taur_clothing_offset/UnregisterFromParent()
	. = ..()

	UnregisterSignal(parent, list(COMSIG_ITEM_GET_WORN_OVERLAYS, COMSIG_ITEM_EQUIPPED))

/// Signal handler for COMSIG_ITEM_GET_WORN_OVERLAYS. Offsets parent's worn overlay based on their wearer's taur body.
/datum/component/taur_clothing_offset/proc/modify_overlays(obj/item/signal_source, list/overlays, mutable_appearance/standing, isinhands, icon_file)
	SIGNAL_HANDLER

	if (!iscarbon(signal_source.loc))
		return

	if (isinhands)
		return

	var/mob/living/carbon/target_carbon = signal_source.loc
	var/obj/item/organ/taur_body/taur_body = target_carbon.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
	if (!istype(taur_body))
		return
	var/icon_dir = target_carbon.dir
	if(ISDIAGONALDIR(icon_dir))
		icon_dir &= ~(NORTH | SOUTH)
	var/offset = taur_body.taur_specific_clothing_y_offsets?["[icon_dir]"]
	if (!offset)
		return
	standing.pixel_y += offset

/// Signal handler for COMSIG_ITEM_EQUIPPED. Handles registering signals.
/datum/component/taur_clothing_offset/proc/parent_equipped(datum/signal_source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (ishuman(equipper) && !(equipper.get_slot_by_item(parent) & (ITEM_SLOT_HANDS|ITEM_SLOT_POCKETS)))
		RegisterSignal(equipper, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(mob_unequipped_item))
		RegisterSignal(equipper, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(wearer_dir_changed))

/// Signal handler for COMSIG_MOB_UNEQUIPPED_ITEM. Handles unregistering signals.
/datum/component/taur_clothing_offset/proc/mob_unequipped_item(mob/signal_source, obj/item/item, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	if (item == parent)
		UnregisterSignal(signal_source, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_ATOM_POST_DIR_CHANGE))

/// Signal handler for COMSIG_ATOM_POST_DIR_CHANGE. Handles updating the offset based on dir.
/datum/component/taur_clothing_offset/proc/wearer_dir_changed(mob/living/carbon/human/signal_source, old_dir, new_dir)
	SIGNAL_HANDLER

	var/obj/item/organ/taur_body/taur_body = signal_source.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
	if (isnull(taur_body))
		return

	if(ISDIAGONALDIR(new_dir))
		new_dir &= ~(NORTH | SOUTH) //remove diagonal for lookup, matching how directional player sprites are selected
	if(ISDIAGONALDIR(old_dir))
		old_dir &= ~(NORTH | SOUTH)
	if(new_dir == old_dir)
		return

	var/obj/item/item_parent = parent
	if (taur_body.taur_specific_clothing_y_offsets?["[new_dir]"] || taur_body.taur_specific_clothing_y_offsets?["[old_dir]"]) // discounts null and 0
		// if the last dir had a offset, we need to reset if the new dir has NO offset
		signal_source.update_clothing(item_parent.slot_flags)
