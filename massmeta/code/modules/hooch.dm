#define TRAIT_GREYTIDE_METABOLISM "greytide_metabolism"

/datum/job/assistant
	liver_traits = list(TRAIT_GREYTIDE_METABOLISM)

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/drinker, delta_time, times_fired)
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_GREYTIDE_METABOLISM))
		drinker.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = TRUE
	return ..() || .

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	var/obj/item/organ/internal/liver/empowered_liver = affected_carbon.get_organ_by_type(/obj/item/organ/internal/liver)
	if(empowered_liver)
		ADD_TRAIT(empowered_liver, TRAIT_GREYTIDE_METABOLISM, "maint_drug_addiction")

/obj/item/organ/internal/liver/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_ENTRAILS_READER) || (user.mind && HAS_TRAIT(user.mind, TRAIT_ENTRAILS_READER)) || isobserver(user))
		if(HAS_TRAIT(src, TRAIT_GREYTIDE_METABOLISM))
			. += "Greyer than most with electrical burn marks, this is the liver of an <em>assistant</em>."
