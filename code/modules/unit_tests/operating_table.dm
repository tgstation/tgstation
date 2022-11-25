/// Make a mob hop on an optable, rest, get up, rest again, and then move to another tile.
/// While the mob is still an active patient, move another mob in too.
/// This is so the replacement code can kick in when the original mob is no longer valid.
/datum/unit_test/operating_table

/datum/unit_test/operating_table/Run()
	var/obj/structure/table/optable/table = allocate(/obj/structure/table/optable)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, get_step(table, NORTH))
	var/mob/living/carbon/human/replacement_human = allocate(/mob/living/carbon/human/consistent, get_step(table, NORTH))

	// Resting is a bit more high level than bodypos, gets us nicer coverage.
	human.set_resting(new_resting = FALSE, instant = TRUE)
	replacement_human.set_resting(new_resting = FALSE, instant = TRUE)

	human.forceMove(get_turf(table))
	TEST_ASSERT_NULL(table.patient, "Operating table is occupied by a non-resting patient.")

	human.set_resting(new_resting = TRUE, instant = TRUE)
	TEST_ASSERT_EQUAL(table.patient, human, "Operating table failed to update for a resting patient.")

	human.set_resting(new_resting = FALSE, instant = TRUE)
	TEST_ASSERT_NULL(table.patient, "Operating table is occupied by a non-resting patient.")

	human.set_resting(new_resting = TRUE, instant = TRUE)
	TEST_ASSERT_EQUAL(table.patient, human, "Operating table failed to update for a resting patient.")

	replacement_human.forceMove(get_turf(table))
	replacement_human.set_resting(new_resting = TRUE, instant = TRUE)
	TEST_ASSERT_EQUAL(table.patient, human, "Operating table patient unset by another patient jumping in.")

	human.forceMove(get_step(get_turf(table), NORTH))
	TEST_ASSERT_EQUAL(table.patient, replacement_human, "Operating table failed to find a replacement patient.")
