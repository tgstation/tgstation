/datum/unit_test/amputation/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 0, "Patient is somehow missing limbs before surgery")

	var/datum/surgery/amputation/surgery = new(patient, BODY_ZONE_R_ARM, patient.get_bodypart(BODY_ZONE_R_ARM))

	var/datum/surgery_step/sever_limb/sever_limb = new
	sever_limb.success(user, patient, BODY_ZONE_R_ARM, null, surgery)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 1, "Patient did not lose any limbs")
	TEST_ASSERT_EQUAL(patient.get_missing_limbs()[1], BODY_ZONE_R_ARM, "Patient is missing a limb that isn't the one we operated on")

/datum/unit_test/brain_surgery/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
	patient.setOrganLoss(ORGAN_SLOT_BRAIN, 20)

	TEST_ASSERT(patient.has_trauma_type(), "Patient does not have any traumas, despite being given one")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	var/datum/surgery_step/fix_brain/fix_brain = new
	fix_brain.success(user, patient)

	TEST_ASSERT(!patient.has_trauma_type(), "Patient kept their brain trauma after brain surgery")
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_BRAIN) < 20, "Patient did not heal their brain damage after brain surgery")

/datum/unit_test/head_transplant/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/alice = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/bob = allocate(/mob/living/carbon/human/consistent)

	alice.fully_replace_character_name(null, "Alice")
	bob.fully_replace_character_name(null, "Bob")

	var/obj/item/bodypart/head/alices_head = alice.get_bodypart(BODY_ZONE_HEAD)
	alices_head.drop_limb()

	var/obj/item/bodypart/head/bobs_head = bob.get_bodypart(BODY_ZONE_HEAD)
	bobs_head.drop_limb()

	TEST_ASSERT_EQUAL(alice.get_bodypart(BODY_ZONE_HEAD), null, "Alice still has a head after dismemberment")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Unknown", "Alice's head was dismembered, but they are not Unknown")

	TEST_ASSERT_EQUAL(bobs_head.real_name, "Bob", "Bob's head does not remember that it is from Bob")

	// Put Bob's head onto Alice's body
	var/datum/surgery_step/add_prosthetic/add_prosthetic = new
	user.put_in_active_hand(bobs_head)
	add_prosthetic.success(user, alice, BODY_ZONE_HEAD, bobs_head)

	TEST_ASSERT(!isnull(alice.get_bodypart(BODY_ZONE_HEAD)), "Alice has no head after prosthetic replacement")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Bob", "Bob's head was transplanted onto Alice's body, but their name is not Bob")

/datum/unit_test/multiple_surgeries/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/patient_zero = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/patient_one = allocate(/mob/living/carbon/human/consistent)

	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)

	var/datum/surgery_step/incise/surgery_step = new
	var/datum/surgery/organ_manipulation/surgery_for_zero = new

	INVOKE_ASYNC(surgery_step, TYPE_PROC_REF(/datum/surgery_step, initiate), user, patient_zero, BODY_ZONE_CHEST, scalpel, surgery_for_zero)
	TEST_ASSERT(surgery_for_zero.step_in_progress, "Surgery on patient zero was not initiated")

	var/datum/surgery/organ_manipulation/surgery_for_one = new

	// Without waiting for the incision to complete, try to start a new surgery
	TEST_ASSERT(!surgery_step.initiate(user, patient_one, BODY_ZONE_CHEST, scalpel, surgery_for_one), "Was allowed to start a second surgery without the rod of asclepius")
	TEST_ASSERT(!surgery_for_one.step_in_progress, "Surgery for patient one is somehow in progress, despite not initiating")

	user.apply_status_effect(/datum/status_effect/hippocratic_oath)
	INVOKE_ASYNC(surgery_step, TYPE_PROC_REF(/datum/surgery_step, initiate), user, patient_one, BODY_ZONE_CHEST, scalpel, surgery_for_one)
	TEST_ASSERT(surgery_for_one.step_in_progress, "Surgery on patient one was not initiated, despite having rod of asclepius")

/// Ensures that the tend wounds surgery can be started
/datum/unit_test/start_tend_wounds

/datum/unit_test/start_tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	var/datum/surgery/surgery = new /datum/surgery/healing/brute/basic

	if (!surgery.can_start(user, patient))
		TEST_FAIL("Can't start basic tend wounds!")

	qdel(surgery)

/datum/unit_test/tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.take_overall_damage(100, 100)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	// Test that tending wounds actually lowers damage
	var/datum/surgery_step/heal/brute/basic/basic_brute_heal = new
	basic_brute_heal.success(user, patient, BODY_ZONE_CHEST)
	TEST_ASSERT(patient.getBruteLoss() < 100, "Tending brute wounds didn't lower brute damage ([patient.getBruteLoss()])")

	var/datum/surgery_step/heal/burn/basic/basic_burn_heal = new
	basic_burn_heal.success(user, patient, BODY_ZONE_CHEST)
	TEST_ASSERT(patient.getFireLoss() < 100, "Tending burn wounds didn't lower burn damage ([patient.getFireLoss()])")

	// Test that wearing clothing lowers heal amount
	var/mob/living/carbon/human/naked_patient = allocate(/mob/living/carbon/human/consistent)
	naked_patient.take_overall_damage(100)

	var/mob/living/carbon/human/clothed_patient = allocate(/mob/living/carbon/human/consistent)
	clothed_patient.equipOutfit(/datum/outfit/job/doctor, TRUE)
	clothed_patient.take_overall_damage(100)

	basic_brute_heal.success(user, naked_patient, BODY_ZONE_CHEST)
	basic_brute_heal.success(user, clothed_patient, BODY_ZONE_CHEST)

	TEST_ASSERT(naked_patient.getBruteLoss() < clothed_patient.getBruteLoss(), "Naked patient did not heal more from wounds tending than a clothed patient")
