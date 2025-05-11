/// Allows the attached item to enable saddle mechanics on the mob wearing it.
/datum/component/carbon_saddle
	/// The piggyback flags to apply to any mob that wears parent.
	var/saddle_flags = RIDER_NEEDS_ARM|RIDING_TAUR

/datum/component/carbon_saddle/Initialize(saddle_flags)
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if (!isnull(saddle_flags))
		src.saddle_flags = saddle_flags

/datum/component/carbon_saddle/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_POST_EQUIPPED, PROC_REF(parent_equipped))
	RegisterSignal(parent, COMSIG_ITEM_MOB_CAN_EQUIP, PROC_REF(parent_can_equip))

/datum/component/carbon_saddle/UnregisterFromParent()
	var/obj/item/item_parent = parent
	UnregisterSignal(item_parent, COMSIG_ITEM_EQUIPPED)

/// Signal handler for COMSIG_ITEM_POST_EQUIPPED. Handles registering signals and traits on the equipper.
/datum/component/carbon_saddle/proc/parent_equipped(datum/signal_source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (!isliving(equipper) || (slot & (ITEM_SLOT_HANDS|ITEM_SLOT_POCKETS)))
		return
	var/mob/living/living_equipper = equipper

	RegisterSignal(living_equipper, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(mob_unequipped_item))
	RegisterSignal(living_equipper, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(wearer_lost_organ))
	RegisterSignal(living_equipper, COMSIG_HUMAN_SADDLE_RIDE_ATTEMPT, PROC_REF(wearer_ridden))

	ADD_TRAIT(living_equipper, TRAIT_SADDLED, REF(src))

/// Signal handler for COMSIG_MOB_UNEQUIPPED_ITEM.
/datum/component/carbon_saddle/proc/mob_unequipped_item(mob/signal_source, obj/item/item, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	if (item == parent)
		mob_unequipped_parent(signal_source)

/// Called when our parent is inequipped. Handles unsetting signals and traits.
/datum/component/carbon_saddle/proc/mob_unequipped_parent(mob/target)
	UnregisterSignal(target, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_CARBON_LOSE_ORGAN, COMSIG_HUMAN_SADDLE_RIDE_ATTEMPT))
	REMOVE_TRAIT(target, TRAIT_SADDLED, REF(src))

/// Signal handler for COMSIG_CARBON_LOSE_ORGAN. Handles unequipping if the requisite organ is removed.
/datum/component/carbon_saddle/proc/wearer_lost_organ(mob/living/carbon/signal_source, obj/item/organ/lost)
	SIGNAL_HANDLER

	if (!wearer_has_requisite_organ(signal_source))
		var/obj/item/item_parent = parent
		var/atom/move_target = get_turf(signal_source)
		signal_source.temporarilyRemoveItemFromInventory(item_parent, TRUE, newloc = move_target)
		item_parent.forceMove(move_target) // force unequip

/// Signal handler for COMSIG_HUMAN_SADDLE_RIDE_ATTEMPT. Returns saddle_flags into the signal bitfield.
/datum/component/carbon_saddle/proc/wearer_ridden(mob/living/carbon/human/wearer, mob/living/carbon/rider)
	SIGNAL_HANDLER

	return saddle_flags

/// Signal handler for COMSIG_ITEM_MOB_CAN_EQUIP. If equipped into a non-hands and pockets slot, returns COMPONENT_ITEM_CANT_EQUIP if our owner doesnt have our required organ.
/datum/component/carbon_saddle/proc/parent_can_equip(obj/item/signal_source, mob/living/target, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	SIGNAL_HANDLER

	if (slot & (ITEM_SLOT_HANDS|ITEM_SLOT_POCKETS))
		return

	if (!wearer_has_requisite_organ(target))
		return COMPONENT_ITEM_CANT_EQUIP

/// Determines if our wearer, target, has our required organ.
/datum/component/carbon_saddle/proc/wearer_has_requisite_organ(mob/living/carbon/target)
	if (!istype(target))
		return TRUE
	var/obj/item/organ/taur_body/taur_body = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAUR)
	return istype(taur_body) && taur_body.can_use_saddle
