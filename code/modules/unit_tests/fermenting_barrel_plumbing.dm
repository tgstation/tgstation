/datum/unit_test/fermenting_barrel_plumbing/Run()
	var/obj/structure/fermenting_barrel/barrel = allocate(/obj/structure/fermenting_barrel, run_loc_floor_bottom_left)
	var/list/plumbing_components = barrel.GetComponents(/datum/component/plumbing/tank)
	var/datum/component/plumbing/tank/barrel_plumbing = length(plumbing_components) ? plumbing_components[1] : null

	TEST_ASSERT_NOTNULL(barrel_plumbing, "Fermenting barrel did not initialize with a plumbing tank component.")
	TEST_ASSERT_EQUAL(barrel_plumbing.recipient_reagents_holder(), barrel.reagents, "Fermenting barrel plumbing component did not use the barrel's reagent holder.")
