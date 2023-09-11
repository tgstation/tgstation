/// Item cannot be swung unless wielded or transformed.
/datum/element/active_swing

/datum/element/active_swing/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_ATTACK_STYLE_CHECK, PROC_REF(check_wield))

/datum/element/active_swing/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_ATTACK_STYLE_CHECK)

/datum/element/active_swing/proc/check_wield(obj/item/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_WIELDED) || HAS_TRAIT(source, TRAIT_TRANSFORM_ACTIVE))
		return NONE
	return ATTACK_SWING_CANCEL
