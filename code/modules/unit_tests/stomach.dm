/datum/unit_test/stomach/Run()

	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/food/hotdog/debug/fooditem = allocate(/obj/item/food/hotdog/debug)
	var/obj/item/organ/stomach/belly = human.get_organ_slot(ORGAN_SLOT_STOMACH)
	var/obj/item/reagent_containers/applicator/pill/pill_one = allocate(/obj/item/reagent_containers/applicator/pill)
	var/obj/item/reagent_containers/applicator/pill/pill_two = allocate(/obj/item/reagent_containers/applicator/pill)
	var/datum/reagent/drug/methamphetamine/meth = /datum/reagent/drug/methamphetamine
	var/datum/reagent/drug/kronkaine/krok = /datum/reagent/drug/kronkaine

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human somehow has ketchup before eating")

	fooditem.attack(human, human)

	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/ketchup), "Stomach doesn't have ketchup after eating")
	TEST_ASSERT_EQUAL(human.reagents.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human body has ketchup after eating it should only be in the stomach")

	//Give them meth and let it kick in
	pill_one.reagents.add_reagent(meth, 1.9 * initial(meth.metabolization_rate) * SSMOBS_DT)
	pill_one.layers_remaining = 0
	pill_one.interact_with_atom(human, human)
	human.Life(SSMOBS_DT)

	TEST_ASSERT(human.reagents.has_reagent(meth), "Human body does not have meth after life tick")
	TEST_ASSERT(human.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "Human consumed meth, but did not gain movespeed modifier")

	// Check if pills properly get stored in stomachs
	pill_two.reagents.add_reagent(krok, 1.9 * initial(krok.metabolization_rate) * SSMOBS_DT)
	pill_two.layers_remaining = 99
	pill_two.interact_with_atom(human, human)
	human.Life(SSMOBS_DT)

	TEST_ASSERT_EQUAL(human.reagents.has_reagent(krok), FALSE, "Human body has krokaine after taking a pill despite it having 99 layers")
	TEST_ASSERT(pill_two in belly.stomach_contents, "Krokaine pill did not get stored in target's stomach")
	TEST_ASSERT(pill_two.loc == human, "Krokaine pill was not put in target's body")

	QDEL_NULL(pill_two)
	belly.Remove(human)
	human.reagents.remove_all(human.reagents.total_volume)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human has reagents after clearing")

	fooditem.attack(human, human)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human has ketchup without a stomach")

/datum/unit_test/stomach/Destroy()
	SSmobs.ignite()
	return ..()
