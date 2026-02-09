///Maximum amount of organ damage
#define MAX_ORGAN_DAMAGE 7

///Damage applied to an organ
/datum/stacked_reagent_effects/organ_damage
	abstract_type = /datum/stacked_reagent_effects/organ_damage
	///Organ slot to apply damage to
	VAR_PROTECTED/organ_slot
	///Multiplier for damage
	VAR_PROTECTED/scale

/datum/stacked_reagent_effects/organ_damage/apply(list/reagents_metabolized, mob/living/carbon/owner, seconds_per_tick)
	. = 0

	var/obj/item/organ/organ = owner.get_organ_slot(organ_slot)
	if(organ)
		var/damage = 0
		for(var/datum/reagent/medicine/med as anything in reagents_metabolized)
			damage += reagents_metabolized[med]
		return abs(organ.apply_organ_damage(min(scale * damage * seconds_per_tick, MAX_ORGAN_DAMAGE)))

/datum/stacked_reagent_effects/organ_damage/liver_damage
	requirements = list(/datum/reagent/medicine = 4)
	organ_slot = ORGAN_SLOT_LIVER
	scale = 0.6

/datum/stacked_reagent_effects/organ_damage/stomach_damage
	requirements = list(/datum/reagent/medicine = 5)
	organ_slot = ORGAN_SLOT_STOMACH
	scale = 0.5

/datum/stacked_reagent_effects/organ_damage/lung_damage
	requirements = list(/datum/reagent/medicine = 6)
	organ_slot = ORGAN_SLOT_LUNGS
	scale = 0.4

/datum/stacked_reagent_effects/organ_damage/heart_damage
	requirements = list(/datum/reagent/medicine = 7)
	organ_slot = ORGAN_SLOT_HEART
	scale = 0.3

/datum/stacked_reagent_effects/organ_damage/brain_damage
	requirements = list(/datum/reagent/medicine = 8)
	organ_slot = ORGAN_SLOT_BRAIN
	scale = 0.2

#undef MAX_ORGAN_DAMAGE
