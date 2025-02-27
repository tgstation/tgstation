
/// Component used by plasmeme limbs. Ignites the owner and prevents fire armor from working if they're exposed to oxygen
/datum/component/reagent_allergies
	dupe_mode = COMPONENT_DUPE_ALLOWED
	
	/// List of reagent types we are allergic to
	var/list/allergies

/datum/component/reagent_allergies/Initialize(list/allergy_types)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	allergies = string_list(allergy_types)

/datum/component/reagent_allergies/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/reagent_allergies/proc/on_life(mob/living/carbon/human/owner, seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_STASIS))
		return
	if(owner.stat == DEAD)
		return

	//Just halts the progression, I'd suggest you run to medbay asap to get it fixed
	if(owner.reagents.has_reagent(/datum/reagent/medicine/epinephrine))
		for(var/allergy in allergies)
			var/datum/reagent/instantiated_med = owner.reagents.has_reagent(allergy)
			if(!instantiated_med)
				continue
			instantiated_med.reagent_removal_skip_list |= ALLERGIC_REMOVAL_SKIP
		return //block damage so long as epinephrine exists

	for(var/allergy in allergies)
		var/datum/reagent/instantiated_med = owner.reagents.has_reagent(allergy)
		if(!instantiated_med)
			continue
		instantiated_med.reagent_removal_skip_list -= ALLERGIC_REMOVAL_SKIP
		owner.adjustToxLoss(3 * seconds_per_tick)
		owner.reagents.add_reagent(/datum/reagent/toxin/histamine, 3 * seconds_per_tick)
		if(SPT_PROB(10, seconds_per_tick))
			owner.vomit(VOMIT_CATEGORY_DEFAULT)
			owner.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN, ORGAN_SLOT_APPENDIX, ORGAN_SLOT_LUNGS, ORGAN_SLOT_HEART, ORGAN_SLOT_LIVER, ORGAN_SLOT_STOMACH), 10)
