/// Moves organs in and out of bodyparts, and moves the bodyparts around to see if someone didn't fuck up their movement
/datum/unit_test/organ_bodypart_shuffle

/datum/unit_test/organ_bodypart_shuffle/Run()
	var/mob/living/carbon/human/hollow_boy = allocate(/mob/living/carbon/human/consistent)

	// Test if organs are all properly updating when forcefully removed
	var/list/removed_organs = list()

	for(var/obj/item/organ/organ as anything in hollow_boy.organs)
		organ.moveToNullspace()
		removed_organs += organ

	for(var/obj/item/organ/organ as anything in removed_organs)
		TEST_ASSERT(!(organ in hollow_boy.organs), "Organ '[organ.name] remained inside human after forceMove into nullspace.")
		TEST_ASSERT(organ.loc == null, "Organ '[organ.name] did not move to nullspace after being forced to.")
		TEST_ASSERT(!(organ.owner), "Organ '[organ.name] kept reference to human after forceMove into nullspace.")
		TEST_ASSERT(!(organ.bodypart_owner), "Organ '[organ.name] kept reference to bodypart after forceMove into nullspace.")

	// Test if bodyparts are all properly updating when forcefully removed
	hollow_boy = allocate(/mob/living/carbon/human/consistent) //freshly filled with wet insides
	var/list/removed_bodyparts = list()

	for(var/obj/item/bodypart/bodypart as anything in hollow_boy.bodyparts)
		bodypart.forceMove(null)
		removed_bodyparts += bodypart

	for(var/obj/item/bodypart/bodypart as anything in removed_bodyparts)
		TEST_ASSERT(!(bodypart in hollow_boy), "Bodypart '[bodypart.name]' remained in human after forceMove into nullspace.")

		// Also check if our organs left the owner, as they SHOULD
		for(var/obj/item/organ/organ in bodypart)
			TEST_ASSERT(!(organ in hollow_boy), "Bodypart '[bodypart.name]' remained in human after bodypart was moved into nullspace.")
