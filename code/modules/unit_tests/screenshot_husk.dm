/// A screenshot test for husks
/datum/unit_test/screenshot_husk

/datum/unit_test/screenshot_husk/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/dummy/consistent) //we don't use a dummy as they have no organs
	human.become_husk(BURN)
	// test with no clothes, the full husk experience
	test_screenshot("body", get_flat_icon_for_all_directions(human))

	var/obj/item/bodypart/leg/left/leftleg = human.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/arm/right/rightarm = human.get_bodypart(BODY_ZONE_R_ARM)
	leftleg.drop_limb(special = TRUE)
	rightarm.drop_limb(special = TRUE)
	// test with some limbs missing
	test_screenshot("body_missing_limbs", get_flat_icon_for_all_directions(human))
