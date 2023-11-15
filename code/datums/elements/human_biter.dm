/// Allows carbons with heads to attempt to bite mobs if attacking with cuffed hands / missing arms
/datum/element/human_biter

/datum/element/human_biter/Attach(datum/target)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(try_bite))

/datum/element/human_biter/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_EARLY_UNARMED_ATTACK)

/datum/element/human_biter/proc/try_bite(mob/living/carbon/human/source, atom/target, proximity_flag, modifiers)
	SIGNAL_HANDLER

	if(!proximity_flag || !source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK) || !isliving(target))
		return NONE

	// If we can attack like normal, just go ahead and do that
	if(source.can_unarmed_attack())
		return NONE

	if(target.attack_paw(source, modifiers))
		return COMPONENT_CANCEL_ATTACK_CHAIN // bite successful!

	return COMPONENT_SKIP_ATTACK // we will fail anyways if we try to attack normally, so skip the rest
