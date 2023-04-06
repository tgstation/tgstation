// testing the mob expose procs are working

/datum/reagent/method_patch_test
	name = "method patch test"

/datum/reagent/method_patch_test/expose_mob(mob/living/target, methods = PATCH, reac_volume, show_message = TRUE)
	. = ..()
	if(methods & PATCH)
		target.health = 90
	if(methods & INJECT)
		target.health = 80

/datum/unit_test/reagent_mob_expose/Run()
	// Life() is handled just by tests
	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/reagent_containers/dropper/dropper = allocate(/obj/item/reagent_containers/dropper)
	var/obj/item/reagent_containers/cup/glass/bottle/drink = allocate(/obj/item/reagent_containers/cup/glass/bottle)
	var/obj/item/reagent_containers/pill/patch/patch = allocate(/obj/item/reagent_containers/pill/patch)
	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)

	// INGEST
	TEST_ASSERT_EQUAL(human.fire_stacks, 0, "Human has fire stacks before taking phlogiston")
	drink.reagents.add_reagent(/datum/reagent/phlogiston, 10)
	drink.attack(human, human)
	TEST_ASSERT_EQUAL(human.fire_stacks, 1, "Human does not have fire stacks after taking phlogiston")
	human.Life(SSMOBS_DT)
	TEST_ASSERT(human.fire_stacks > 1, "Human fire stacks did not increase after life tick")

	// TOUCH
	dropper.reagents.add_reagent(/datum/reagent/water, 5)
	dropper.afterattack(human, human, TRUE)
	TEST_ASSERT(human.fire_stacks < 0, "Human still has fire stacks after touching water")

	// VAPOR
	TEST_ASSERT_NULL(human.has_status_effect(/datum/status_effect/drowsiness), "Human is drowsy at the start of testing")
	drink.reagents.clear_reagents()
	drink.reagents.add_reagent(/datum/reagent/nitrous_oxide, 10)
	drink.reagents.trans_to(human, 10, methods = VAPOR)
	TEST_ASSERT_NOTNULL(human.has_status_effect(/datum/status_effect/drowsiness), "Human is not drowsy after exposure to vapors")
	drink.reagents.clear_reagents()
	drink.reagents.add_reagent(/datum/reagent/water, 10)
	var/old_fire_stacks = human.fire_stacks
	drink.reagents.trans_to(human, 10, methods = VAPOR)
	TEST_ASSERT(human.fire_stacks < old_fire_stacks, "Human does not get wetter after being exposed to water by vapors")

	// PATCH
	human.health = 100
	TEST_ASSERT_EQUAL(human.health, 100, "Human health did not set properly")
	patch.reagents.add_reagent(/datum/reagent/method_patch_test, 1)
	patch.self_delay = 0
	patch.attack(human, human)
	TEST_ASSERT_EQUAL(human.health, 90, "Human health did not update after patch was applied")

	// INJECT
	syringe.reagents.add_reagent(/datum/reagent/method_patch_test, 1)
	syringe.melee_attack_chain(human, human)
	TEST_ASSERT_EQUAL(human.health, 80, "Human health did not update after injection from syringe")

/datum/unit_test/reagent_mob_expose/Destroy()
	SSmobs.ignite()
	return ..()
