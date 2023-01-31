#define ORGAN_INSERTED_OK(lab_rat, test_organ) ((test_organ.owner == lab_rat) && (test_organ in lab_rat.internal_organs) && test_organ.slot ? (lab_rat.getorganslot(test_organ.slot) == test_organ) : TRUE)
#define ORGAN_REMOVED_OK(lab_rat, test_organ) ((test_organ.owner == null) && !(test_organ in lab_rat.internal_organs) && test_organ.slot ? (lab_rat.getorganslot(test_organ.slot) != test_organ) : TRUE)
/// List of organ typepaths which are class prototypes.
/// These organs aren't usable in-game, they are used only to create subclasses.
#define ORGAN_PROTOTYPES list(\
	/obj/item/organ/internal,\
	/obj/item/organ/external,\
	/obj/item/organ/external/wings,\
	/obj/item/organ/internal/cyberimp,\
	/obj/item/organ/internal/cyberimp/brain,\
	/obj/item/organ/internal/cyberimp/mouth,\
	/obj/item/organ/internal/cyberimp/arm,\
	/obj/item/organ/internal/cyberimp/chest,\
	/obj/item/organ/internal/cyberimp/eyes,\
	/obj/item/organ/internal/alien,\
)

/// Sanity-check organ insertion and removal, for all organ subtypes usable in-game.
/datum/unit_test/organ_sanity/Run()
	for(var/obj/item/organ/test_organ as anything in subtypesof(/obj/item/organ))
		// Skip prototypes.
		if(test_organ in ORGAN_PROTOTYPES)
			continue

		// Human which will receive organ.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		test_organ = new test_organ()
		// Insert organ and store status code in var.
		var/inserted_ok = test_organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)

		// Expects status code 1
		if(!inserted_ok)
			TEST_FAIL("The organ \"[test_organ.type]\" was not inserted in the mob when expected, Insert() returned FALSE when TRUE was expected.")
			continue

		// Inserting Nightmare brain causes the Human's species to change.
		// Species change swaps out all the organs, making test_organ un-usable by this point.
		if(test_organ.type == /obj/item/organ/internal/brain/shadow/nightmare)
			continue

		// Check vars on Human and organ, they are expected to be present after Insert().
		if(!ORGAN_INSERTED_OK(lab_rat, test_organ))
			TEST_FAIL("The organ \"[test_organ.type]\" was not properly inserted in the mob, some variables were not assigned when expected.")
			continue

		// Now yank it back out.
		// Check vars on Human and organ, they are expected to be deleted after Remove().
		test_organ.Remove(lab_rat, special = TRUE)
		if(!ORGAN_REMOVED_OK(lab_rat, test_organ))
			TEST_FAIL("The organ \"[test_organ.type]\" was not properly removed from the mob, some variables were not reset when expected.")

#undef ORGAN_INSERTED_OK
#undef ORGAN_REMOVED_OK
#undef ORGAN_PROTOTYPES
