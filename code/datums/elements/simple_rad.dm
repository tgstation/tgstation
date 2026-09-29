/datum/element/simple_rad

/datum/element/simple_rad/Attach(atom/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_IRRADIATED, type)
	target.rad_glow()
	RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

	if (!isorgan(target))
		return

	var/obj/item/organ/organ = target
	if (organ.organ_flags & ORGAN_EXTERNAL)
		return

	RegisterSignal(organ, COMSIG_ORGAN_IMPLANTED, PROC_REF(rad_organ_implanted))
	RegisterSignal(organ, COMSIG_ORGAN_REMOVED, PROC_REF(rad_organ_removed))
	if(organ.owner)
		rad_organ_implanted(organ, organ.owner)

/datum/element/simple_rad/Detach(datum/source, ...)
	REMOVE_TRAIT(source, TRAIT_IRRADIATED, type)
	source.remove_filter("rad_glow")
	UnregisterSignal(source, COMSIG_COMPONENT_CLEAN_ACT)

	if (!isorgan(source))
		return ..()

	var/obj/item/organ/organ = source
	if (organ.organ_flags & ORGAN_EXTERNAL)
		return ..()

	UnregisterSignal(organ, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(organ.owner)
		rad_organ_removed(organ, organ.owner)

	return ..()

/datum/element/simple_rad/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(clean_types & CLEAN_TYPE_RADIATION)
		Detach(source)
		return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP
	return NONE

/datum/element/simple_rad/proc/rad_organ_implanted(obj/item/organ/source, mob/living/carbon/new_owner)
	SIGNAL_HANDLER

	new_owner.apply_status_effect(/datum/status_effect/grouped/has_irradiated_organs, REF(source))

/datum/element/simple_rad/proc/rad_organ_removed(obj/item/organ/source, mob/living/carbon/old_owner)
	SIGNAL_HANDLER

	old_owner.remove_status_effect(/datum/status_effect/grouped/has_irradiated_organs, REF(source))

/datum/status_effect/grouped/has_irradiated_organs
	id = "has_irradiated_organs"
	alert_type = null
	tick_interval = 2 SECONDS
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN|HEAL_TOX|HEAL_NEGATIVE_MUTATIONS|HEAL_STATUS|HEAL_REFRESH_ORGANS

/datum/status_effect/grouped/has_irradiated_organs/on_remove()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/organ/organ as anything in carbon_owner.organs)
		organ.clear_radiation()

/datum/status_effect/grouped/has_irradiated_organs/tick(seconds_between_ticks)
	if(SPT_PROB(max(0.01, length(sources) - 4), seconds_between_ticks))
		owner.make_irradiated()
