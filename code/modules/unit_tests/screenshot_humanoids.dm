/// A screenshot test for every humanoid species with a handful of jobs.
/datum/unit_test/screenshot_humanoids

/datum/unit_test/screenshot_humanoids/Run()
	var/list/testable_species = subtypesof(/datum/species)

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
	testable_species -= /datum/species/lizard

	// Test humans as naked so we can catch issues with bodypart layering
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/dummy/consistent)
	test_screenshot("[/datum/species/human]", get_flat_icon_for_all_directions(human))
	testable_species -= /datum/species/human

	// let me have this
	var/mob/living/carbon/human/moth = allocate(/mob/living/carbon/human/dummy/consistent)
	moth.dna.features["moth_antennae"] = "Firewatch"
	moth.dna.features["moth_markings"] = "None"
	moth.dna.features["moth_wings"] = "Firewatch"
	moth.set_species(/datum/species/moth)
	moth.equipOutfit(/datum/outfit/job/cmo, visuals_only = TRUE)
	test_screenshot("[/datum/species/moth]", get_flat_icon_for_all_directions(moth))
	testable_species -= /datum/species/moth

	// More in depth test for slimes since they have a lot going on
	for (var/datum/species/slime_type as anything in typesof(/datum/species/jelly))
		var/mob/living/carbon/human/slime = allocate(/mob/living/carbon/human/dummy/consistent)
		slime.dna.features["mcolor"] = COLOR_PINK
		slime.hairstyle = "Bob Hair 2"
		slime.hair_color = COLOR_RED // Should be forced to pink
		slime.set_species(slime_type)
		slime.equipOutfit(/datum/outfit/job/scientist/consistent)
		test_screenshot("[slime_type]", get_flat_icon_for_all_directions(slime))
		testable_species -= slime_type

	// The rest of the species
	for (var/datum/species/species_type as anything in testable_species)
		test_screenshot("[species_type]", get_flat_icon_for_all_directions(make_dummy(species_type, /datum/outfit/job/assistant/consistent)))

/datum/unit_test/screenshot_humanoids/proc/make_dummy(species, job_outfit)
	var/mob/living/carbon/human/dummy/consistent/dummy = allocate(/mob/living/carbon/human/dummy/consistent)
	dummy.set_species(species)
	dummy.equipOutfit(job_outfit, visuals_only = TRUE)
	return dummy
