/// Moves organs in and out of bodyparts, and moves the bodyparts around to see if someone didn't fuck up their movement
/datum/unit_test/organ_bodypart_shuffle

/datum/unit_test/organ_bodypart_shuffle/Run()
	var/mob/living/carbon/human/hollow_boy = allocate(/mob/living/carbon/human/consistent) //freshly filled with wet insides

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

	for(var/obj/item/bodypart/bodypart as anything in hollow_boy.bodyparts)
		bodypart = new bodypart.type() //fresh, duplice bodypart with no insides
		for(var/obj/item/organ/organ as anything in removed_organs)
			if(bodypart.body_zone != deprecise_zone(organ.zone))
				continue
			organ.bodypart_insert(bodypart) // Put all the old organs back in
		bodypart.replace_limb(hollow_boy) //so stick new bodyparts on them with their old organs
		// Check if, after we put the old organs in a new limb, and after we put that new limb on the mob, if the organs came with
		for(var/obj/item/organ/organ as anything in removed_organs) //technically readded organ now
			if(bodypart.body_zone != deprecise_zone(organ.zone))
				continue
			TEST_ASSERT(organ in hollow_boy.organs, "Organ '[organ.name] was put in an empty bodypart that replaced a humans, but the organ did not come with.")

