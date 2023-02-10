/datum/unit_test/limbsanity

/datum/unit_test/limbsanity/Run()
	for(var/path in subtypesof(/obj/item/bodypart) - list(/obj/item/bodypart/arm, /obj/item/bodypart/leg)) /// removes the abstract items.
		var/obj/item/bodypart/part = new path(null)
		if(part.is_dimorphic)
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_m"))
				Fail("[path] does not have a valid icon for male variants")
			if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]_f"))
				Fail("[path] does not have a valid icon for female variants")
		else if(!icon_exists(UNLINT(part.should_draw_greyscale ? part.icon_greyscale : part.icon_static), "[part.limb_id]_[part.body_zone]"))
			Fail("[path] does not have a valid icon")

/datum/unit_test/limb_hight_adjustment

/datum/unit_test/limb_hight_adjustment/Run()
	var/mob/living/carbon/human/john_doe = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/species/monkey/monkey = allocate(/mob/living/carbon/human/species/monkey)
	var/mob/living/carbon/human/species/tallboy/tallboy = allocate(/mob/living/carbon/human/species/tallboy)
	var/mob/living/carbon/human/mad_surgeon = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT_EQUAL(john_doe.get_top_offset(), 0, "John Doe found to have a top offset other than zero.")
	TEST_ASSERT_EQUAL(monkey.get_top_offset(), -8, "Monkey found to have a top offset other than -8.")
	TEST_ASSERT_EQUAL(tallboy.get_top_offset(), 23, "Tallboy human varient found to have a top offset other than 23.")

	var/datum/surgery/amputation/left_leg_amputation = new(john_doe, BODY_ZONE_L_LEG, john_doe.get_bodypart(BODY_ZONE_L_LEG))

	var/datum/surgery_step/sever_limb/sever_limb_left = new
	sever_limb_left.success(mad_surgeon, john_doe, BODY_ZONE_L_ARM, null, left_leg_amputation)

	var/obj/item/bodypart/leg/left/monkey/left_monky_leg = allocate(/obj/item/bodypart/leg/left/monkey)
	if(!left_monky_leg.try_attach_limb(john_doe))
		Fail("Unable to attach monkey leg to John Doe")
	TEST_ASSERT_EQUAL(john_doe.get_top_offset(), 0, "John Doe has a top offset other than 0 with one human leg and one monkey leg.")

	var/datum/surgery/amputation/right_leg_amputation = new(john_doe, BODY_ZONE_R_LEG, john_doe.get_bodypart(BODY_ZONE_R_LEG))

	var/datum/surgery_step/sever_limb/sever_limb_right = new
	sever_limb_right.success(mad_surgeon, john_doe, BODY_ZONE_R_ARM, null, right_leg_amputation)

	TEST_ASSERT_EQUAL(john_doe.get_top_offset(), -3, "John Doe has a top offset other than -3 with one monkey leg.")
