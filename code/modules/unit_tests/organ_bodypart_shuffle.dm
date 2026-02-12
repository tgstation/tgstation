/// Moves organs in and out of bodyparts, and moves the bodyparts around to see if someone didn't fuck up their movement
/datum/unit_test/organ_bodypart_shuffle

/datum/unit_test/organ_bodypart_shuffle/Run()
	var/mob/living/carbon/human/hollow_boy = allocate(/mob/living/carbon/human/consistent) //freshly filled with wet insides

	// Test if organs are all properly updating when forcefully removed
	var/list/removed_organs = list()

	// 1. remove all the organs from the mob
	for(var/obj/item/organ/organ as anything in hollow_boy.organs)
		organ.moveToNullspace()
		removed_organs += organ

	// 2. ensure removed organs proper disassociate from the mob and the bodypart
	for(var/obj/item/organ/organ as anything in removed_organs)
		TEST_ASSERT(!(organ in hollow_boy.organs), "Organ '[organ.name] remained inside human after forceMove into nullspace.")
		TEST_ASSERT_NULL(organ.loc, "Organ '[organ.name] did not move to nullspace after being forced to.")
		TEST_ASSERT_NULL(organ.owner, "Organ '[organ.name] kept reference to human after forceMove into nullspace.")
		TEST_ASSERT_NULL(organ.bodypart_owner, "Organ '[organ.name] kept reference to bodypart after forceMove into nullspace.")

	// 3. replace all bodyparts with new ones and place the previously removed organs into the new bodyparts
	for(var/obj/item/bodypart/bodypart as anything in hollow_boy.bodyparts)
		var/obj/item/bodypart/replacement = allocate(bodypart.type)
		for(var/obj/item/organ/organ as anything in removed_organs)
			if(replacement.body_zone != deprecise_zone(organ.zone))
				continue
			organ.bodypart_insert(replacement)
		if(!replacement.replace_limb(hollow_boy))
			TEST_FAIL("Failed to replace [replacement] with a new one of the same type.")
		qdel(bodypart) // it's been replaced, clean up

	// 4. ensure organs are properly associated with the new bodyparts and the mob
	for(var/obj/item/organ/organ as anything in removed_organs)
		TEST_ASSERT(organ in hollow_boy.organs, "Organ '[organ.name] was put in an empty bodypart that replaced a humans, but the organ did not come with.")
		TEST_ASSERT(organ.owner == hollow_boy, "Organ '[organ.name]'s owner was not properly updated to the new human after being placed in a replacement bodypart.")
		TEST_ASSERT(organ.bodypart_owner in hollow_boy.bodyparts, "Organ '[organ.name]'s bodypart_owner was not properly updated to the new bodypart after being placed in a replacement bodypart.")
