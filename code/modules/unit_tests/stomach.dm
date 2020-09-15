/datum/unit_test/stomach/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/food/snacks/hotdog/fooditem = allocate(/obj/item/reagent_containers/food/snacks/hotdog)
	var/obj/item/organ/stomach/belly = human.getorganslot(ORGAN_SLOT_STOMACH)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/reagent/drug/methamphetamine/meth = /datum/reagent/drug/methamphetamine

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human somehow has ketchup before eating")

	fooditem.attack(human, human)

	TEST_ASSERT(human.has_reagent(/datum/reagent/consumable/ketchup), "Human doesn't have ketchup after eating")
	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/ketchup), "Stomach doesn't have ketchup after eating")

	//Give them meth and let it kick in
	pill.reagents.add_reagent(meth, initial(meth.metabolization_rate) * 1.9)
	pill.attack(human, human)
	human.Life()

	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/ketchup), "Stomach doesn't have ketchup after eating")
	TEST_ASSERT(human.has_reagent(meth), "Human does not have meth in their system after consuming it")
	TEST_ASSERT(human.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "Human consumed meth, but did not gain movespeed modifier")

	belly.Remove(human)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human still has ketchup after removal of stomach")
	TEST_ASSERT(!human.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "Human still has movespeed modifier despite not containing any more meth")

	fooditem.attack(human, human)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human has ketchup without a stomach")
