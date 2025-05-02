
///returns a boolean whether a machine occupant can be infused
/atom/movable/proc/can_infuse(mob/feedback_target)
	if(feedback_target)
		balloon_alert(feedback_target, "no dna!")
	return FALSE

/mob/living/can_infuse(mob/feedback_target)
	if(feedback_target)
		balloon_alert(feedback_target, "dna too simple!")
	return FALSE

/mob/living/carbon/human/can_infuse(mob/feedback_target)
	// Checked by can_mutate but explicit feedback for this issue is good
	if(HAS_TRAIT(src, TRAIT_BADDNA))
		if(feedback_target)
			balloon_alert(feedback_target, "dna is corrupted!")
		return FALSE
	if(!can_mutate())
		if(feedback_target)
			balloon_alert(feedback_target, "dna is missing!")
		return FALSE
	return TRUE

///returns /datum/infuser_entry that matches an item being used for infusion, returns a fly mutation on failure
/atom/movable/proc/get_infusion_entry() as /datum/infuser_entry
	var/datum/infuser_entry/found
	for(var/datum/infuser_entry/entry as anything in flatten_list(GLOB.infuser_entries))
		if(entry.tier == DNA_MUTANT_UNOBTAINABLE)
			continue
		if(is_type_in_list(src, entry.input_obj_or_mob))
			found = entry
			break
	if(!found)
		found = GLOB.infuser_entries[/datum/infuser_entry/fly]
	return found

/// Attempt to replace/add-to the occupant's organs with "mutated" equivalents.
/// Returns TRUE on success, FALSE on failure.
/// Requires the target mob to have an existing organic organ to "mutate".
// TODO: In the future, this should have more logic:
// - Replace non-mutant organs before mutant ones.
/mob/living/carbon/human/proc/infuse_organ(datum/infuser_entry/entry, atom/movable/infused_from)
	var/obj/item/organ/new_organ = pick_infusion_organ(entry, infused_from)
	if(!new_organ)
		return FALSE
	// Valid organ successfully picked.
	new_organ = new new_organ()
	new_organ.replace_into(src)
	new_organ.organ_flags |= ORGAN_MUTANT
	return TRUE

/// Picks a random mutated organ from the given infuser entry which is also compatible with this human.
/// Tries to return a typepath of a valid mutant organ if all of the following criteria are true:
/// 1. Target must have a pre-existing organ in the same organ slot as the new organ;
///   - or the new organ must be external.
/// 2. Target's pre-existing organ must be organic / not robotic.
/// 3. Target must not have the same/identical organ.
/mob/living/carbon/human/proc/pick_infusion_organ(datum/infuser_entry/entry, atom/movable/infused_from)
	if(!entry)
		return FALSE
	var/list/obj/item/organ/potential_new_organs = entry.get_output_organs(src, infused_from)
	// Remove organ typepaths from the list if they're incompatible with target.
	for(var/obj/item/organ/new_organ as anything in entry.output_organs)
		var/obj/item/organ/old_organ = get_organ_slot(initial(new_organ.slot))
		if(old_organ)
			if((old_organ.type != new_organ) && !IS_ROBOTIC_ORGAN(old_organ))
				continue // Old organ can be mutated!
		else if(new_organ::organ_flags & ORGAN_EXTERNAL)
			continue // External organ can be grown!
		// Internal organ is either missing, or is non-organic.
		potential_new_organs -= new_organ
	// Pick a random organ from the filtered list.
	if(length(potential_new_organs))
		return pick(potential_new_organs)
	return FALSE
