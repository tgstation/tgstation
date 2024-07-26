/**
 * noticable organ element; which makes organs have a special description added to the person with the organ, if certain body zones aren't covered.
 *
 * Used for infused mutant organs
 */
/datum/element/noticable_organ
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///Shows on examining someone with an infused organ.
	var/infused_desc
	/// Which body zone has to be exposed. If none is set, this is always noticable.
	var/body_zone

/datum/element/noticable_organ/Attach(obj/item/organ/target, infused_desc, body_zone)
	. = ..()

	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE

	src.infused_desc = infused_desc
	src.body_zone = body_zone

	RegisterSignal(target, COMSIG_ORGAN_IMPLANTED, PROC_REF(enable_description))
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))
	if(target.owner)
		enable_description(target, target.owner)

/datum/element/noticable_organ/Detach(obj/item/organ/target)
	UnregisterSignal(target, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(target.owner)
		UnregisterSignal(target.owner, COMSIG_ATOM_EXAMINE)
	return ..()

/// Proc that returns true or false if the organ should show its examine check.
/datum/element/noticable_organ/proc/should_show_text(mob/living/carbon/examined)
	if(body_zone && (body_zone in examined.get_covered_body_zones()))
		return FALSE
	return TRUE

/datum/element/noticable_organ/proc/enable_description(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	RegisterSignal(receiver, COMSIG_ATOM_EXAMINE, PROC_REF(on_receiver_examine))

/datum/element/noticable_organ/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER

	UnregisterSignal(loser, COMSIG_ATOM_EXAMINE)

/datum/element/noticable_organ/proc/on_receiver_examine(mob/living/carbon/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!should_show_text(examined))
		return

	var/examine_text = REPLACE_PRONOUNS(infused_desc, examined)


	examine_list += examine_text

/**
 * Subtype of noticable organs for AI control, that will make a few more ai status checks before forking over the examine.
 */
/datum/element/noticable_organ/ai_control


/datum/element/noticable_organ/ai_control/should_show_text(mob/living/carbon/examined)
	. = ..()
	if(!.)
		return FALSE
	if(examined.ai_controller?.ai_status == AI_STATUS_ON)
		if(!examined.dna.species.ai_controlled_species)
			return TRUE
	return FALSE

/datum/element/noticable_organ/ai_control/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	Detach(target)
