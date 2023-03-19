#define TEST_ORGAN_INSERT_MESSAGE(test_organ, message) "`[test_organ.type]/Insert()` [message]"
#define TEST_ORGAN_REMOVE_MESSAGE(test_organ, message) "`[test_organ.type]/Remove()` [message]"

/// Check organ insertion and removal, for all organ subtypes usable in-game.
/// Ensures algorithmic correctness of the "Insert()" and "Remove()" procs.
/// This test is especially useful because developers frequently  override those.
/datum/unit_test/organ_sanity
	// List of organ typepaths which cause species change.
	// Species change swaps out all the organs, making test_organ un-usable after insertion.
	var/static/list/species_changing_organs = typecacheof(list(
		/obj/item/organ/internal/brain/shadow/nightmare,
	))
	// List of organ typepaths which are not test-able, such as certain class prototypes.
	var/static/list/test_organ_blacklist = typecacheof(list(
		/obj/item/organ/internal,
		/obj/item/organ/external,
		/obj/item/organ/external/wings,
		/obj/item/organ/internal/cyberimp,
		/obj/item/organ/internal/cyberimp/brain,
		/obj/item/organ/internal/cyberimp/mouth,
		/obj/item/organ/internal/cyberimp/arm,
		/obj/item/organ/internal/cyberimp/chest,
		/obj/item/organ/internal/cyberimp/eyes,
		/obj/item/organ/internal/alien,
	))

/datum/unit_test/organ_sanity/Run()
	for(var/obj/item/organ/organ_type as anything in subtypesof(/obj/item/organ))
		organ_test_insert(organ_type)

/datum/unit_test/organ_sanity/proc/organ_test_insert(obj/item/organ/organ_type)
	// Skip prototypes.
	if(test_organ_blacklist[organ_type])
		return

	// Appropriate mob (Human) which will receive organ.
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/test_organ = new organ_type()

	// Inappropriate mob (Dog) which will hopefully reject organ.
	var/mob/living/basic/pet/dog/lab_dog = allocate(/mob/living/basic/pet/dog/corgi)
	var/obj/item/organ/reject_organ = new organ_type()

	TEST_ASSERT(test_organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should return TRUE to indicate success."))
	TEST_ASSERT(!reject_organ.Insert(lab_dog, special = TRUE, drop_if_replaced = FALSE), TEST_ORGAN_INSERT_MESSAGE(test_organ, "shouldn't return TRUE when inserting into a basic mob (Corgi)."))

	// Species change swaps out all the organs, making test_organ un-usable by this point.
	if(species_changing_organs[test_organ.type])
		return

	TEST_ASSERT(test_organ.owner == lab_rat, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should assign the human to the organ's `owner` var."))
	TEST_ASSERT(test_organ in lab_rat.organs, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should insert the organ into the human's `internal_organs` list."))
	if(test_organ.slot)
		TEST_ASSERT(lab_rat.organs_slot[test_organ.slot] == test_organ, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add the organ to the human's `internal_organs_slot` list."))
		TEST_ASSERT(lab_rat.getorganslot(test_organ.slot) == test_organ, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should make the organ available via human's `getorganslot()` proc."))

	if(LAZYLEN(test_organ.organ_traits))
		TEST_ASSERT(LAZYLEN(lab_rat.status_traits), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Traits to lazylist `human.status_traits`."))
		for(var/test_trait in test_organ.organ_traits)
			TEST_ASSERT(HAS_TRAIT(lab_rat, test_trait), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Trait `[test_trait]` to lazylist `human.status_traits`"))
	
	if(LAZYLEN(test_organ.actions))
		TEST_ASSERT(LAZYLEN(lab_rat.actions), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Actions to lazylist `human.actions`."))
		for(var/datum/action/test_action as anything in test_organ.actions)
			TEST_ASSERT(test_action in lab_rat.actions, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Action `[test_action]` to lazylist `human.actions`."))

	if(LAZYLEN(test_organ.organ_effects))
		TEST_ASSERT(LAZYLEN(lab_rat.status_effects), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Status Effects to lazylist `human.status_effects`."))
		for(var/datum/status_effect/test_status as anything in test_organ.organ_effects)
			TEST_ASSERT(test_status in lab_rat.status_effects, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Status Effect `[test_status]` to lazylist `human.status_effects`."))

	test_organ.Remove(lab_rat, special = TRUE)

	TEST_ASSERT(test_organ.owner == null, TEST_ORGAN_REMOVE_MESSAGE(test_organ, "should assign the organ's `owner` var to null."))
	TEST_ASSERT(!(test_organ in lab_rat.organs), TEST_ORGAN_REMOVE_MESSAGE(test_organ, "should remove the organ from the human's `internal_organs` list."))
	if(test_organ.slot)
		TEST_ASSERT(lab_rat.organs_slot[test_organ.slot] != test_organ, TEST_ORGAN_REMOVE_MESSAGE(test_organ, "should remove the organ from the human's `internal_organs_slot` list."))
		TEST_ASSERT(lab_rat.getorganslot(test_organ.slot) != test_organ, TEST_ORGAN_REMOVE_MESSAGE(test_organ, "should remove the organ from the human's `getorganslot()` proc."))

	return

#undef TEST_ORGAN_INSERT_MESSAGE
#undef TEST_ORGAN_REMOVE_MESSAGE
