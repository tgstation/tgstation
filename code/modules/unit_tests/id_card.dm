/// Ensures the captain's spare id keeps the name "captain's spare id", and doesn't get changed by id label
/datum/unit_test/spare_id_name

/datum/unit_test/spare_id_name/Run()
	var/obj/item/card/id/advanced/gold/captains_spare/card = EASY_ALLOCATE()
	TEST_ASSERT_EQUAL(card.name, initial(card.name), "Captain's spare ID card should not change its name by default.")
