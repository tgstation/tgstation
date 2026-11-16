/// Tests debrained overlay. And also eyeless since we're here
/datum/unit_test/screenshot_debrain
	var/last_frame = 1

/datum/unit_test/screenshot_debrain/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/dummy/consistent)
	var/obj/item/organ/brain/their_brain = human.get_organ_by_type(__IMPLIED_TYPE__)
	var/obj/item/organ/eyes/their_eyes = human.get_organ_by_type(__IMPLIED_TYPE__)
	human.set_hairstyle(/datum/sprite_accessory/hair/bedheadv4::name)
	human.set_facial_hairstyle(/datum/sprite_accessory/facial_hair/vlongbeard::name)
	human.set_haircolor(COLOR_BLACK)
	human.set_facial_haircolor(COLOR_BLACK)

	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	// record pre-test appearance
	final_icon.Insert(getFlatIcon(human, no_anim = TRUE), dir = SOUTH, frame = 1)

	// remove brain, record appearance
	their_brain.Remove(human)
	final_icon.Insert(getFlatIcon(human, no_anim = TRUE), dir = NORTH, frame = 1)

	// remove eyes, record appearance
	their_eyes.Remove(human)
	final_icon.Insert(getFlatIcon(human, no_anim = TRUE), dir = EAST, frame = 1)

	// re-add organs, record appearance
	their_brain.Insert(human)
	their_eyes.Insert(human)
	final_icon.Insert(getFlatIcon(human, no_anim = TRUE), dir = WEST, frame = 1)

	// test the final screenshot
	test_screenshot("head_organs", final_icon)
