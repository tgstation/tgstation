/datum/unit_test/id_access

/datum/unit_test/id_access/Run()
	var/mob/living/carbon/human/consistent/subject = EASY_ALLOCATE()
	subject.equip_to_appropriate_slot(new /obj/item/clothing/under/color/grey)
	var/obj/item/card/id/advanced/card = EASY_ALLOCATE()

	card.set_access(list(ACCESS_HYDROPONICS), FORCE_ADD_ALL)
	TEST_ASSERT_EQUAL(length(card.GetAccess()), 1, "ID card access length incorrect after setting access.")

	subject.put_in_hands(card)
	TEST_ASSERT(check_access(subject, ACCESS_HYDROPONICS), "Subject did not have the access on holding ID card.")
	subject.dropItemToGround(card)
	TEST_ASSERT(check_access(subject, null), "Subject still had access after dropping ID card.")
	subject.equip_to_appropriate_slot(card)
	TEST_ASSERT(check_access(subject, ACCESS_HYDROPONICS), "Subject did not have the access on equipping ID card.")
	subject.dropItemToGround(card)
	TEST_ASSERT(check_access(subject, null), "Subject still had access after unequipping ID card.")

	var/obj/item/storage/wallet/wallet = EASY_ALLOCATE()
	card.forceMove(wallet)
	subject.equip_to_appropriate_slot(wallet)
	TEST_ASSERT(check_access(subject, ACCESS_HYDROPONICS), "Subject did not have the access on equipping wallet with ID card inside.")
	subject.dropItemToGround(wallet)
	TEST_ASSERT(check_access(subject, null), "Subject still had access after unequipping wallet with ID card inside.")
	subject.equip_to_appropriate_slot(wallet)
	click_wrapper(subject, card) // withdraw id card from wallet
	TEST_ASSERT(card.loc == subject && card == subject.get_active_held_item(), "Subject failed to withdraw ID card from wallet.")
	click_wrapper(subject, wallet) // reinsert id card into wallet
	TEST_ASSERT(card.loc == wallet, "Subject failed to reinsert ID card into wallet.")
	TEST_ASSERT(check_access(subject, ACCESS_HYDROPONICS), "Subject did not have the access after reinserting ID card into equipped wallet.")
	subject.dropItemToGround(wallet)

	var/obj/item/modular_computer/pda/pda = EASY_ALLOCATE()
	pda.insert_id(card)
	subject.equip_to_appropriate_slot(pda)
	TEST_ASSERT(check_access(subject, ACCESS_HYDROPONICS), "Subject did not have the access on equipping PDA with ID card inside.")
	subject.dropItemToGround(pda)
	TEST_ASSERT(check_access(subject, null), "Subject still had access after unequipping PDA with ID card inside.")
	subject.equip_to_appropriate_slot(pda)
	pda.remove_id(subject)
	TEST_ASSERT(card.loc == subject && card == subject.get_active_held_item(), "Subject failed to withdraw ID card from PDA.")
	click_wrapper(subject, pda) // reinsert id card into pda
	TEST_ASSERT(card.loc == pda, "Subject failed to reinsert ID card into PDA.")
	TEST_ASSERT(check_access(subject, ACCESS_HYDROPONICS), "Subject did not have the access after reinserting ID card into equipped PDA.")
	subject.dropItemToGround(pda)

/datum/unit_test/id_access/proc/check_access(mob/living/carbon/human/consistent/subject, expected)
	var/list/subject_access = subject.get_access()
	if(isnull(expected))
		return length(subject_access) == 0
	return length(subject_access) == 1 && subject_access[1] == expected
