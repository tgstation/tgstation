/// Ensures digitigrade legs and clothing are displayed correctly in screenshots
/datum/unit_test/screenshot_digi

/datum/unit_test/screenshot_digi/Run()
	var/icon/finished_icon = icon('icons/effects/effects.dmi', "nothing")
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__)

	// screenshot test of just plain digitigrade legs.
	// doubles as coverage that ashwalkers spawn with digitigrade legs (as they should be forced to do)
	dummy.set_species(/datum/species/lizard/ashwalker)
	TEST_ASSERT((dummy.bodyshape & BODYSHAPE_DIGITIGRADE), "Dummy (Ashwalker) should be digitigrade!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 1)

	// screenshot test of an assistant outfit
	// covers digitigrade autogen'd legs
	dummy.equipOutfit(/datum/outfit/job/assistant/consistent)
	TEST_ASSERT(isclothing(dummy.w_uniform), "Dummy (Ashwalker) should be wearing a jumpsuit!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 2)

	// screenshot test of an EVA suit
	// should hide the autogen'd legs
	var/obj/item/clothing/suit/space/eva/suit = allocate(__IMPLIED_TYPE__)
	dummy.equip_to_appropriate_slot(suit)
	TEST_ASSERT_EQUAL(dummy.wear_suit, suit, "Dummy (Ashwalker) should be wearing the EVA suit!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 3)

	// screenshot test of holding an EVA suit
	// should show the autogen'd legs once more
	suit.attempt_pickup(dummy, skip_grav = TRUE)
	TEST_ASSERT((suit in dummy.held_items), "Dummy (Ashwalker) should be holding the EVA suit!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 4)

	// screenshot of turning the ashwalker into a human
	// this should correctly update the auto gen sprites and leg sprites
	dummy.set_species(/datum/species/human)
	TEST_ASSERT(!(dummy.bodyshape & BODYSHAPE_DIGITIGRADE), "Dummy (Human) should be not digitigrade!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 5)

	// screenshot test of turning the human back into an ashwalker
	// this should correctly update the auto gen sprites and leg sprites again
	dummy.set_species(/datum/species/lizard/ashwalker)
	TEST_ASSERT((dummy.bodyshape & BODYSHAPE_DIGITIGRADE), "Dummy (Ashwalker) should be digitigrade again!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 6)


	// screenshot test of putting the EVA suit back on.
	// you'd think this is unnecessary but this is here to cover a bug where the suit works the first equip, but not the second
	dummy.temporarilyRemoveItemFromInventory(suit)
	dummy.equip_to_appropriate_slot(suit)
	TEST_ASSERT_EQUAL(dummy.wear_suit, suit, "Dummy (Ashwalker) should be wearing the EVA suit again!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 7)

	// screenshot test of taking the EVA suit off
	// should show the autogen'd legs once more
	qdel(suit)
	TEST_ASSERT_NULL(dummy.wear_suit, "Dummy (Ashwalker) should not be wearing the EVA suit!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 8)

	// finally, screenshot test of taking jumpsuit (everything) off
	// which should test that the autogen legs disappear (here to cover a bug in which it does not disappear)
	dummy.delete_equipment()
	TEST_ASSERT_EQUAL(length(dummy.get_equipped_items()), 0, "Dummy (Ashwalker) should have no equipment!")
	finished_icon = icon(finished_icon)
	finished_icon.Insert(getFlatIcon(dummy, no_anim = TRUE), dir = SOUTH, frame = 9)

	// and upload
	test_screenshot("leg_test", finished_icon)
