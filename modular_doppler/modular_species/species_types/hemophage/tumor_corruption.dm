/// Element that handles spreading the Hemophages' pulsating tumor corruption
/// to applicable organs, so that they can be properly corrupted, even if they
/// weren't roundstart-corrupted organs.
/datum/element/tumor_corruption


/datum/element/tumor_corruption/Attach(datum/target)
	. = ..()

	if(.)
		return

	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	handle_organ_corruption_on_existing_organs(target)
	RegisterSignal(target, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(try_corrupt_new_organ))


/datum/element/tumor_corruption/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_CARBON_GAIN_ORGAN)


/**
 * Handles corrupting already-existing organs upon having the tumor be inserted in the mob.
 */
/datum/element/tumor_corruption/proc/handle_organ_corruption_on_existing_organs(mob/living/carbon/organ_enjoyer)
	var/obj/item/organ/liver/liver = organ_enjoyer.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && !(liver.organ_flags & ORGAN_TUMOR_CORRUPTED))
		liver.AddComponent(/datum/component/organ_corruption/liver)

	var/obj/item/organ/lungs/lungs = organ_enjoyer.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(lungs && !(lungs.organ_flags & ORGAN_TUMOR_CORRUPTED))
		lungs.AddComponent(/datum/component/organ_corruption/lungs)

	var/obj/item/organ/stomach/stomach = organ_enjoyer.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(stomach && !(stomach.organ_flags & ORGAN_TUMOR_CORRUPTED))
		stomach.AddComponent(/datum/component/organ_corruption/stomach)

	var/obj/item/organ/tongue/tongue = organ_enjoyer.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue && !(tongue.organ_flags & ORGAN_TUMOR_CORRUPTED))
		tongue.AddComponent(/datum/component/organ_corruption/tongue)


/**
 * Handles corrupting any new organ that's inserted into the affected mob, if needed.
 */
/datum/element/tumor_corruption/proc/try_corrupt_new_organ(mob/living/carbon/receiver, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	var/static/list/corruptable_organ_slots = list(
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_TONGUE,
	)

	if(!(new_organ.slot in corruptable_organ_slots))
		return

	if(new_organ.organ_flags & ORGAN_TUMOR_CORRUPTED)
		return

	switch(new_organ.slot)
		if(ORGAN_SLOT_LIVER)
			new_organ.AddComponent(/datum/component/organ_corruption/liver)
			return

		if(ORGAN_SLOT_LUNGS)
			new_organ.AddComponent(/datum/component/organ_corruption/lungs)
			return

		if(ORGAN_SLOT_STOMACH)
			new_organ.AddComponent(/datum/component/organ_corruption/stomach)
			return

		if(ORGAN_SLOT_TONGUE)
			new_organ.AddComponent(/datum/component/organ_corruption/tongue)
			return
