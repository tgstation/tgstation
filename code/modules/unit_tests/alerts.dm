/// Tests screen alerts are clickable
/datum/unit_test/alerts
	var/was_clicked = FALSE

/datum/unit_test/alerts/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.mock_client = new /datum/client_interface()

	var/old_usr = usr // Click still relies on usr so let's not mess this up
	usr = dummy

	var/atom/movable/screen/alert/test_alert/clickme = dummy.throw_alert(TRAIT_SOURCE_UNIT_TESTS, /atom/movable/screen/alert/test_alert)
	clickme.linked = src
	clickme.Click()
	if(!was_clicked)
		TEST_FAIL("Screen alert was not clickable.")

	usr = old_usr

/atom/movable/screen/alert/test_alert
	var/datum/unit_test/alerts/linked

/atom/movable/screen/alert/test_alert/Click(location, control, params)
	. = ..()
	if(!.)
		return

	linked.was_clicked = TRUE

/atom/movable/screen/alert/test_alert/Destroy()
	linked = null
	return ..()
