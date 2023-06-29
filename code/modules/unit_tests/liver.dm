#define DAMAGE_AMOUNT 20

/datum/unit_test/milk_healing/Run()
	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/species/skeleton/mrbones = allocate(/mob/living/carbon/human/species/skeleton)
	var/datum/reagent/consumable/milk/calcium = /datum/reagent/consumable/milk

	TEST_ASSERT(!isnull(mrbones.get_organ_by_type(/obj/item/organ/internal/liver/bone)), "Skeleton does not have a bone liver")
	TEST_ASSERT_EQUAL(mrbones.has_reagent(/datum/reagent/consumable/milk), FALSE, "Skeleton somehow has milk before drinking")

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
	var/expected_healed_amount = DAMAGE_AMOUNT - (2.5 * REM * (SSmobs.wait / 10)) // = seconds_per_tick
	// Milk also heals brute on its own, so we may be more healed than expected
	TEST_ASSERT(damaged_parts[1].brute_dam >= expected_healed_amount,
		"Milk did not heal the expected amount of damage (expected at least [expected_healed_amount], got [damaged_parts[1].brute_dam])")

#undef DAMAGE_AMOUNT

/datum/unit_test/milk_healing/Destroy()
	SSmobs.ignite()
	return ..()
