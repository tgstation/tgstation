// Test a high five through and through, with multiple people nearby
/datum/unit_test/high_five

/datum/unit_test/high_five/Run()
	var/mob/living/carbon/human/offer_guy = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/take_guy = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/random_bystander = allocate(/mob/living/carbon/human/consistent) // this guy's just here for another valid taker

	offer_guy.emote("slap")
	offer_guy.give()

	TEST_ASSERT_NOTNULL(offer_guy.has_status_effect(/datum/status_effect/offering/no_item_received/high_five), \
		"Offerer doesn't have the high five offer status effect after offering (giving) to takers nearby")

	var/atom/movable/screen/alert/give/highfive/alert_to_click = locate() in flatten_list(take_guy.alerts)
	var/atom/movable/screen/alert/give/highfive/bystander_alert_we_dont_click = locate() in flatten_list(random_bystander.alerts)
	TEST_ASSERT_NOTNULL(alert_to_click, "Taker had no alert to click to accept the high five offer")
	TEST_ASSERT_NOTNULL(bystander_alert_we_dont_click, "Bystander had no alert from the high fiver offer")

	alert_to_click.handle_transfer() // high five happens here with the taker only. Can't call click but this is close

	TEST_ASSERT_NULL(offer_guy.has_status_effect(/datum/status_effect/offering/no_item_received/high_five), \
		"Offerer still has the high five offer status effect after a high five was completed")
	TEST_ASSERT(QDELETED(bystander_alert_we_dont_click), \
		"Bystander still has the alert from the high fiver offer after the high five was completed")

// Test a too slow setup
/datum/unit_test/high_five_too_slow

/datum/unit_test/high_five_too_slow/Run()
	var/mob/living/carbon/human/offer_guy = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/take_guy = allocate(/mob/living/carbon/human/consistent)
	pass(take_guy) // This guy just needs to stand around

	// Just testing a too slow setup - so long as the setup works, we're good.
	offer_guy.emote("slap")
	offer_guy.give()
	offer_guy.dropItemToGround(offer_guy.get_active_held_item())
	TEST_ASSERT_NOTNULL(offer_guy.has_status_effect(/datum/status_effect/offering/no_item_received/high_five), \
		"Offerer lost the high five offer status effect from dropping the slapper, even though this is valid, as it is used to too-slow")

/// Tests someone offering a high five correctly stops offering when all takers walks away
/datum/unit_test/high_five_walk_away

/datum/unit_test/high_five_walk_away/Run()
	var/mob/living/carbon/human/offer_guy = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/take_guy_A = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/take_guy_B = allocate(/mob/living/carbon/human/consistent)

	offer_guy.emote("slap")
	offer_guy.give()
	take_guy_A.forceMove(run_loc_floor_top_right)
	TEST_ASSERT_NOTNULL(offer_guy.has_status_effect(/datum/status_effect/offering/no_item_received/high_five), \
		"Offerer lost the high fiver offer status effect from taker A moving away, which is invalid because taker B is still nearby")

	take_guy_B.forceMove(run_loc_floor_top_right)
	TEST_ASSERT_NULL(offer_guy.has_status_effect(/datum/status_effect/offering/no_item_received/high_five), \
		"Offerer still has the high fiver offer status effect from taker B moving away, which is invalid because there are no takers are nearby")
