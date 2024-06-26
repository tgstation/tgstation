/// This test ensures that any mapped xenobiology pens properly have a unique mapping ID set between each ooze sucker and slime pen management console.
/datum/unit_test/linked_xenobio_pens

/datum/unit_test/linked_xenobio_pens/Run()
	var/list/obj/machinery/plumbing/ooze_sucker/used_map_ids = list()
	for(var/obj/machinery/slime_pen_controller/pen as anything in GLOB.slime_pen_controllers)
		if(!pen.mapping_id)
			TEST_FAIL("Found a slime pen management console without a mapping ID at [AREACOORD(pen)]!")
		else if(used_map_ids[pen.mapping_id])
			TEST_FAIL("Found a slime pen management console with duplicate mapping_id [pen.mapping_id] at [AREACOORD(pen)], which is already used by the console at [AREACOORD(used_map_ids[pen.mapping_id])]!")
		else
			used_map_ids[pen.mapping_id] = pen
	for(var/obj/machinery/plumbing/ooze_sucker/sucker as anything in GLOB.ooze_suckers)
		if(!sucker.mapping_id)
			TEST_FAIL("Found an ooze sucker without a mapping ID at [AREACOORD(sucker)]!")
		else if(!used_map_ids[sucker.mapping_id])
			TEST_FAIL("Found an ooze sucker with an unused mapping ID at [AREACOORD(sucker)]!")
		else if(!sucker.linked_controller)
			TEST_FAIL("Ooze sucker failed to link to controller at [AREACOORD(sucker)]!")

