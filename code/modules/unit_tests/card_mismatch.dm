/datum/unit_test/card_mismatch

/datum/unit_test/card_mismatch/Run()
	var/message = checkCardpacks(SStrading_card_game.card_packs)
	message += checkCardDatums()
	if(message)
		Fail(message)
