/// Tests transferring reagents between two reagent_containers, making sure all the regent transfers
/// leaving nothing behind in the source container and making sure everything is in the target container.
/datum/unit_test/reagent_transfer

/datum/unit_test/reagent_transfer/Run()
	var/obj/item/reagent_containers/cup/glass/bottle/source_container = allocate(/obj/item/reagent_containers/cup/glass/bottle)
	var/obj/item/reagent_containers/cup/glass/bottle/target_container = allocate(/obj/item/reagent_containers/cup/glass/bottle)

	source_container.reagents.clear_reagents()
	target_container.reagents.clear_reagents()

	TEST_ASSERT_EQUAL(length(source_container.reagents.reagent_list), 0, "Source container has reagents when it should be empty.")
	TEST_ASSERT_EQUAL(length(target_container.reagents.reagent_list), 0, "Target container has reagents when it should be empty.")

	source_container.reagents.add_reagent(/datum/reagent/water, 10)
	TEST_ASSERT_EQUAL(length(source_container.reagents.reagent_list), 1, "Source container has [length(source_container.reagents)] unique reagents when only 1 is expected.")

	var/datum/reagent/water/water_reagent = source_container.reagents.reagent_list[1]
	TEST_ASSERT(istype(water_reagent), "Incorrect reagent type detected in source container: [water_reagent.type] (should be /datum/reagent/water).")
	TEST_ASSERT_EQUAL(water_reagent.volume, 10, "Source container has [water_reagent.volume] reagent volume when 10 is expected.")

	source_container.reagents.trans_to(target_container, 10)
	TEST_ASSERT_EQUAL(length(source_container.reagents.reagent_list), 0, "Source container has some reagents left over from transfer when none are expected.")

	TEST_ASSERT_EQUAL(length(target_container.reagents.reagent_list), 1, "Target container has [length(source_container.reagents)] unique reagents when only 1 is expected.")
	water_reagent = target_container.reagents.reagent_list[1]
	TEST_ASSERT(istype(water_reagent), "Incorrect reagent type detected in target container: [water_reagent.type] (should be /datum/reagent/water).")
	TEST_ASSERT_EQUAL(water_reagent.volume, 10, "Target container has [water_reagent.volume] reagent volume when 10 is expected.")

/datum/unit_test/reagent_mob_expose/Destroy()
	SSmobs.ignite()
	return ..()
