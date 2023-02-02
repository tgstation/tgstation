/datum/unit_test/card_mismatch

/datum/unit_test/card_mismatch/Run()
	var/message = SStrading_card_game.check_cardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.check_card_datums()
	TEST_ASSERT(!message, message)
