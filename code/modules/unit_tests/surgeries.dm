/datum/unit_test/amputation/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/circular_saw/saw = allocate(/obj/item/circular_saw)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 0, "Patient is somehow missing limbs before surgery")

	var/datum/surgery_operation/limb/amputate/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]

	UNLINT(surgery.success(patient.get_bodypart(BODY_ZONE_R_ARM), user, saw, list()))

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 1, "Patient did not lose any limbs")
	TEST_ASSERT_EQUAL(patient.get_missing_limbs()[1], BODY_ZONE_R_ARM, "Patient is missing a limb that isn't the one we operated on")

/datum/unit_test/brain_surgery/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
	patient.set_organ_loss(ORGAN_SLOT_BRAIN, 20)

	TEST_ASSERT(patient.has_trauma_type(), "Patient does not have any traumas, despite being given one")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	var/datum/surgery_operation/organ/repair/brain/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(surgery.success(patient.get_organ_slot(ORGAN_SLOT_BRAIN), user, hemostat, list()))

	TEST_ASSERT(!patient.has_trauma_type(), "Patient kept their brain trauma after brain surgery")
	TEST_ASSERT(patient.get_organ_loss(ORGAN_SLOT_BRAIN) < 20, "Patient did not heal their brain damage after brain surgery")

/datum/unit_test/head_transplant/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	var/mob/living/carbon/human/alice = allocate(/mob/living/carbon/human/consistent)
	alice.fully_replace_character_name(null, "Alice")
	alice.set_haircolor(COLOR_LIGHT_PINK, update = FALSE)
	alice.set_hairstyle("Very Long Hair", update = FALSE)
	alice.set_facial_haircolor(COLOR_LIGHT_PINK, update = FALSE)
	alice.set_facial_hairstyle("Shaved", update = TRUE)

	var/mob/living/carbon/human/bob = allocate(/mob/living/carbon/human/consistent)
	bob.fully_replace_character_name(null, "Bob")
	bob.set_haircolor(COLOR_LIGHT_BROWN, update = FALSE)
	bob.set_hairstyle("Short Hair", update = FALSE)
	bob.set_facial_haircolor(COLOR_LIGHT_BROWN, update = FALSE)
	bob.set_facial_hairstyle("Beard (Full)", update = TRUE)

	var/obj/item/bodypart/head/alices_head = alice.get_bodypart(BODY_ZONE_HEAD)
	alices_head.drop_limb()

	var/obj/item/bodypart/head/bobs_head = bob.get_bodypart(BODY_ZONE_HEAD)
	bobs_head.drop_limb()

	TEST_ASSERT_EQUAL(alice.get_bodypart(BODY_ZONE_HEAD), null, "Alice still has a head after dismemberment")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Unknown", "Alice's head was dismembered, but they are not Unknown")

	TEST_ASSERT_EQUAL(bobs_head.real_name, "Bob", "Bob's head does not remember that it is from Bob")

	// Put Bob's head onto Alice's body
	var/datum/surgery_operation/prosthetic_replacement/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	user.put_in_active_hand(bobs_head)
	UNLINT(surgery.success(alice.get_bodypart(BODY_ZONE_CHEST), user, bobs_head, list()))

	TEST_ASSERT(!isnull(alice.get_bodypart(BODY_ZONE_HEAD)), "Alice has no head after prosthetic replacement")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Bob", "Bob's head was transplanted onto Alice's body, but their name is not Bob")
	TEST_ASSERT_EQUAL(alice.hairstyle, "Short Hair", "Bob's head was transplanted onto Alice's body, but their hairstyle is not Short Hair")
	TEST_ASSERT_EQUAL(alice.hair_color, COLOR_LIGHT_BROWN, "Bob's head was transplanted onto Alice's body, but their hair color is not COLOR_LIGHT_BROWN")
	TEST_ASSERT_EQUAL(alice.facial_hairstyle, "Beard (Full)", "Bob's head was transplanted onto Alice's body, but their facial hairstyle is not Beard (Full)")
	TEST_ASSERT_EQUAL(alice.facial_hair_color, COLOR_LIGHT_BROWN, "Bob's head was transplanted onto Alice's body, but their facial hair color is not COLOR_LIGHT_BROWN")

