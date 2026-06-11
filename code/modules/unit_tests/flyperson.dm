/// Test that flypeople can get nutriment from vomit decals
/datum/unit_test/flyperson

/datum/unit_test/flyperson/Run()
	var/mob/living/carbon/human/consistent/fly = allocate(__IMPLIED_TYPE__)
	fly.set_species(/datum/species/fly)

	var/obj/effect/decal/cleanable/vomit/gross = allocate(__IMPLIED_TYPE__)
	gross.create_reagents(10)
	gross.reagents.add_reagent(/datum/reagent/consumable/nutriment, 10)
	click_wrapper(fly, gross)

	TEST_ASSERT(QDELETED(gross), "The vomit was not deleted by the flyperson")
	TEST_ASSERT(fly.has_reagent(/datum/reagent/consumable/nutriment, 10), "The flyperson did not gain the reagents present in the vomit")
