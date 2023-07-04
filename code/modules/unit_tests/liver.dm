#define DAMAGE_AMOUNT 20
#define SECONDS_PER_TICK SSmobs.wait / 10

/datum/unit_test/liver
	abstract_type = /datum/unit_test/liver

/datum/unit_test/liver/skeleton/Run()
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/species/skeleton/mrbones = allocate(/mob/living/carbon/human/species/skeleton)
	var/datum/reagent/toxin/bonehurtingjuice/bonehurting = /datum/reagent/toxin/bonehurtingjuice
	var/datum/reagent/consumable/milk/calcium = /datum/reagent/consumable/milk

	TEST_ASSERT(!isnull(mrbones.get_organ_by_type(/obj/item/organ/liver/bone)), "Skeleton does not have a bone liver")
	TEST_ASSERT_EQUAL(mrbones.has_reagent(/datum/reagent/toxin/bonehurtingjuice), FALSE, "Skeleton somehow has bone hurting juice before drinking")
	TEST_ASSERT_EQUAL(mrbones.has_reagent(/datum/reagent/consumable/milk), FALSE, "Skeleton somehow has milk before drinking")

	// Test bone hurting juice reactions

	mrbones.reagents.add_reagent(bonehurting, 40)
	mrbones.Life(SSMOBS_DT)
	var/expected_stamina_damage = (7.5 * REM * SECONDS_PER_TICK)
	var/expected_brute_damage = (0.5 * REM * SECONDS_PER_TICK)

	TEST_ASSERT_EQUAL(mrbones.getStaminaLoss(), expected_stamina_damage,
		"Skeleton took [mrbones.getStaminaLoss() > expected_stamina_damage ? "more" : "less"] stamina damage than expected")
	TEST_ASSERT_EQUAL(mrbones.getBruteLoss(), expected_brute_damage,
		"Skeleton took [mrbones.getBruteLoss() > expected_brute_damage ? "more" : "less"] brute damage than expected")

	mrbones.reagents.remove_all(mrbones.reagents.total_volume)
	mrbones.fully_heal()
	TEST_ASSERT_EQUAL(mrbones.getStaminaLoss(), 0, "Skeleton did not fully heal stamina damage")
	TEST_ASSERT_EQUAL(mrbones.getBruteLoss(), 0, "Skeleton did not fully heal brute damage")

	// Test milk reactions

	mrbones.reagents.add_reagent(calcium, 51)
	mrbones.Life(SSMOBS_DT)
	TEST_ASSERT(mrbones.reagents.total_volume < 50, "Excess (>50u) milk did not leak out of skeleton")
	mrbones.reagents.remove_all(mrbones.reagents.total_volume)

	mrbones.apply_damage(DAMAGE_AMOUNT, def_zone = BODY_ZONE_CHEST)
	var/list/obj/item/bodypart/damaged_parts = mrbones.get_damaged_bodyparts(brute = TRUE)
	TEST_ASSERT(!isnull(damaged_parts), "Skeleton did not take any damage")
	TEST_ASSERT(length(damaged_parts) == 1, "Skeleton took damage to more than one body part")

	mrbones.reagents.add_reagent(calcium, 50)
	mrbones.Life(SSMOBS_DT)
	var/expected_remaining_damage = DAMAGE_AMOUNT - (2.5 * REM * SECONDS_PER_TICK)
	// Milk also heals brute on its own, so we may be more healed than expected
	TEST_ASSERT(damaged_parts[1].brute_dam <= expected_remaining_damage,
		"Milk did not heal the expected amount of damage (expected at least [expected_remaining_damage], got [damaged_parts[1].brute_dam])")

/datum/unit_test/liver/skeleton/Destroy()
	SSmobs.ignite()
	return ..()

// Plasmamen
/datum/unit_test/liver/plasmaman/Run()
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/species/plasma/mrbones = allocate(/mob/living/carbon/human/species/plasma)
	var/datum/reagent/toxin/plasma/plasma = /datum/reagent/toxin/plasma
	var/datum/reagent/toxin/hot_ice/hot_ice = /datum/reagent/toxin/hot_ice

	// Testing plasma/hot ice healing on wounds

	TEST_ASSERT(!isnull(mrbones.get_organ_by_type(/obj/item/organ/liver/bone/plasmaman)), "Plasmaman does not have a plasmaman bone liver")
	TEST_ASSERT_EQUAL(mrbones.has_reagent(plasma), FALSE, "Plasmaman somehow has plasma before drinking")
	TEST_ASSERT_EQUAL(mrbones.has_reagent(hot_ice), FALSE, "Plasmaman somehow has hot ice before drinking")

	var/obj/item/bodypart/r_arm = mrbones.get_bodypart(BODY_ZONE_R_ARM)
	var/obj/item/bodypart/l_arm = mrbones.get_bodypart(BODY_ZONE_L_ARM)
	var/expected_wound_healing = 4 * REM * SECONDS_PER_TICK

	// Test plasma

	r_arm.receive_damage(WOUND_MINIMUM_DAMAGE, 0, wound_bonus = 100, sharpness = NONE)
	TEST_ASSERT(length(mrbones.all_wounds), "Plasmaman did not receive a wound on their right arm")

	mrbones.reagents.add_reagent(plasma, 50)
	mrbones.Life(SSMOBS_DT)
	var/datum/wound/afflicted_wound = mrbones.all_wounds[1]
	TEST_ASSERT_EQUAL(afflicted_wound.cryo_progress, expected_wound_healing, "Plasma did not reduce wound on plasmaman")

	mrbones.reagents.remove_all(mrbones.reagents.total_volume)
	mrbones.fully_heal()
	TEST_ASSERT(!length(r_arm.wounds), "Plasmaman did not fully heal wounds")

	// Test hot ice

	l_arm.receive_damage(WOUND_MINIMUM_DAMAGE, 0, wound_bonus = 100, sharpness = NONE)
	TEST_ASSERT(length(mrbones.all_wounds), "Plasmaman did not receive a wound on their left arm")

	afflicted_wound = mrbones.all_wounds[1]
	mrbones.reagents.add_reagent(hot_ice, 50)
	mrbones.Life(SSMOBS_DT)
	TEST_ASSERT_EQUAL(afflicted_wound.cryo_progress, expected_wound_healing, "Hot ice did not reduce wound on plasmaman")

	// Test gunpowder giving plasmamen hallucinations

	var/datum/reagent/gunpowder/gunpowder = /datum/reagent/gunpowder

	mrbones.reagents.add_reagent(gunpowder, 50)
	mrbones.Life(SSMOBS_DT)
	TEST_ASSERT(mrbones.has_status_effect(/datum/status_effect/drugginess), "Plasmaman did not get druggy status after consuming gunpowder")
	TEST_ASSERT(mrbones.has_status_effect(/datum/status_effect/hallucination), "Plasmaman did not get hallucinating status after consuming gunpowder")

/datum/unit_test/liver/plasmaman/Destroy()
	SSmobs.ignite()
	return ..()

#undef DAMAGE_AMOUNT
#undef SECONDS_PER_TICK
