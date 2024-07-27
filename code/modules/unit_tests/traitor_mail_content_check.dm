/// Makes sure that fake mail doesn't get random goods.
/datum/unit_test/traitor_mail_content_check

/datum/unit_test/traitor_mail_content_check/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	person.mind_initialize()
	var/obj/item/mail/traitor/test_mail = allocate(/obj/item/mail/traitor)
	person.mind.set_assigned_role(SSjob.get_job_type(/datum/job/captain))
	test_mail.initialize_for_recipient(person.mind)
	TEST_ASSERT_EQUAL(test_mail.contents.len, 0, "/obj/item/mail/traitor should not have items after initialize_for_recipient proc!")
