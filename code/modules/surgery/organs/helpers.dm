/**
 * Get the organ object from the mob matching the passed in typepath
 *
 * Arguments:
 * * typepath The typepath of the organ to get
 */
/mob/proc/get_organ_by_type(typepath)
	RETURN_TYPE(/obj/item/organ)
	return

/**
 * Get organ objects by zone
 *
 * This will return a list of all the organs that are relevant to the zone that is passedin
 *
 * Arguments:
 * * zone [a BODY_ZONE_X define](https://github.com/tgstation/tgstation/blob/master/code/__DEFINES/combat.dm#L187-L200)
 */
/mob/proc/get_organs_for_zone(zone)
	return

/**
 * Returns a list of all organs in specified slot
 *
 * Arguments:
 * * slot Slot to get the organs from
 */
/mob/proc/get_organ_slot(slot)
	return

/mob/living/carbon/get_organ_by_type(typepath)
	return (locate(typepath) in organs)

/mob/living/carbon/get_organs_for_zone(zone, include_children = FALSE)
	var/valid_organs = list()
	for(var/obj/item/organ/organ as anything in organs)
		if(zone == organ.zone)
			valid_organs += organ
		else if(include_children && zone == deprecise_zone(organ.zone))
			valid_organs += organ
	return valid_organs

/mob/living/carbon/get_organ_slot(slot)
	. = organs_slot[slot]

/**
 * Returns a list of all missing organs this species should have
 *
 * list [key] is the ORGAN_SLOT missing an organ, list value is the text name of the slot organ
 */
/mob/living/carbon/human/proc/get_missing_organs(include_appendix = FALSE)
	var/list/missing_organs = list()

	if(!get_organ_slot(ORGAN_SLOT_BRAIN))
		missing_organs[ORGAN_SLOT_BRAIN] = "Brain"
	if(needs_heart() && !get_organ_slot(ORGAN_SLOT_HEART))
		missing_organs[ORGAN_SLOT_HEART] = "Heart"
	if(!HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT) && !isnull(dna.species.mutantlungs) && !get_organ_slot(ORGAN_SLOT_LUNGS))
		missing_organs[ORGAN_SLOT_LUNGS] = "Lungs"
	if(!HAS_TRAIT_FROM(src, TRAIT_LIVERLESS_METABOLISM, SPECIES_TRAIT) && !isnull(dna.species.mutantliver) && !get_organ_slot(ORGAN_SLOT_LIVER))
		missing_organs[ORGAN_SLOT_LIVER] = "Liver"
	if(!HAS_TRAIT_FROM(src, TRAIT_NOHUNGER, SPECIES_TRAIT) && !isnull(dna.species.mutantstomach) && !get_organ_slot(ORGAN_SLOT_STOMACH))
		missing_organs[ORGAN_SLOT_STOMACH] ="Stomach"
	if(!isnull(dna.species.mutanttongue) && !get_organ_slot(ORGAN_SLOT_TONGUE))
		missing_organs[ORGAN_SLOT_TONGUE] = "Tongue"
	if(!isnull(dna.species.mutantears) && !get_organ_slot(ORGAN_SLOT_EARS))
		missing_organs[ORGAN_SLOT_EARS] = "Ears"
	if(!isnull(dna.species.mutantears) && !get_organ_slot(ORGAN_SLOT_EYES))
		missing_organs[ORGAN_SLOT_EYES] = "Eyes"
	if(include_appendix && !isnull(dna.species.mutantappendix) && !get_organ_slot(ORGAN_SLOT_APPENDIX))
		missing_organs[ORGAN_SLOT_APPENDIX] = "Appendix"

	return missing_organs
