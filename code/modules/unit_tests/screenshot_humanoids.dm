/// A screenshot test for a handful of humanoids with a handful of jobs.
/// In the future, when there is an automatic way to commit screenshot diffs,
/// this should cover every species.
/datum/unit_test/screenshot_humanoids

TEST_FOCUS(/datum/unit_test/screenshot_humanoids)

/datum/unit_test/screenshot_humanoids/Run()
	test_screenshot("human", get_flat_icon_for_all_directions(make_dummy(/datum/species/human, /datum/outfit/job/assistant/consistent)))
	test_screenshot("lizard", get_flat_icon_for_all_directions(make_dummy(/datum/species/lizard, /datum/outfit/job/engineer)))

	// let me have this
	var/mob/living/carbon/human/moth = make_dummy(/datum/species/moth, /datum/outfit/job/cmo)
	moth.dna.features["moth_antennae"] = "Firewatch"
	moth.dna.features["moth_markings"] = "None"
	moth.dna.features["moth_wings"] = "Firewatch"
	moth.set_species(/datum/species/moth) // remove this when you can just set a feature without some lame brain stuff

	test_screenshot("moth", get_flat_icon_for_all_directions(moth))

/datum/unit_test/screenshot_humanoids/proc/get_flat_icon_for_all_directions(atom/thing)
	var/icon/output = icon('icons/effects/effects.dmi', "nothing")
	COMPILE_OVERLAYS(thing)

	for (var/direction in GLOB.cardinals)
		var/icon/partial = getFlatIcon(thing, defdir = direction)
		output.Insert(partial, dir = direction)

	return output

/datum/unit_test/screenshot_humanoids/proc/make_dummy(species, job_outfit)
	var/mob/living/carbon/human/dummy/consistent/dummy = allocate(/mob/living/carbon/human/dummy/consistent)
	dummy.set_species(species)
	dummy.equipOutfit(job_outfit, visualsOnly = TRUE)
	return dummy
