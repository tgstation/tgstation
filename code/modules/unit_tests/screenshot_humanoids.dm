/// A screenshot test for every humanoid species with a handful of jobs.
/datum/unit_test/screenshot_humanoids

/datum/unit_test/screenshot_humanoids/Run()
	// Test lizards as their own thing so we can get more coverage on their features
	var/mob/living/carbon/human/lizard = allocate(/mob/living/carbon/human/dummy/consistent)
	lizard.dna.features["mcolor"] = "#099"
	lizard.dna.features["tail_lizard"] = "Light Tiger"
	lizard.dna.features["snout"] = "Sharp + Light"
	lizard.dna.features["horns"] = "Simple"
	lizard.dna.features["frills"] = "Aquatic"
	lizard.dna.features["legs"] = "Normal Legs"
	lizard.set_species(/datum/species/lizard)
	lizard.equipOutfit(/datum/outfit/job/engineer)
	test_screenshot("[/datum/species/lizard]", get_flat_icon_for_all_directions(lizard))

	// let me have this
	var/mob/living/carbon/human/moth = allocate(/mob/living/carbon/human/dummy/consistent)
	moth.dna.features["moth_antennae"] = "Firewatch"
	moth.dna.features["moth_markings"] = "None"
	moth.dna.features["moth_wings"] = "Firewatch"
	moth.set_species(/datum/species/moth)
	moth.equipOutfit(/datum/outfit/job/cmo, visualsOnly = TRUE)
	test_screenshot("[/datum/species/moth]", get_flat_icon_for_all_directions(moth))

	// The rest of the species
	for (var/datum/species/species_type as anything in subtypesof(/datum/species) - /datum/species/moth - /datum/species/lizard)
		test_screenshot("[species_type]", get_flat_icon_for_all_directions(make_dummy(species_type, /datum/outfit/job/assistant/consistent)))

/datum/unit_test/screenshot_humanoids/proc/make_dummy(species, job_outfit)
	var/mob/living/carbon/human/dummy/consistent/dummy = allocate(/mob/living/carbon/human/dummy/consistent)
	dummy.set_species(species)
	dummy.equipOutfit(job_outfit, visualsOnly = TRUE)
	return dummy
