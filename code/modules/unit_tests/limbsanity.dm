/datum/unit_test/limbsanity

/datum/unit_test/limbsanity/Run()
	for(var/path in subtypesof(/obj/item/bodypart) - list(/obj/item/bodypart/arm, /obj/item/bodypart/leg)) /// removes the abstract items.
		var/obj/item/bodypart/part = new path(null)
		if(part.is_dimorphic)
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_m"))
				TEST_FAIL("[path] does not have a valid icon for male variants")
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_f"))
				TEST_FAIL("[path] does not have a valid icon for female variants")
		else if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]"))
			TEST_FAIL("[path] does not have a valid icon")

/// Tests the height adjustment system which dynamically changes how much the chest, head, and arms of a carbon are adjusted upwards or downwards based on the length of their legs and chest.
/datum/unit_test/limb_height_adjustment

/datum/unit_test/limb_height_adjustment/Run()
	var/mob/living/carbon/human/john_doe = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/species/monkey/monkey = allocate(/mob/living/carbon/human/species/monkey)
	var/mob/living/carbon/human/tallboy = allocate(/mob/living/carbon/human/consistent)

	tallboy.set_species(/datum/species/human/tallboy)
	TEST_ASSERT_EQUAL(john_doe.get_top_offset(), 0, "John Doe found to have a top offset other than zero.")
	TEST_ASSERT_EQUAL(monkey.get_top_offset(), -8, "Monkey found to have a top offset other than -8.")
	TEST_ASSERT_EQUAL(tallboy.get_top_offset(), 23, "Tallboy human varient found to have a top offset other than 23.")


	var/obj/item/bodypart/leg/left/monkey/left_monky_leg = allocate(/obj/item/bodypart/leg/left/monkey)
	var/obj/item/bodypart/leg/right/monkey/right_monky_leg = allocate(/obj/item/bodypart/leg/right/monkey)

	left_monky_leg.replace_limb(john_doe, TRUE)

	TEST_ASSERT_EQUAL(john_doe.get_top_offset(), 0, "John Doe has a top offset other than 0 with one human leg and one monkey leg.")

	right_monky_leg.replace_limb(john_doe, TRUE)

	TEST_ASSERT_EQUAL(john_doe.get_top_offset(), -3, "John Doe has a top offset other than -3 with two monkey legs.")

