/// Allows mobs with this component to have all of their limbs operated on without needing drapes
/datum/component/free_operation
	dupe_mode = COMPONENT_DUPE_SOURCES

/datum/component/free_operation/Initialize(check)
	if (!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	ADD_TRAIT(parent, TRAIT_READY_TO_OPERATE, REF(src))
	var/mob/living/carbon/owner = parent
	for (var/obj/item/bodypart/limb as anything in owner.bodyparts)
		ADD_TRAIT(limb, TRAIT_READY_TO_OPERATE, REF(src))

/datum/component/free_operation/Destroy(force)
	REMOVE_TRAIT(parent, TRAIT_READY_TO_OPERATE, REF(src))
	var/mob/living/carbon/owner = parent
	for (var/obj/item/bodypart/limb as anything in owner.bodyparts)
		REMOVE_TRAIT(limb, TRAIT_READY_TO_OPERATE, REF(src))
	return ..()

/datum/component/free_operation/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CARBON_ATTACH_LIMB, PROC_REF(flag_limb))
	RegisterSignal(parent, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(unflag_limb))

/datum/component/free_operation/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))

/datum/component/free_operation/proc/flag_limb(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	ADD_TRAIT(limb, TRAIT_READY_TO_OPERATE, REF(src))

/datum/component/free_operation/proc/unflag_limb(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	REMOVE_TRAIT(limb, TRAIT_READY_TO_OPERATE, REF(src))
