/// This test is used to make sure a flesh-and-bone base human can suffer all the types of wounds, and that suffering more severe wounds removes and replaces the lesser wound. Also tests that [/mob/living/carbon/proc/fully_heal] removes all wounds
/datum/unit_test/test_human_base/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)

	/// the limbs have no wound resistance like the chest and head do, so let's go with the r_arm
	var/obj/item/bodypart/tested_part = victim.get_bodypart(BODY_ZONE_R_ARM)
	/// In order of the wound types we're trying to inflict, what sharpness do we need to deal them?
	var/list/sharps = list(SHARP_NONE, SHARP_EDGED, SHARP_POINTY, SHARP_NONE)
	/// Since burn wounds need burn damage, duh
	var/list/dam_types = list(BRUTE, BRUTE, BRUTE, BURN)

	var/i = 1
	var/list/iter_test_wound_list

	for(iter_test_wound_list in list(list(/datum/wound/blunt/moderate, /datum/wound/blunt/severe, /datum/wound/blunt/critical),\
										list(/datum/wound/slash/moderate, /datum/wound/slash/severe, /datum/wound/slash/critical),\
										list(/datum/wound/pierce/moderate, /datum/wound/pierce/severe, /datum/wound/pierce/critical),\
										list(/datum/wound/burn/moderate, /datum/wound/burn/severe, /datum/wound/burn/critical)))

		TEST_ASSERT_EQUAL(length(victim.all_wounds), 0, "Patient is somehow wounded before test")
		var/datum/wound/iter_test_wound
		var/threshold_penalty = 0

		for(iter_test_wound in iter_test_wound_list)
			var/threshold = initial(iter_test_wound.threshold_minimum) - threshold_penalty // just enough to guarantee the next tier of wound, given the existing wound threshold penalty
			if(dam_types[i] == BRUTE)
				tested_part.receive_damage(WOUND_MINIMUM_DAMAGE, 0, wound_bonus = threshold, sharpness=sharps[i])
			else if(dam_types[i] == BURN)
				tested_part.receive_damage(0, WOUND_MINIMUM_DAMAGE, wound_bonus = threshold, sharpness=sharps[i])

			TEST_ASSERT(length(victim.all_wounds), "Patient has no wounds when one wound is expected. Severity: [initial(iter_test_wound.severity)]")
			TEST_ASSERT_EQUAL(length(victim.all_wounds), 1, "Patient has more than one wound when only one is expected. Severity: [initial(iter_test_wound.severity)]")
			var/datum/wound/actual_wound = victim.all_wounds[1]
			TEST_ASSERT_EQUAL(actual_wound.type, iter_test_wound, "Patient has wound of incorrect severity. Expected: [initial(iter_test_wound.name)] Got: [actual_wound]")
			threshold_penalty = actual_wound.threshold_penalty
		i++
		victim.fully_heal(TRUE) // should clear all wounds between types


/// This test is used for making sure species with bones but no flesh (skeletons, plasmamen) can only suffer BONE_WOUNDS, and nothing tagged with FLESH_WOUND (it's possible to require both)
/datum/unit_test/test_human_bone/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)

	/// the limbs have no wound resistance like the chest and head do, so let's go with the r_arm
	var/obj/item/bodypart/tested_part = victim.get_bodypart(BODY_ZONE_R_ARM)
	/// In order of the wound types we're trying to inflict, what sharpness do we need to deal them?
	var/list/sharps = list(SHARP_NONE, SHARP_EDGED, SHARP_POINTY, SHARP_NONE)
	/// Since burn wounds need burn damage, duh
	var/list/dam_types = list(BRUTE, BRUTE, BRUTE, BURN)

	var/i = 1
	var/list/iter_test_wound_list
	victim.dna.species.species_traits &= HAS_FLESH // take away the base human's flesh (ouchie!) ((not actually ouchie, this just affects their wounds and dismemberment handling))

	for(iter_test_wound_list in list(list(/datum/wound/blunt/moderate, /datum/wound/blunt/severe, /datum/wound/blunt/critical),\
										list(/datum/wound/slash/moderate, /datum/wound/slash/severe, /datum/wound/slash/critical),\
										list(/datum/wound/pierce/moderate, /datum/wound/pierce/severe, /datum/wound/pierce/critical),\
										list(/datum/wound/burn/moderate, /datum/wound/burn/severe, /datum/wound/burn/critical)))

		TEST_ASSERT_EQUAL(length(victim.all_wounds), 0, "Patient is somehow wounded before test")
		var/datum/wound/iter_test_wound
		var/threshold_penalty = 0

		for(iter_test_wound in iter_test_wound_list)
			var/threshold = initial(iter_test_wound.threshold_minimum) - threshold_penalty // just enough to guarantee the next tier of wound, given the existing wound threshold penalty
			if(dam_types[i] == BRUTE)
				tested_part.receive_damage(WOUND_MINIMUM_DAMAGE, 0, wound_bonus = threshold, sharpness=sharps[i])
			else if(dam_types[i] == BURN)
				tested_part.receive_damage(0, WOUND_MINIMUM_DAMAGE, wound_bonus = threshold, sharpness=sharps[i])

			// so if we just tried to deal a flesh wound, make sure we didn't actually suffer it. We may have suffered a bone wound instead, but we just want to make sure we don't have a flesh wound
			if(initial(iter_test_wound.wound_flags) & FLESH_WOUND)
				if(!length(victim.all_wounds)) // not having a wound is good news
					continue
				else // we have to check that it's actually a bone wound and not the intended wound type
					TEST_ASSERT_EQUAL(length(victim.all_wounds), 1, "Patient has more than one wound when only one is expected. Severity: [initial(iter_test_wound.severity)]")
					var/datum/wound/actual_wound = victim.all_wounds[1]
					TEST_ASSERT((actual_wound.wound_flags & ~FLESH_WOUND), "Patient has flesh wound despite no HAS_FLESH flag, expected either no wound or bone wound. Offending wound: [actual_wound]")
					threshold_penalty = actual_wound.threshold_penalty
			else // otherwise if it's a bone wound, check that we have it per usual
				TEST_ASSERT(length(victim.all_wounds), "Patient has no wounds when one wound is expected. Severity: [initial(iter_test_wound.severity)]")
				TEST_ASSERT_EQUAL(length(victim.all_wounds), 1, "Patient has more than one wound when only one is expected. Severity: [initial(iter_test_wound.severity)]")
				var/datum/wound/actual_wound = victim.all_wounds[1]
				TEST_ASSERT_EQUAL(actual_wound.type, iter_test_wound, "Patient has wound of incorrect severity. Expected: [initial(iter_test_wound.name)] Got: [actual_wound]")
				threshold_penalty = actual_wound.threshold_penalty
		i++
		victim.fully_heal(TRUE) // should clear all wounds between types
