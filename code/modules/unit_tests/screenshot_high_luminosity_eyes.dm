#define UPDATE_EYES_LEFT 1
#define UPDATE_EYES_RIGHT 2

/// Tests to make sure no punks have broken high luminosity eyes
/datum/unit_test/screenshot_high_luminosity_eyes
	var/mob/living/carbon/human/test_subject
	var/obj/item/organ/internal/eyes/robotic/glow/test_eyes

/datum/unit_test/screenshot_high_luminosity_eyes/Run()
	// Create a mob with red and blue eyes. This is to test that high luminosity eyes properly default to the old eye color.
	test_subject = allocate(/mob/living/carbon/human/consistent)
	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent)
	test_subject.eye_color_left = COLOR_RED
	test_subject.eye_color_right = COLOR_BLUE

	// Create our eyes, and insert them into the mob
	test_eyes = allocate(/obj/item/organ/internal/eyes/robotic/glow)
	test_eyes.Insert(test_subject)

	// This should be 4, but just in case it ever changes in the future
	var/default_light_range = test_eyes.eye.light_range

	// Test the normal light on appearance
	test_eyes.toggle_active()
	var/icon/flat_icon = create_icon()
	test_screenshot("light_on", flat_icon)

	// Change the eye color to pink and green
	test_eyes.set_beam_color(COLOR_SCIENCE_PINK, to_update = UPDATE_EYES_LEFT)
	test_eyes.set_beam_color(COLOR_SLIME_GREEN, to_update = UPDATE_EYES_RIGHT)

	// Make sure the light overlay goes away (but not the emissive overlays) when we go to light range 0 while still turned on
	test_eyes.set_beam_range(0)
	TEST_ASSERT_EQUAL(test_eyes.eye.light_on, TRUE, "[src]'s 'eye.light_on' is FALSE after setting range to 0 while on. 'eye.light_on' should = TRUE!")
	flat_icon = create_icon()
	test_screenshot("light_emissive", flat_icon)

	// turn it on and off again, it should look the same afterwards
	test_eyes.toggle_active()
	TEST_ASSERT_EQUAL(test_eyes.eye.light_on, FALSE, "[src]'s 'eye.light_on' is TRUE after being toggled off at range 0. 'eye.light_on' should = FALSE!")
	test_eyes.toggle_active()
	TEST_ASSERT_EQUAL(test_eyes.eye.light_on, TRUE, "[src]'s 'eye.light_on' is FALSE after being toggled on at range 0. 'eye.light_on' should = TRUE!")
	flat_icon = create_icon()
	test_screenshot("light_emissive", flat_icon)

	// Make sure the light comes back on when we go from range 0 to 1
	// Change left/right eye color back to red/blue. It should match the original screenshot
	test_eyes.set_beam_range(default_light_range)
	test_eyes.set_beam_color(COLOR_RED, to_update = UPDATE_EYES_LEFT)
	test_eyes.set_beam_color(COLOR_BLUE, to_update = UPDATE_EYES_RIGHT)
	flat_icon = create_icon()
	test_screenshot("light_on", flat_icon)

/// Create the mob icon with light cone underlay
/datum/unit_test/screenshot_high_luminosity_eyes/proc/create_icon()
	var/icon/final_icon = get_flat_icon_for_all_directions(test_subject, no_anim = FALSE)
	for(var/mutable_appearance/light_underlay as anything in test_subject.underlays)
		if(light_underlay.icon == 'icons/effects/light_overlays/light_cone.dmi')
			// The light cone icon is 96x96, so we have to shift it over to have it match our sprites. x = 1, y = 1 is the lower left corner so we shift 32 pixels opposite to that.
			final_icon.Blend(get_flat_icon_for_all_directions(light_underlay, no_anim = FALSE), ICON_UNDERLAY, -ICON_SIZE_X + 1, -ICON_SIZE_Y + 1)
	return final_icon

#undef UPDATE_EYES_LEFT
#undef UPDATE_EYES_RIGHT
