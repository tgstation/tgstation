/datum/unit_test/screenshot_hair_gradient

/datum/unit_test/screenshot_hair_gradient/Run()
	// Check if hair gradients render properly
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/dummy/consistent)
	human.set_hairstyle(/datum/sprite_accessory/hair/bedheadv4::name)
	human.set_haircolor(COLOR_BLACK)
	human.set_hair_gradient_color(COLOR_PINK)
	human.set_hair_gradient_style(/datum/sprite_accessory/gradient/reflected_inverse::name)
	test_screenshot("hair_gradient", getFlatIcon(human, no_anim = TRUE, defdir = SOUTH))

	// Now check it on an ethereal for hair alpha
	var/mob/living/carbon/human/ethereal = allocate(/mob/living/carbon/human/dummy/consistent)
	ethereal.set_species(/datum/species/ethereal)
	ethereal.set_hairstyle(/datum/sprite_accessory/hair/bedheadv4::name)
	ethereal.set_hair_gradient_color(COLOR_PINK)
	ethereal.set_hair_gradient_style(/datum/sprite_accessory/gradient/reflected_inverse::name)
	test_screenshot("hair_gradient_ethereal", getFlatIcon(ethereal, no_anim = TRUE, defdir = SOUTH))