/datum/unit_test/multiple_surgeries/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent/slow)
	ADD_TRAIT(user, TRAIT_HIPPOCRATIC_OATH, TRAIT_SOURCE_UNIT_TESTS)

	var/mob/living/carbon/human/patient_zero = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/patient_one = allocate(/mob/living/carbon/human/consistent)

	patient_zero.set_body_position(LYING_DOWN)
	patient_one.set_body_position(LYING_DOWN)

	ADD_TRAIT(patient_zero, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(patient_one, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	var/obj/item/bodypart/chest/patient_zero_chest = patient_zero.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/bodypart/chest/patient_one_chest = patient_one.get_bodypart(BODY_ZONE_CHEST)

	ADD_TRAIT(patient_zero_chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(patient_one_chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	user.put_in_active_hand(scalpel)

	ASYNC
		user.perform_surgery(patient_zero, scalpel)

	TEST_ASSERT(DOING_INTERACTION(user, patient_zero), "User is not performing surgery on patient zero as expected")

	ASYNC
		user.perform_surgery(patient_one, scalpel)

	TEST_ASSERT(DOING_INTERACTION(user, patient_one), "User is not able to perform surgery on two patients at once despite having the Hippocratic Oath trait")

// Ensures that the tend wounds surgery can be started
/datum/unit_test/start_tend_wounds

/datum/unit_test/start_tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	patient.set_body_position(LYING_DOWN)

	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	var/obj/item/bodypart/chest/patient_chest = patient.get_bodypart(BODY_ZONE_CHEST)
	ADD_TRAIT(patient_chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was available on an undamaged, unoperated patient")

	patient.take_overall_damage(10, 10)
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was available on a damaged but unoperated patient")

	patient_chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	TEST_ASSERT(surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was not available on a damaged, operated patient")

/datum/unit_test/tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.take_overall_damage(100, 100)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	// Test that tending wounds actually lowers damage
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(surgery.success(patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))
	TEST_ASSERT(patient.get_brute_loss() < 100, "Tending brute wounds didn't lower brute damage ([patient.get_brute_loss()])")

	// Test that wearing clothing lowers heal amount
	var/mob/living/carbon/human/naked_patient = allocate(/mob/living/carbon/human/consistent)
	naked_patient.take_overall_damage(100)

	var/mob/living/carbon/human/clothed_patient = allocate(/mob/living/carbon/human/consistent)
	clothed_patient.equipOutfit(/datum/outfit/job/doctor, TRUE)
	clothed_patient.take_overall_damage(100)

	UNLINT(surgery.success(naked_patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))
	UNLINT(surgery.success(clothed_patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))

	TEST_ASSERT(naked_patient.get_brute_loss() < clothed_patient.get_brute_loss(), "Naked patient did not heal more from wounds tending than a clothed patient")

/// Tests items-as-prosthetic-limbs can apply
/datum/unit_test/prosthetic_item

/datum/unit_test/prosthetic_item/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/claymore/sword = allocate(/obj/item/claymore)

	patient.make_item_prosthetic(sword)

	TEST_ASSERT(HAS_TRAIT_FROM(sword, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT), "Prosthetic item attachment failed! Item does not have the nodrop trait")

/// Specifically checks the chainsaw nullrod
/datum/unit_test/prosthetic_item/nullrod

/datum/unit_test/prosthetic_item/nullrod/Run()
	var/mob/living/carbon/human/picker = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/nullrod/chainsaw/nullrod = allocate(/obj/item/nullrod/chainsaw)

	nullrod.on_selected(null, null, picker)

	TEST_ASSERT(HAS_TRAIT_FROM(nullrod, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT), "Chainsaw nullrod item attachment failed! Item does not have the nodrop trait")

/// Checks all operations have a name and description
/datum/unit_test/verify_surgery_setup

/datum/unit_test/verify_surgery_setup/Run()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(subtypesof(/datum/surgery_operation), filter_replaced = FALSE))
		if (isnull(operation.name))
			TEST_FAIL("Surgery operation [operation.type] has no name set")
		if (isnull(operation.desc))
			TEST_FAIL("Surgery operation [operation.type] has no description set")

/// Checks replaced surgeries are filtered out correctly
/datum/unit_test/verify_surgery_replacements

/datum/unit_test/verify_surgery_replacements/Run()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(subtypesof(/datum/surgery_operation), filter_replaced = TRUE))
		if(!operation.replaced_by || operation.replaced_by.type == operation.type)
			continue
		TEST_FAIL("Surgery operation [operation.type] is marked as replaced by [operation.replaced_by.type], \
			but the operation was not correctly filtered by get_instances.")

/// Tests that make incision shows up when expected
/datum/unit_test/incision_check

/datum/unit_test/incision_check/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/list/operations

	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	surgeon.put_in_active_hand(scalpel)
	operations = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(length(operations), 0, "Surgery operations were available on a standing patient")

	patient.set_body_position(LYING_DOWN)
	operations = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)
	if(length(operations) > 1)
		TEST_FAIL("More operations than expected were available on the patient")
		return

	if(length(operations) == 1)
		var/list/found_operation_data = operations[operations[1]]
		var/datum/surgery_operation/operation = found_operation_data[1]
		var/atom/movable/operating_on = found_operation_data[2]
		TEST_ASSERT_EQUAL(operation.type, /datum/surgery_operation/limb/incise_skin, "The available surgery operation was not \"make incision\"")
		TEST_ASSERT_EQUAL(operating_on, patient.get_bodypart(BODY_ZONE_CHEST), "The available surgery operation was not on the chest bodypart")
		return

	TEST_ASSERT_EQUAL(patient.body_position, LYING_DOWN, "Patient is not lying down as expected")

	var/datum/surgery_operation/incise_operation = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]
	var/atom/movable/operate_on = incise_operation.get_operation_target(patient, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(operate_on, patient.get_bodypart(BODY_ZONE_CHEST), "Incise skin operation did not return the chest bodypart as a valid operation target")

	if(incise_operation.check_availability(patient, operate_on, surgeon, scalpel, BODY_ZONE_CHEST))
		TEST_FAIL("Make incision operation was not found among available operations despite being available")
	else
		TEST_FAIL("Make incision operation was not available when it should have been")

/// Checks is_location_accessible works as intended
/datum/unit_test/location_accessibility

/datum/unit_test/location_accessibility/Run()
	var/mob/living/carbon/human/test_mob = allocate(/mob/living/carbon/human/consistent)

	test_mob.equipOutfit(/datum/outfit/job/assistant/consistent)
	TEST_ASSERT(!test_mob.is_location_accessible(BODY_ZONE_CHEST), "Chest should be inaccessible when wearing a jumpsuit")

	var/obj/item/clothing/under/jumpsuit = test_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	jumpsuit.adjust_to_alt()
	TEST_ASSERT(test_mob.is_location_accessible(BODY_ZONE_CHEST), "Chest should be accessible after rolling jumpsuit down")
