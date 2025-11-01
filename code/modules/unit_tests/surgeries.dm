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
	patient.setOrganLoss(ORGAN_SLOT_BRAIN, 20)

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

	TEST_ASSERT(DOING_INTERACTION(user, DOAFTER_SOURCE_SURGERY), "User is not performing surgery on patient zero as expected")

	ASYNC
		user.perform_surgery(patient_zero, scalpel)

	TEST_ASSERT(!DOING_INTERACTION(user, DOAFTER_SOURCE_SURGERY), "User is performing surgery on patient one, despite already operating on patient zero")
	ADD_TRAIT(user, TRAIT_HIPPOCRATIC_OATH, TRAIT_SOURCE_UNIT_TESTS)

	ASYNC
		user.perform_surgery(patient_zero, scalpel)

	TEST_ASSERT(DOING_INTERACTION(user, patient_one), "User was unable to operate on patient one despite having the Hippocratic Oath trait")

// Ensures that the tend wounds surgery can be started
/datum/unit_test/start_tend_wounds

/datum/unit_test/start_tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	var/obj/item/bodypart/chest/patient_chest = patient.get_bodypart(BODY_ZONE_CHEST)
	ADD_TRAIT(patient_chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was available on an undamaged, unoperated patient")

	patient.take_overall_damage(10, 10)
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was available on a damaged but unoperated patient")

	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	TEST_ASSERT(surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds surgery was not available on a damaged, operated patient")

/datum/unit_test/tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.take_overall_damage(100, 100)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	// Test that tending wounds actually lowers damage
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(surgery.success(patient, user, hemostat, list("brute_heal" = 10, "brute_multiplier" = 0.1)))
	TEST_ASSERT(patient.getBruteLoss() < 100, "Tending brute wounds didn't lower brute damage ([patient.getBruteLoss()])")

	// Test that wearing clothing lowers heal amount
	var/mob/living/carbon/human/naked_patient = allocate(/mob/living/carbon/human/consistent)
	naked_patient.take_overall_damage(100)

	var/mob/living/carbon/human/clothed_patient = allocate(/mob/living/carbon/human/consistent)
	clothed_patient.equipOutfit(/datum/outfit/job/doctor, TRUE)
	clothed_patient.take_overall_damage(100)

	UNLINT(surgery.success(naked_patient, user, hemostat, list("brute_heal" = 10, "brute_multiplier" = 0.1)))
	UNLINT(surgery.success(clothed_patient, user, hemostat, list("brute_heal" = 10, "brute_multiplier" = 0.1)))

	TEST_ASSERT(naked_patient.getBruteLoss() < clothed_patient.getBruteLoss(), "Naked patient did not heal more from wounds tending than a clothed patient")

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
