///Side effects from metabolizing an reagent or a combination of them
/datum/stacked_reagent_effects
	abstract_type = /datum/stacked_reagent_effects
	///List of reagents that need to be metabolized for this side effect to kick in. For subtypes values greater than requirement list will also trigger this effect
	var/list/datum/reagent/requirements

/**
 * Checks if this side effect can be applied on the mob
 * Arguments
 *
 * * list/reagents_metabolized - a map of reagent type path -> metabolization_ratio of all reagents
 * * mob/living/carbon/owner - the mob to apply the side effects to
 * * seconds_per_tick - passed from /datum/reagents/proc/metabolize_reagent()
*/
/datum/stacked_reagent_effects/proc/check_and_apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/list/datum/reagent/requirements_needed = requirements
	for(var/datum/reagent/test as anything in reagents_metabolized)
		for(var/datum/reagent/requirement as anything in requirements_needed)
			if(ispath(test, requirement))
				if(requirements_needed == requirements)
					requirements_needed = requirements.Copy()
				requirements_needed[requirement] -= 1
				if(!requirements_needed[requirement])
					requirements_needed -= requirement
				break

	if(!requirements_needed.len)
		apply(reagents_metabolized, owner, seconds_per_tick)

/**
 * Apply a list of side effects to an mob once they have metabolized the requirments
 * Arguments
 *
 * * list/reagents_metabolized - a map of reagent type path -> metabolization_ratio of all reagents
 * * mob/living/carbon/owner - the mob to apply the side effects to
 * * seconds_per_tick - passed from /datum/reagents/proc/metabolize_reagent()
*/
/datum/stacked_reagent_effects/proc/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	PROTECTED_PROC(TRUE)

	return FALSE
