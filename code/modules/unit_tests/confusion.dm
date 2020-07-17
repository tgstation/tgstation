// Check if get_confusion() accurately tracks confusion
// and that handle_status_effects() accurately lowers it
/datum/unit_test/living_confusion/Run()
	// Pause natural Life() calls so confusion is managed entirely by the tests
	SSmobs.pause()

	var/mob/living/ian = allocate(/mob/living/simple_animal/pet/dog/corgi/ian)
	TEST_ASSERT_EQUAL(ian.get_confusion(), 0, "Ian didn't start out with 0 confusion")

	ian.confused += 10
	TEST_ASSERT_EQUAL(ian.get_confusion(), 10, "Ian didn't have 10 confusion after raising confused variable by 10")

	ian.handle_status_effects()
	TEST_ASSERT(ian.get_confusion() < 10, "handle_status_effects didn't lower Ian's confusion")

	ian.confused = 0

	var/datum/component/confusion/confusion1 = ian.AddComponent(/datum/component/confusion, 5)
	TEST_ASSERT_EQUAL(ian.get_confusion(), 5, "get_confusion() didn't factor in the first confusion component")
	ian.handle_status_effects()
	TEST_ASSERT(ian.get_confusion() < 5, "handle_status_effects didn't lower the confusion of the first confusion component")

	var/datum/component/confusion/confusion2 = ian.AddComponent(/datum/component/confusion, 5)
	TEST_ASSERT(ian.get_confusion() > 5, "get_confusion() didn't factor in multiple confusion components")

	qdel(confusion1)
	qdel(confusion2)

	TEST_ASSERT_EQUAL(ian.get_confusion(), 0, "After deleting all sources of confusion, Ian is still confused")

/datum/unit_test/living_confusion/Destroy()
	SSmobs.ignite()
	return ..()

// Checks that the confusion symptom correctly gives, and removes, confusion
/datum/unit_test/confusion_symptom/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/confusion/disease = allocate(/datum/disease/advance/confusion)
	var/datum/symptom/confusion/confusion = disease.symptoms[1]
	disease.processing = TRUE
	disease.update_stage(5)
	disease.infect(H, make_copy = FALSE)
	confusion.Activate(disease)
	TEST_ASSERT(H.get_confusion() > 0, "Human is not confused after getting symptom.")
	disease.cure()
	TEST_ASSERT_EQUAL(H.get_confusion(), 0, "Human is still confused after curing confusion.")

/datum/disease/advance/confusion/New()
	symptoms += new /datum/symptom/confusion
	Refresh()
