/// Checks for items int contents of /obj/item/mail/traitor after initialize_for_recipient proc
/datum/unit_test/traitor_mail_content_check

/datum/unit_test/traitor_mail_content_check/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/mail/traitor/test_mail = allocate(/obj/item/mail/traitor)
	person.mind.assigned_role = JOB_CAPTAIN
	test_mail.initialize_for_recipient(person.mind)
	TEST_ASSERT(test_mail.contents.len == 0, "/obj/item/mail/traitor should not have item after initialize_for_recipient proc!")
