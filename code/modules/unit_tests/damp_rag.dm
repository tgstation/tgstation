/// Tests that damp rags can smother people.
/// When smothing reagents are ingested (go to the stomach).
/datum/unit_test/damp_rag_smother

/datum/unit_test/damp_rag_smother/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/organ/stomach/victim_stomach = victim.get_organ_slot(ORGAN_SLOT_STOMACH)
	var/obj/item/rag/rag = EASY_ALLOCATE()

	attacker.put_in_active_hand(rag, forced = TRUE)
	attacker.zone_selected = BODY_ZONE_PRECISE_MOUTH
	attacker.set_combat_mode(TRUE)
	rag.reagents.add_reagent(/datum/reagent/water, rag.reagents.maximum_volume)
	click_wrapper(attacker, victim)
	TEST_ASSERT_EQUAL(victim_stomach.reagents.get_reagent_amount(/datum/reagent/water), rag.reagents.maximum_volume, \
		"The victim should have been smothered by the rag, gaining water reagent.")
