/datum/unit_test/card_mismatch

/datum/unit_test/card_mismatch/Run()
	var/message = SStrading_card_game.checkCardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.checkCardDatums()
	TEST_ASSERT(!message, message)
