/// Applied to an organ, makes it take on the appearance of an item
/// If the item <-> organ relationship is broken, the organ will be destroyed
/datum/component/arbitrary_item_organ
	/// The item our organ is representing
	var/obj/item/base_item

/datum/component/arbitrary_item_organ/Initialize(obj/item/base_item)
	if(!isorgan(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isitem(base_item))
		return COMPONENT_INCOMPATIBLE

	src.base_item = base_item

	base_item.forceMove(parent)

	var/obj/item/organ/organ = parent
	organ.organ_flags |= ORGAN_FAKE|ORGAN_PROMINENT|ORGAN_HAZARDOUS
	organ.organ_flags &= ~ORGAN_ORGANIC
	organ.apply_organ_damage(INFINITY)
	organ.name = base_item.name

	RegisterSignal(organ, COMSIG_ORGAN_ADJUST_DAMAGE, PROC_REF(break_again))
	RegisterSignal(organ, COMSIG_ORGAN_BODYPART_REMOVED, PROC_REF(organ_removed))

	RegisterSignals(base_item, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(base_item_lost))

/datum/component/arbitrary_item_organ/Destroy()
	UnregisterSignal(parent, list(COMSIG_ORGAN_ADJUST_DAMAGE, COMSIG_ORGAN_REMOVED))
	UnregisterSignal(base_item, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	base_item = null
	return ..()

/// If our internal item is deleted or removed from the organ's contents, nuke the organ
/datum/component/arbitrary_item_organ/proc/base_item_lost(obj/item/base_item)
	SIGNAL_HANDLER

	if(QDELING(parent))
		return

	qdel(parent)

/// Any attempt to heal the organ should damage cap it again
/datum/component/arbitrary_item_organ/proc/break_again(obj/item/organ/organ, damage_amount, ...)
	SIGNAL_HANDLER
	if(damage_amount < INFINITY)
		organ.apply_organ_damage(INFINITY)

/// If the organ is removed it reverts to being a normal item
/datum/component/arbitrary_item_organ/proc/organ_removed(obj/item/organ/organ, obj/item/bodypart/limb, ...)
	SIGNAL_HANDLER

	base_item.forceMove(limb.owner?.drop_location() || limb.drop_location()) // triggers qdel(organ)
