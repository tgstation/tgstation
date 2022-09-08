/// A screenshot test for making sure invisible limbs function, keeping them clothed so we know they're there.
/datum/unit_test/screenshot_saturnx

/datum/unit_test/screenshot_saturnx/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human) //we don't use a dummy as they have no organs
	human.equipOutfit(/datum/outfit/job/assistant/consistent, visualsOnly = TRUE)

	var/datum/reagent/drug/saturnx/saturnx_reagent = new()

	saturnx_reagent.expose_atom(human, 15)
	saturnx_reagent.turn_man_invisible(human) //immediately turn us invisible

	test_screenshot("invisibility", get_flat_icon_for_all_directions(human))

/datum/unit_test/screenshot_saturnx/proc/get_flat_icon_for_all_directions(atom/thing)
	var/icon/output = icon('icons/effects/effects.dmi', "nothing")
	COMPILE_OVERLAYS(thing)

	for (var/direction in GLOB.cardinals)
		var/icon/partial = getFlatIcon(thing, defdir = direction, no_anim = TRUE)
		output.Insert(partial, dir = direction)

	return output
