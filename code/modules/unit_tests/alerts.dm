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

/datum/unit_test/alert_underlay_stripping

/datum/unit_test/alert_underlay_stripping/Run()
	var/mob/living/carbon/human/consistent/dummy = EASY_ALLOCATE()
	dummy.equipOutfit(/datum/outfit/job/assistant/consistent)
	dummy.mock_client = new /datum/client_interface()

	var/obj/item/flashlight/lantern/on/light = EASY_ALLOCATE()
	dummy.put_in_hands(light)

	var/obj/item/rod_of_asclepius/asclepius = EASY_ALLOCATE()
	dummy.put_in_hands(asclepius)
	asclepius.apply_oath(dummy)

	var/datum/status_effect/hippocratic_oath/oath = dummy.has_status_effect(/datum/status_effect/hippocratic_oath)
	TEST_ASSERT_NOTNULL(oath, "Dummy should have the Hippocratic Oath status effect.")
	oath.aura_healing.process(1) // tick it once to apply the alert
	var/atom/movable/screen/alert/aura_healing/alert = locate() in assoc_to_values(dummy.alerts)
	TEST_ASSERT_NOTNULL(alert, "Dummy should have received the aura healing alert.")
	TEST_ASSERT(length(alert.overlays) > 0, "Alert should have overlays applied.")

	for(var/mutable_appearance/some_overlay as anything in alert.overlays)
		var/base_plane = PLANE_TO_TRUE(some_overlay.plane)
		for(var/mutable_appearance/some_subunderlay as anything in some_overlay.underlays)
			if(PLANE_TO_TRUE(some_subunderlay.plane) != base_plane)
				TEST_FAIL("Alert overlay has a off-plane underlay - it should have been stripped, otherwise it may interfere with screens.")
