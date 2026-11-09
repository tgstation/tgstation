/datum/unit_test/reachable_soup

/datum/unit_test/reachable_soup/Run()
	var/obj/machinery/oven/range/range = EASY_ALLOCATE()
	var/obj/item/reagent_containers/cup/soup_pot/soup = EASY_ALLOCATE()
	var/mob/living/carbon/human/dummy = EASY_ALLOCATE()

	dummy.put_in_active_hand(soup)
	click_wrapper(dummy, range)
	TEST_ASSERT_EQUAL(soup.loc, range, "Soup pot should have been placed on the stove.")

	click_wrapper(dummy, soup)
	TEST_ASSERT_EQUAL(soup.loc, dummy, "Soup pot should have been picked up by the dummy.")
