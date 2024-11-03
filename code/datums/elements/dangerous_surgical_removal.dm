/**
 * ## DANGEROUS ORGAN REMOVAL ELEMENT
 *
 * Makes the organ corrode instantly when removed (potentially surgically!).
 * That's about it.
 */
/datum/element/dangerous_organ_removal
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// whether the removal needs to be surgical for it to explode. If you're adding more modes, just pass the signal directly instead
	var/surgical

/datum/element/dangerous_organ_removal/Attach(datum/target, surgical = FALSE)
	. = ..()
	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE

	src.surgical = surgical

	if(surgical)
		RegisterSignal(target, COMSIG_ORGAN_SURGICALLY_REMOVED, PROC_REF(on_removal))
	else
		RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removal))

/datum/element/dangerous_organ_removal/Detach(datum/source)
	. = ..()

	UnregisterSignal(source, list(COMSIG_ORGAN_SURGICALLY_REMOVED, COMSIG_ORGAN_REMOVED))

/datum/element/dangerous_organ_removal/proc/on_removal(obj/item/organ/source, mob/living/user, mob/living/carbon/old_owner, target_zone, obj/item/tool)
	SIGNAL_HANDLER
	if(surgical && source.organ_flags & (ORGAN_FAILING|ORGAN_EMP))
		return
	if(user?.Adjacent(source))
		source.audible_message("[source] corrosive acid explodes on [user]'s face!")
		user.take_bodypart_damage(15)
	else
		source.audible_message("[source] corrodes into tiny pieces!")
	source.AddComponent(/datum/component/acid, MOVABLE_ACID_DAMAGE_MAX, MOB_ACID_VOLUME_MAX, GLOB.acid_overlay, /particles/acid, turf_acid_ignores_mobs = TRUE)
	qdel(source)
