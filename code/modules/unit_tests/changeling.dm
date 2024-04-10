/// Tests transformation sting goes back and forth correctly
/datum/unit_test/transformation_sting
	var/ling_name = "Is-A-Changeling"
	var/base_victim_name
	var/last_frame = 1
	var/icon/final_icon

/datum/unit_test/transformation_sting/Run()
	var/mob/living/carbon/human/ling = setup_ling()
	var/mob/living/carbon/human/victim = setup_victim()
	var/datum/antagonist/changeling/ling_datum = IS_CHANGELING(ling)

	// Get the ability we're testing
	ling_datum.purchase_power(/datum/action/changeling/sting/transformation)
	var/datum/action/changeling/sting/transformation/sting_action = locate() in ling.actions
	sting_action.selected_dna = ling_datum.current_profile
	sting_action.sting_duration = 0.5 SECONDS // just makes sure everything settles.

	// Check that they look different before stinging
	add_to_screenshot(ling, victim, both_species = TRUE)

	// Do the sting, make the transformation
	sting_action.sting_action(ling, victim)
	// Check their name and species align
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/temporary_transformation), "Victim did not get temporary transformation status effect on being transformation stung.")
	TEST_ASSERT_EQUAL(victim.real_name, ling_name, "Victim real name did not change on being transformation stung.")
	TEST_ASSERT_EQUAL(victim.name, ling_name, "Victim name did not change on being transformation stung.")
	TEST_ASSERT_EQUAL(victim.dna.species.type, ling.dna.species.type, "Victim species did not change on being transformation stung.")
	TEST_ASSERT_EQUAL(victim.dna.features["mcolor"], ling.dna.features["mcolor"], "Victim mcolor did not change on being transformation stung.")
	// Check they actually look the same
	add_to_screenshot(ling, victim)

	// Make sure we give it enough time such that the status effect process ticks over and finishes
	sleep(sting_action.sting_duration + 0.5 SECONDS)

	// Check their name and species reset correctly
	TEST_ASSERT_EQUAL(victim.name, base_victim_name, "Victim name did not change back after transformation sting expired.")
	TEST_ASSERT_EQUAL(victim.real_name, base_victim_name, "Victim real name did not change back after transformation sting expired.")
	TEST_ASSERT_NOTEQUAL(victim.dna.species.type, ling.dna.species.type, "Victim species did not change back after transformation sting expired.")
	TEST_ASSERT_NOTEQUAL(victim.dna.features["mcolor"], ling.dna.features["mcolor"], "Victim mcolor did not reset after transformation sting expired.")
	// Check they actually look different again
	add_to_screenshot(ling, victim, both_species = TRUE)

	test_screenshot("appearances", final_icon)

/// Adds both mobs to the screenshot test, if both_species is TRUE, it also adds the victim in lizard form
/datum/unit_test/transformation_sting/proc/add_to_screenshot(mob/living/carbon/human/ling, mob/living/carbon/human/victim, both_species = FALSE)
	if(isnull(final_icon))
		final_icon = icon('icons/effects/effects.dmi', "nothing")

	// If we have a lot of dna features with a lot of parts (icons)
	// This'll eventually runtime into a bad icon operation
	// So we're recaching the icons here to prevent it from failing
	final_icon = icon(final_icon)
	final_icon.Insert(getFlatIcon(ling, no_anim = TRUE), dir = SOUTH, frame = last_frame)
	final_icon.Insert(getFlatIcon(victim, no_anim = TRUE), dir = NORTH, frame = last_frame)

	if(both_species)
		var/prior_species = victim.dna.species.type
		victim.set_species(/datum/species/lizard)
		final_icon.Insert(getFlatIcon(victim, no_anim = TRUE), dir = EAST, frame = last_frame)
		victim.set_species(prior_species)

	last_frame += 1

/datum/unit_test/transformation_sting/proc/setup_victim()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	base_victim_name = victim.real_name
	victim.mind_initialize()
	return victim

/datum/unit_test/transformation_sting/proc/setup_ling()
	var/mob/living/carbon/human/ling = allocate(/mob/living/carbon/human/consistent)
	// Because we use two consistent humans, we need to change some of the features to know they're actually updating to new values.
	// The more DNA features and random things we change, the more likely we are to catch something not updating correctly.
	// Yeah guess who/what this is, I dare you.
	ling.dna.features["mcolor"] = "#886600"
	ling.dna.features["tail_lizard"] = "Smooth"
	ling.dna.features["snout"] = "Sharp + Light"
	ling.dna.features["horns"] = "Curled"
	ling.dna.features["frills"] = "Short"
	ling.dna.features["spines"] = "Long + Membrane"
	ling.dna.features["body_markings"] = "Light Belly"
	ling.dna.features["legs"] = DIGITIGRADE_LEGS
	ling.eye_color_left = COLOR_WHITE
	ling.eye_color_right = COLOR_WHITE
	ling.dna.update_ui_block(DNA_EYE_COLOR_LEFT_BLOCK)
	ling.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)
	ling.set_species(/datum/species/lizard)

	ling.real_name = ling_name
	ling.dna.real_name = ling_name
	ling.name = ling_name
	ling.dna.initialize_dna(create_mutation_blocks = FALSE, randomize_features = FALSE)

	ling.mind_initialize()
	ling.mind.add_antag_datum(/datum/antagonist/changeling)

	return ling
