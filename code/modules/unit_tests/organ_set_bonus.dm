/// Tests the "organ set bonus" status effects, which are for the DNA Infuser.
/// Ensures they properly change their IDs.
/datum/unit_test/organ_set_bonus_id/Run()
	var/bonus_effects = subtypesof(/datum/status_effect/organ_set_bonus)
	var/list/existing_ids = list()
	for(var/datum/status_effect/organ_set_bonus/bonus_effect in bonus_effects)
		var/effect_id = initial(bonus_effect.id)
		var/id_exists = (effect_id in existing_ids)
		if(id_exists)
			TEST_FAIL("ID of [bonus_effect] was duplicated in another status effect.")
		else
			existing_ids += effect_id

/// Tests the "organ set bonus" status effects.
/// Ensures that each status effect gets properly added/removed from mobs.
/datum/unit_test/organ_set_bonus_sanity/Run()
	var/infuser_entries = typesof(/datum/infuser_entry)
	for(var/datum/infuser_entry/infuser_entry in infuser_entries)
		var/output_organs = initial(infuser_entry.output_organs)
		var/datum/element/organ_set_bonus/bonus_element
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		for(var/obj/item/organ/organ as anything in output_organs)
			organ = new organ()
			organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
			if(!bonus_element)
				bonus_element = organ.comp_lookup["comsig_organ_implanted"]
		var/datum/status_effect/organ_set_bonus/bonus_effect = lab_rat.has_status_effect(bonus_element.bonus_type)
		TEST_ASSERT_NOTNULL(bonus_effect,
		"The \"organ set bonus\" status effect for [infuser_entry] was not added to the mob as expected.")
