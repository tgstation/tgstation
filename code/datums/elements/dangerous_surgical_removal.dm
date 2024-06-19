/**
 * ## DANGEROUS SURGICAL REMOVAL ELEMENT
 *
 * Makes the organ explode when removed surgically.
 * That's about it.
 */
/datum/element/dangerous_surgical_removal

/datum/element/dangerous_surgical_removal/Attach(datum/target)
	. = ..()
	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ORGAN_SURGICALLY_REMOVED, PROC_REF(on_surgical_removal))

/datum/element/dangerous_surgical_removal/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ORGAN_SURGICALLY_REMOVED)

/datum/element/dangerous_surgical_removal/proc/on_surgical_removal(obj/item/organ/source, mob/living/user, mob/living/carbon/old_owner, target_zone, obj/item/tool)
	SIGNAL_HANDLER
	if(source.organ_flags & (ORGAN_FAILING|ORGAN_EMP))
		return
	if(user?.Adjacent(source))
		source.audible_message("[source] explodes on [user]'s face!")
		user.take_bodypart_damage(15)
	else
		source.audible_message("[source] explodes into tiny pieces!")
	explosion(source, light_impact_range = 1, explosion_cause = source)
	qdel(source)
