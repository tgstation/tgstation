/**
 * noticable organ element; which makes organs have a special description added to the person with the organ, if certain body zones aren't covered.
 *
 * Used for infused mutant organs
 */
/datum/element/noticable_organ
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	// "[they] [desc here]", shows on examining someone with an infused organ.
	var/infused_desc
	///Which body zone has to be exposed. If none is set, this is always noticable.
	var/body_zone

/datum/element/noticable_organ/Attach(datum/target, infused_desc, body_zone)
	. = ..()

	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE

	src.infused_desc = infused_desc
	src.body_zone = body_zone

	RegisterSignal(target, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

/datum/element/noticable_organ/Detach(obj/item/organ/target)
	UnregisterSignal(target, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(target.owner)
		UnregisterSignal(target.owner, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/element/noticable_organ/proc/on_implanted(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	RegisterSignal(receiver, COMSIG_PARENT_EXAMINE, PROC_REF(on_receiver_examine))

/datum/element/noticable_organ/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER

	UnregisterSignal(loser, COMSIG_PARENT_EXAMINE)

/datum/element/noticable_organ/proc/on_receiver_examine(mob/living/carbon/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/list/covered = examined.get_covered_body_zones()
	if(!body_zone || (body_zone in covered))
		return
	examine_list += span_notice("[examined.p_they(TRUE)] [infused_desc]")
