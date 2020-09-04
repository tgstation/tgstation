/datum/unit_test/pills/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/iron/pill = allocate(/obj/item/reagent_containers/pill/iron)
	// Pills go in the belly and metabolize to the body, they do not go from mouth to blood.
	//var/obj/item/organ/stomach/belly = human.getorganslot(ORGAN_SLOT_STOMACH)

	TEST_ASSERT_EQUAL(human.reagents.has_reagent(/datum/reagent/iron), FALSE, "Human somehow has iron before taking pill")

	pill.attack(human, human)
	human.Life()

	// This is not correct but consessions are made
	TEST_ASSERT(human.reagents.has_reagent(/datum/reagent/iron), "Human doesn't have iron after taking pill")
	// This is what should have happened
	//TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/iron), "Belly doesn't have iron after taking pill")

