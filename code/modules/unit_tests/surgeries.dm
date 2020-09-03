/datum/unit_test/amputation/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 0, "Patient is somehow missing limbs before surgery")

	var/datum/surgery/amputation/surgery = new(patient, BODY_ZONE_R_ARM, patient.get_bodypart(BODY_ZONE_R_ARM))

	var/datum/surgery_step/sever_limb/sever_limb = new
	sever_limb.success(user, patient, BODY_ZONE_R_ARM, null, surgery)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 1, "Patient did not lose any limbs")
	TEST_ASSERT_EQUAL(patient.get_missing_limbs()[1], BODY_ZONE_R_ARM, "Patient is missing a limb that isn't the one we operated on")

/datum/unit_test/brain_surgery/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
	patient.setOrganLoss(ORGAN_SLOT_BRAIN, 20)

	TEST_ASSERT(patient.has_trauma_type(), "Patient does not have any traumas, despite being given one")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	var/datum/surgery_step/fix_brain/fix_brain = new
	fix_brain.success(user, patient)

	TEST_ASSERT(!patient.has_trauma_type(), "Patient kept their brain trauma after brain surgery")
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_BRAIN) < 20, "Patient did not heal their brain damage after brain surgery")

/datum/unit_test/multiple_surgeries/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient_zero = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient_one = allocate(/mob/living/carbon/human)

	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)

	var/datum/surgery_step/incise/surgery_step = new
	var/datum/surgery/organ_manipulation/surgery_for_zero = new

	INVOKE_ASYNC(surgery_step, /datum/surgery_step/proc/initiate, user, patient_zero, BODY_ZONE_CHEST, scalpel, surgery_for_zero)
	TEST_ASSERT(surgery_for_zero.step_in_progress, "Surgery on patient zero was not initiated")

	var/datum/surgery/organ_manipulation/surgery_for_one = new

	// Without waiting for the incision to complete, try to start a new surgery
	TEST_ASSERT(!surgery_step.initiate(user, patient_one, BODY_ZONE_CHEST, scalpel, surgery_for_one), "Was allowed to start a second surgery without the rod of asclepius")
	TEST_ASSERT(!surgery_for_one.step_in_progress, "Surgery for patient one is somehow in progress, despite not initiating")

	user.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	INVOKE_ASYNC(surgery_step, /datum/surgery_step/proc/initiate, user, patient_one, BODY_ZONE_CHEST, scalpel, surgery_for_one)
	TEST_ASSERT(surgery_for_one.step_in_progress, "Surgery on patient one was not initiated, despite having rod of asclepius")

/datum/unit_test/tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.take_overall_damage(100, 100)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Test that tending wounds actually lowers damage
	var/datum/surgery_step/heal/brute/basic/basic_brute_heal = new
	basic_brute_heal.success(user, patient, BODY_ZONE_CHEST)
	TEST_ASSERT(patient.getBruteLoss() < 100, "Tending brute wounds didn't lower brute damage ([patient.getBruteLoss()])")

	var/datum/surgery_step/heal/burn/basic/basic_burn_heal = new
	basic_burn_heal.success(user, patient, BODY_ZONE_CHEST)
	TEST_ASSERT(patient.getFireLoss() < 100, "Tending burn wounds didn't lower burn damage ([patient.getFireLoss()])")

	// Test that wearing clothing lowers heal amount
	var/mob/living/carbon/human/naked_patient = allocate(/mob/living/carbon/human)
	naked_patient.take_overall_damage(100)

	var/mob/living/carbon/human/clothed_patient = allocate(/mob/living/carbon/human)
	clothed_patient.equipOutfit(/datum/outfit/job/doctor, TRUE)
	clothed_patient.take_overall_damage(100)

	basic_brute_heal.success(user, naked_patient, BODY_ZONE_CHEST)
	basic_brute_heal.success(user, clothed_patient, BODY_ZONE_CHEST)

	TEST_ASSERT(naked_patient.getBruteLoss() < clothed_patient.getBruteLoss(), "Naked patient did not heal more from wounds tending than a clothed patient")
