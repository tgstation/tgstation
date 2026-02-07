/datum/stacked_reagent_effects/liver_damage
	requirements = list(/datum/reagent/medicine = 4)

/datum/stacked_reagent_effects/liver_damage/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	var/obj/item/organ/liver = owner.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		var/liver_damage = 0
		for(var/datum/reagent/medicine/med as anything in reagents_metabolized)
			liver_damage += 0.6 * reagents_metabolized[med]
		liver.apply_organ_damage(liver_damage * seconds_per_tick)

/datum/stacked_reagent_effects/stomache_damage
	requirements = list(/datum/reagent/medicine = 5)

/datum/stacked_reagent_effects/stomache_damage/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	var/obj/item/organ/stomach = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(stomach)
		var/stomach_damage = 0
		for(var/datum/reagent/medicine/med as anything in reagents_metabolized)
			stomach_damage += 0.5 * reagents_metabolized[med]
		stomach.apply_organ_damage(stomach_damage * seconds_per_tick)

/datum/stacked_reagent_effects/lung_damage
	requirements = list(/datum/reagent/medicine = 6)

/datum/stacked_reagent_effects/lung_damage/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	var/obj/item/organ/lung = owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(lung)
		var/lung_damage = 0
		for(var/datum/reagent/medicine/med as anything in reagents_metabolized)
			lung_damage += 0.4 * reagents_metabolized[med]
		lung.apply_organ_damage(lung_damage * seconds_per_tick)

/datum/stacked_reagent_effects/heart_damage
	requirements = list(/datum/reagent/medicine = 7)

/datum/stacked_reagent_effects/heart_damage/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	var/obj/item/organ/heart = owner.get_organ_slot(ORGAN_SLOT_HEART)
	if(heart)
		var/heart_damage = 0
		for(var/datum/reagent/medicine/med as anything in reagents_metabolized)
			heart_damage += 0.3 * reagents_metabolized[med]
		heart.apply_organ_damage(heart_damage * seconds_per_tick)
