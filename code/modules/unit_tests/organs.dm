#define TEST_ORGAN_INSERT_MESSAGE(test_organ, message) "`[test_organ.type]/Insert()` [message]"
#define TEST_ORGAN_REMOVE_MESSAGE(test_organ, message) "`[test_organ.type]/Remove()` [message]"

/// Check organ insertion and removal, for all organ subtypes usable in-game.
/// Ensures algorithmic correctness of the "Insert()" and "Remove()" procs.
/// This test is especially useful because developers frequently  override those.
/datum/unit_test/organ_sanity
	// List of organ typepaths which cause species change.
	// Species change swaps out all the organs, making test_organ un-usable after insertion.
	var/static/list/species_changing_organs = typecacheof(list(
		/obj/item/organ/brain/shadow/nightmare,
	))

/datum/unit_test/organ_sanity/Run()
	for(var/obj/item/organ/organ_type as anything in subtypesof(/obj/item/organ) - GLOB.prototype_organs)
		organ_test_insert(organ_type)

/datum/unit_test/organ_sanity/proc/organ_test_insert(obj/item/organ/organ_type)
	// Appropriate mob (Human) which will receive organ.
	var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/test_organ = new organ_type()

	// Inappropriate mob (Dog) which will hopefully reject organ.
	var/mob/living/basic/pet/dog/lab_dog = allocate(/mob/living/basic/pet/dog/corgi)
	var/obj/item/organ/reject_organ = new organ_type()

	TEST_ASSERT(test_organ.Insert(lab_rat, special = TRUE, movement_flags = DELETE_IF_REPLACED), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should return TRUE to indicate success."))
	TEST_ASSERT(!reject_organ.Insert(lab_dog, special = TRUE, movement_flags = DELETE_IF_REPLACED), TEST_ORGAN_INSERT_MESSAGE(test_organ, "shouldn't return TRUE when inserting into a basic mob (Corgi)."))

	// Species change swaps out all the organs, making test_organ un-usable by this point.
	if(species_changing_organs[test_organ.type])
		return

	TEST_ASSERT(test_organ.owner == lab_rat, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should assign the human to the organ's `owner` var."))
	TEST_ASSERT(test_organ in lab_rat.organs, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should insert the organ into the human's `internal_organs` list."))
	if(test_organ.slot)
		TEST_ASSERT(lab_rat.organs_slot[test_organ.slot] == test_organ, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add the organ to the human's `internal_organs_slot` list."))
		TEST_ASSERT(lab_rat.get_organ_slot(test_organ.slot) == test_organ, TEST_ORGAN_INSERT_MESSAGE(test_organ, "should make the organ available via human's `get_organ_slot()` proc."))

	if(LAZYLEN(test_organ.organ_traits))
		TEST_ASSERT(LAZYLEN(lab_rat._status_traits), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Traits to lazylist `human._status_traits`."))
		for(var/test_trait in test_organ.organ_traits)
			TEST_ASSERT(HAS_TRAIT(lab_rat, test_trait), TEST_ORGAN_INSERT_MESSAGE(test_organ, "should add Trait `[test_trait]` to lazylist `human._status_traits`"))

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
		TEST_ASSERT(lab_rat.get_organ_slot(test_organ.slot) != test_organ, TEST_ORGAN_REMOVE_MESSAGE(test_organ, "should remove the organ from the human's `get_organ_slot()` proc."))

	return

#undef TEST_ORGAN_INSERT_MESSAGE
#undef TEST_ORGAN_REMOVE_MESSAGE

/// Tests organ damage cap.
/// Organ damage should never bypass the cap.
/// Every internal organ is tested.
/datum/unit_test/organ_damage

/datum/unit_test/organ_damage/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	for(var/obj/item/organ/organ_to_test in dummy.organs)
		test_organ(dummy, organ_to_test)

/datum/unit_test/organ_damage/proc/test_organ(mob/living/carbon/human/dummy, obj/item/organ/test_organ)
	var/slot_to_use = test_organ.slot

	// Tests [mob/living/proc/adjustOrganLoss]
	TEST_ASSERT_EQUAL(dummy.adjustOrganLoss(slot_to_use, test_organ.maxHealth * 10), -test_organ.maxHealth, \
		"Mob level \"apply organ damage\" returned the wrong value for [slot_to_use] organ with default arguments.")
	TEST_ASSERT_EQUAL(dummy.get_organ_loss(slot_to_use), test_organ.maxHealth, \
		"Mob level \"apply organ damage\" can exceed the [slot_to_use] organ's damage cap with default arguments.")
	dummy.fully_heal(HEAL_ORGANS)

	// Tests [mob/living/proc/set_organ_damage]
	TEST_ASSERT_EQUAL(dummy.setOrganLoss(slot_to_use, test_organ.maxHealth * 10), -test_organ.maxHealth, \
		"Mob level \"set organ damage\" returned the wrong value for [slot_to_use] organ with default arguments.")
	TEST_ASSERT_EQUAL(dummy.get_organ_loss(slot_to_use), test_organ.maxHealth, \
		"Mob level \"set organ damage\" can exceed the [slot_to_use] organ's damage cap with default arguments.")
	dummy.fully_heal(HEAL_ORGANS)

	// Tests [mob/living/proc/adjustOrganLoss] with a large max supplied
	TEST_ASSERT_EQUAL(dummy.adjustOrganLoss(slot_to_use, test_organ.maxHealth * 10, INFINITY), -test_organ.maxHealth, \
		"Mob level \"apply organ damage\" returned the wrong value for [slot_to_use] organ with a large maximum supplied.")
	TEST_ASSERT_EQUAL(dummy.get_organ_loss(slot_to_use), test_organ.maxHealth, \
		"Mob level \"apply organ damage\" can exceed the [slot_to_use] organ's damage cap with a large maximum supplied.")
	dummy.fully_heal(HEAL_ORGANS)
