/// Tests SLOWS_WHILE_IN_HAND
/datum/unit_test/held_slowdown

/datum/unit_test/held_slowdown/Run()
	var/mob/living/carbon/human/consistent/dummy = EASY_ALLOCATE()
	var/obj/item/restraints/legcuffs/bola/bola = EASY_ALLOCATE()
	dummy.put_in_hands(bola)
	TEST_ASSERT(!(bola in dummy.get_equipped_speed_mod_items()), "Bola slows while held, when it shouldn't.")

	bola.item_flags |= SLOWS_WHILE_IN_HAND
	TEST_ASSERT((bola in dummy.get_equipped_speed_mod_items()), "Bola should slow while held now that it has the SLOWS_WHILE_IN_HAND flag.")
