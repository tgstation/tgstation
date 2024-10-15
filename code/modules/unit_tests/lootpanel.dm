/datum/unit_test/lootpanel
	abstract_type = /datum/unit_test/lootpanel

/datum/unit_test/lootpanel/contents/Run()
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	var/datum/lootpanel/panel = allocate(/datum/lootpanel, mock_client)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	mock_client.mob = labrat
	var/turf/one_over = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/obj/item/storage/toolbox/box = allocate(/obj/item/storage/toolbox, one_over)

	panel.open(one_over)
	TEST_ASSERT_EQUAL(length(panel.contents), 2, "Contents should populate on open")
	TEST_ASSERT_EQUAL(length(panel.to_image), 2, "to_image should've populated (unit testing)")
	TEST_ASSERT_EQUAL(panel.contents[1].item, one_over, "First item should be the source turf")

	var/datum/search_object/searchable = panel.contents[2]
	TEST_ASSERT_EQUAL(searchable.item, box, "Second item should be the box")

	qdel(box)
	TEST_ASSERT_EQUAL(length(panel.contents), 1, "Contents should update on searchobj deleted")
	TEST_ASSERT_EQUAL(length(panel.to_image), 1, "to_image should update on searchobj deleted")

	allocate(/obj/item/storage/toolbox, one_over)
	TEST_ASSERT_EQUAL(length(panel.contents), 1, "Contents shouldn't update, we're dumb")
	TEST_ASSERT_EQUAL(length(panel.to_image), 1, "to_image shouldn't update, we're dumb")

	panel.populate_contents() // this also calls reset_contents bc length(contents)
	TEST_ASSERT_EQUAL(length(panel.contents), 2, "Contents should repopulate with the new toolbox")

	panel.populate_contents()
	TEST_ASSERT_EQUAL(length(panel.contents), 2, "Panel shouldnt dupe searchables if reopened")

	mock_client.mob = null
