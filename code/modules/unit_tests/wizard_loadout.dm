// Once upon a time, a Game Master decided to upgrade the wizard's spellbook to tgui.
// In doing so, he introduced an infinite loop that crashed many servers and made many wizards sad.
// May this never happen again.

/// Test loadouts for crashes, runtimes, stack traces and infinite loops. No ASSERTs necessary.
/datum/unit_test/wizard_loadout

/datum/unit_test/wizard_loadout/Run()
	for(var/loadout in ALL_WIZARD_LOADOUTS)
		var/obj/item/spellbook/wizard_book = allocate(/obj/item/spellbook)
		var/mob/living/carbon/human/wizard = allocate(/mob/living/carbon/human/consistent)
		wizard.mind_initialize()
		wizard.put_in_active_hand(wizard_book, forced = TRUE)
		wizard_book.wizard_loadout(wizard, loadout)
