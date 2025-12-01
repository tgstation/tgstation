/// Test beegent transfer
/datum/unit_test/beegent

/datum/unit_test/beegent/Run()
	var/mob/living/basic/bee/bee = allocate(__IMPLIED_TYPE__)
	var/turf/bee_turf = get_turf(bee)
	var/datum/reagent/picked = GLOB.chemical_reagents_list[/datum/reagent/toxin/fentanyl]
	bee.assign_reagent(picked)
	bee.death()
	var/obj/item/trash/bee/dead_bee = locate() in bee_turf
	TEST_ASSERT_NOTNULL(dead_bee, "The bee did not leave a corpse.")
	TEST_ASSERT_EQUAL(dead_bee.beegent, picked, "The bee's corpse did not have the correct beegent assigned.")
	TEST_ASSERT(dead_bee.reagents.has_reagent(/datum/reagent/toxin/fentanyl), "The bee's corpse did not contain any of the beegent.")
	// clean up, we aren't allocated
	QDEL_NULL(dead_bee)
